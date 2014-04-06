------------------------------------------------------------------------
-- Title      : Elastic Buffer
------------------------------------------------------------------------
-- File       : elastic_buffer_core.vhd
-- Author     : Xilinx Inc.
------------------------------------------------------------------------
--
-- *************************************************************************
--
-- (c) Copyright 1998 - 2011 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- This is based on Coregen Wrappers from ISE O.40d (13.1)
-- Wrapper version 2.1
-------------------------------------------------------------------------------
-- Description: This is the Elastic Buffer which accepts the signals in the
--              CORE_CLK domain and transfers it into the GMII_MII_CLK domain
--              It will automatically correct the pointer when an buffer
--              overflow or underflow occurs
--
--              This elastic buffer is based on the tx_elastic_buffer of
--              the pcs_pma_v2_0 design, scaled down to 8 deep.  It is
--              6 deep because the silicon area demands it.  Setting
--              the upper and lower threshold for a 6 deep FIFO was tricky.
--              Because of the one clock latency introduced by the latching of
--              the OCCUPANCY signals, every pointer adjustment takes three
--              clock cycles.  The first cycle to detect that there is a full/
--              empty. The second cycle to increment rd address but not write,
--              or vice versa, the last cycle for the new occupancy to be
--              latched.
--              For write occupancy problem, the FIFO will adjust when
--              WR_OCCUPANCY = 5.  After adjustment, WR_OCCUPANCY will be 2,
--              but because of the clock skew between rd/wr clock, RD_OCCUPANCY
--              can be as low as 1.  Because of this, read occupancy is allowed
--              to adjust when RD_OCCUPANCY < 1 but not while it is equal to 1.
--              Otherwise, we will go from a NEARLY_FULL to a NEARLY_EMPTY condition.
--              This means that the pointers will not adjust *before* a buffer
--              error.  It will adjust while the buffer is reading and writing
--              to the same address space.
--              However, these sync buffers are special in that they are used
--              to synchronized between two clock domains of the exactly same
--              frequency, with only phase difference.  This means that the
--              buffers will need adjusting once and should never get either
--              full or empty.
--              Do not use these buffers as is to adjust for clock domains with
--              frequency differences.  It will not work right.
--
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use ieee.numeric_std.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;


library UNISIM;
use UNISIM.VCOMPONENTS.all;

library work;
use work.COMMON_PACK.all;



entity ELASTIC_BUFFER_8 is
  generic (
    D_WIDTH : positive
    );
   port(

      WR_RESET        : in std_logic;                      -- WR clock domain Reset.
      RD_RESET        : in std_logic;                      -- RD clock domain Reset.

      -------------------------------------------------------------------------
      -- Signals received from the input _CLK_WR domain.
      -------------------------------------------------------------------------

      CLK_WR          : in std_logic;                      -- Write clock domain.
      WR_EN           : in std_logic;                      -- FIFO data write
      D_WR            : in std_logic_vector(D_WIDTH-1 downto 0);   -- Data synchronous to CLK_WR.
      EN_WR           : in std_logic;                      -- EN synchronous to CLK_WR.
      ER_WR           : in std_logic;                      -- ER synchronous to CLK_WR.
      IFG_DELAY       : in std_logic_vector(7 downto 0);   -- number of IFG between frame

      -------------------------------------------------------------------------
      -- Signals transfered onto the new CLK_RD domain.
      -------------------------------------------------------------------------

      CLK_RD          : in std_logic;                      -- Read clock domain.
      RD_ADV          : in std_logic;                      -- advance FIFO Read data
      D_RD            : out std_logic_vector(D_WIDTH-1 downto 0);  -- Data synchronous to CLK_RD.
      EN_RD           : out std_logic;                     -- EN synchronous to CLK_RD.
      ER_RD           : out std_logic                      -- ER synchronous to CLK_RD.



   );

end ELASTIC_BUFFER_8;

architecture RTL of ELASTIC_BUFFER_8 is


   constant LOWER_THRESHOLD : unsigned := "001";           -- FIFO occupancy should be kept at 1 or above.
   constant UPPER_THRESHOLD : unsigned := "101";           -- FIFO occupancy should be kept at 4 or below.

   signal EN_WR_REG         : std_logic;                    -- Registered version of EN_WR.
   signal ER_WR_REG         : std_logic;                    -- Registered version of ER_WR.
   signal EN_WREN_REG       : std_logic;                    -- Registered version of EN_WR.
   signal ER_WREN_REG       : std_logic;                    -- Registered version of ER_WR.
   signal D_WR_REG          : std_logic_vector(D_WIDTH-1 downto 0);
   signal WR_ENABLE         : std_logic;                    -- write enable for FIFO.
   signal RD_ENABLE         : std_logic;                    -- read enable for FIFO.
   signal NEARLY_FULL       : std_logic;                    -- FIFO is getting full.
   signal NEARLY_EMPTY      : std_logic;                    -- FIFO is becoming empty.
   signal NEXT_WR_ADDR      : unsigned(2 downto 0);         -- Next FIFO write address (to reduce latency in gray code logic).
   signal WR_ADDR           : unsigned(2 downto 0);         -- FIFO write address.
   signal WR_ADDRGRAY       : std_logic_vector(2 downto 0); -- FIFO write address converted to Gray Code.
   signal WAG_READSYNC      : std_logic_vector(2 downto 0); -- WR_ADDRGRAY Registered on read clock.
   signal WR_ADDRBIN        : unsigned(2 downto 0);         -- WR_ADDRGRAY converted back to binary - on READ clock.
   signal NEXT_RD_ADDR      : unsigned(2 downto 0);         -- Next FIFO write address (to reduce latency in gray code logic).
   signal RD_ADDR           : unsigned(2 downto 0);         -- FIFO write address.
   signal RD_ADDRGRAY       : std_logic_vector(2 downto 0); -- FIFO read address converted to Gray Code.
   signal RAG_WRITESYNC     : std_logic_vector(2 downto 0); -- RD_ADDRGRAY Registered on write clock.

   -- This attribute will stop timing errors being reported in back annotated SDF simulation.
   attribute ASYNC_REG               : string;
   attribute ASYNC_REG of RAG_WRITESYNC : signal is "TRUE";
   attribute ASYNC_REG of WAG_READSYNC  : signal is "true";
   attribute ASYNC_REG of WR_ENABLE     : signal is "true";

   signal RD_ADDRBIN        : unsigned(2 downto 0);         -- RD_ADDRGRAY converted back to binary - on WRITE clock.
   signal EN_FIFO           : std_logic;                    -- EN_WR after FIFO.
   signal ER_FIFO           : std_logic;                    -- ER_WR after FIFO.
   signal D_FIFO            : std_logic_vector(D_WIDTH-1 downto 0); -- D_WR after FIFO.
   signal EN_FIFO_REG       : std_logic;                    -- Registered version of EN_FIFO.
   signal ER_FIFO_REG       : std_logic;                    -- Registered version of ER_FIFO.
   signal D_FIFO_REG        : std_logic_vector(D_WIDTH-1 downto 0); -- Registered version of D_FIFO.
   signal WR_OCCUPANCY      : unsigned(2 downto 0);         -- The occupancy of the FIFO in write clock domain.
   signal RD_OCCUPANCY      : unsigned(2 downto 0);         -- The occupancy of the FIFO in read clock domain.

   signal RAM_IN            : std_logic_vector(D_WIDTH+1 downto 0); -- FIFO inputs    RY
   signal RAM_OUT           : std_logic_vector(D_WIDTH+1 downto 0) := (others => '0'); -- FIFO outputs   RY
   signal WR_IFG_CNTR_RESET : std_logic;  -- Reset Interframe gap counter
   signal WR_IFG_CNTR_START : std_logic;  -- Start Interframe gap counter
   signal WR_IFG_CNTR       : std_logic_vector(7 downto 0);  -- Count the number of bytes in Interframe Gaps
   signal WR_IFG_REACHED    : std_logic;  -- IFG_CNTR is all 0
   signal MIFG              : std_logic;  -- high during IFG.  Enable IFG_CNTR to count

   type sync_buf is array (7 downto 0) of std_logic_vector(10 downto 0);

   signal mem                    :  sync_buf := (others => (others => '0'));
   signal ADDR : std_logic_vector(2 downto 0);
   signal DPR_ADDR : std_logic_vector(2 downto 0);

   attribute ASYNC_REG of mem           : signal is "true";

 begin


-------------------------------------------------------------------------------
-- FIFO WRITE LOGIC :
-------------------------------------------------------------------------------


-- purpose: Reclock EN_WR and ER_WR.  Provide one stage latency before feeding
-- into FIFO to match the WR_ENABLE one stage latency.
-- type   : sequential
   RECLOCK_GMII: process (CLK_WR)
   begin
      if CLK_WR'event and CLK_WR = '1' then
         EN_WR_REG <= EN_WR;
         ER_WR_REG <= ER_WR;
         D_WR_REG(D_WIDTH-1 downto 0)  <= D_WR(D_WIDTH-1 downto 0);

      end if;
   end process RECLOCK_GMII;

   -- Reclock EN and ER only when WR_EN is high.  This is used to decode the
   -- beginning and end of the frame written into the buffer so that 12 IFG can be
   -- counted before the RD/WR buffer pointers are adjusted.

   RECLOCK_EN_ER: process (CLK_WR)
   begin
      if CLK_WR'event and CLK_WR = '1' then
        if WR_EN = '1' then
          EN_WREN_REG <= EN_WR;
          ER_WREN_REG <= ER_WR;
        end if;
      end if;
   end process RECLOCK_EN_ER;

   -- purpose: generate pulse on rising edge of EN_WR to reset the interframe gap counter
   -- type   : combinational
   -- inputs : EN_WR_REG, EN_WR, ER_WR_REG

   GEN_WR_IFG_CNTR_RESET: process (EN_WREN_REG, EN_WR)
   begin  -- process CNTR_RESET
     if (EN_WREN_REG = '0' and EN_WR = '1')
     then
       WR_IFG_CNTR_RESET <= '1';
     else
       WR_IFG_CNTR_RESET <= '0';
     end if;
   end process GEN_WR_IFG_CNTR_RESET;

   -- purpose: generate pulse at end of frame to start the interframe gap counter
   -- type   : combinational
   -- inputs : EN_WR_REG, EN_WR

   GEN_WR_IFG_CNTR_START: process (EN_WREN_REG, EN_WR, WR_EN, ER_WREN_REG, ER_WR)
   begin  -- process CNTR_RESET
     if ((EN_WREN_REG = '1' and EN_WR = '0' and ER_WR = '0') or   -- End of frame, no extension.
          (ER_WREN_REG = '1' and ER_WR = '0' and EN_WR = '0'))      -- End of Extension.
     then
       WR_IFG_CNTR_START <= '1';
     else
       WR_IFG_CNTR_START <= '0';
     end if;
   end process GEN_WR_IFG_CNTR_START;

   -- purpose: generate signal Maintain IFG
   GEN_MIFG: process (CLK_WR)
   begin  -- process GEN_MIFG
     if CLK_WR'event and CLK_WR = '1' then  -- rising clock edge
       if WR_IFG_CNTR_RESET = '1' or WR_RESET = '1' then
         MIFG <= '0';
       elsif WR_IFG_CNTR_START = '1' then
         MIFG <= '1';
       end if;
     end if;
   end process GEN_MIFG;


   -- purpose: Inter frame gap counter.  Count interframe gaps and prevents
   -- pointer correction during the required IFG.  This counter resets
   -- at rising edge of EN_WR going high, starts counting at the end of frame
   -- and stops when it gets to 0.
   -- MN 11/2008: Changed to reset to 0 - required value should be updated on the rising edge of EN_WR

   GEN_WR_IFG_CNTR: process (CLK_WR)
   begin  -- process WR_IFG_CNTR
     if CLK_WR'event and CLK_WR = '1' then
       if WR_RESET = '1' then
         WR_IFG_CNTR <= (others => '0');
       elsif WR_IFG_CNTR_RESET = '1' then
         WR_IFG_CNTR <= IFG_DELAY;
       else
         if (WR_IFG_CNTR /= "00000000" and WR_EN = '1' and (WR_IFG_CNTR_START = '1' or MIFG = '1')) then
           WR_IFG_CNTR <= WR_IFG_CNTR - 1;
         end if;
       end if;
     end if;
   end process GEN_WR_IFG_CNTR;

  WR_IFG_REACHED <= not(WR_IFG_CNTR(7) or WR_IFG_CNTR(6) or WR_IFG_CNTR(5) or
                        WR_IFG_CNTR(4) or WR_IFG_CNTR(3) or WR_IFG_CNTR(2) or
                        WR_IFG_CNTR(1) or WR_IFG_CNTR(0));

-- purpose: Create the FIFO write enable.
-- type   : sequential
   GEN_WR_ENABLE: process (CLK_WR)
   begin
     if CLK_WR'event and CLK_WR = '1' then
       if WR_RESET = '1' then
         WR_ENABLE <= '0';
          -- Check to see that all specified IFG have been transmitted before
          -- allowing pointer correction
          -- Keep setting WR_ENABLE low until either NEARLY_FULL is low or EN_ WR or EN_ER goes high
       elsif (NEARLY_FULL = '1' and WR_IFG_REACHED = '1'  and WR_EN = '1' and EN_WR = '0' and ER_WR = '0')
       then                             -- It takes 2 IDLE removes for NEARLY_FULL to go low
         WR_ENABLE <= '0';
       else
         WR_ENABLE <= WR_EN;
       end if;
     end if;
   end process GEN_WR_ENABLE;

-- purpose: Create the FIFO write address pointer.
-- type   : sequential
   GEN_WR_ADDR: process (CLK_WR)
   begin
     if CLK_WR'event and CLK_WR = '1' then
       if WR_RESET = '1' then
         NEXT_WR_ADDR <= "100";
         WR_ADDR      <= "011";         -- intialize the pointers to be apart from RD_ADDR
       elsif WR_ENABLE = '1' then
         NEXT_WR_ADDR <= NEXT_WR_ADDR + 1;
         WR_ADDR      <= NEXT_WR_ADDR;
       end if;
     end if;
   end process GEN_WR_ADDR;


   ADDR <= WR_ADDR(2) & WR_ADDR(1) & WR_ADDR(0);
   DPR_ADDR <= RD_ADDR(2) & RD_ADDR(1) & RD_ADDR(0);

   MEM_ACCESS: process
   begin
     wait until (CLK_WR'event and CLK_WR = '1');
     if (WR_ENABLE = '1') THEN
       mem(to_integer(unsigned(ADDR))) <= RAM_IN(10 downto 0);
     end if;
   end process MEM_ACCESS;

   RAM_IN  <= ER_WR_REG & EN_WR_REG & D_WR_REG(D_WIDTH-1 downto 0);

-------------------------------------------------------------------------------
-- FIFO READ LOGIC:
-------------------------------------------------------------------------------



-- purpose: Register the FIFO outputs.
-- type   : sequential
   DRIVE_NEW_GMII: process (CLK_RD)
   begin
     if CLK_RD'event and CLK_RD = '1' then
       if RD_ENABLE = '1' then
         RAM_OUT <= mem(to_integer(unsigned(DPR_ADDR)));
       end if;
     end if;
   end process DRIVE_NEW_GMII;

   D_FIFO_REG  <= RAM_OUT(8 downto 0);
   EN_FIFO_REG <= RAM_OUT(9);
   ER_FIFO_REG <= RAM_OUT(10);

-- purpose: Create the FIFO read enable.
-- type   : sequential
   GEN_RD_ENABLE: process (CLK_RD)
   begin
     if CLK_RD'event and CLK_RD = '1' then
       if RD_RESET = '1' then
         RD_ENABLE <= '0';
       elsif EN_FIFO_REG = '0' and ER_FIFO_REG = '0' and NEARLY_EMPTY = '1' and RD_ADV = '1'
       then                               -- It takes 2 IDLE inserts for NEARLY_EMPTY to go low
         RD_ENABLE <= '0';
       else
         RD_ENABLE <= RD_ADV;
       end if;
     end if;
   end process GEN_RD_ENABLE;

-- purpose: Create the FIFO read address pointer.
--          Since the buffer is only 6 deep, special care is taken to wrap
--          pointer around 0 when it hits 5.
-- type   : sequential

   GEN_RD_ADDR: process (CLK_RD)
   begin
     if CLK_RD'event and CLK_RD = '1' then
       if RD_RESET = '1' then
         NEXT_RD_ADDR <= "001";
         RD_ADDR      <= "000";                 -- intialize the pointers to be apart from WR_ADDR
       elsif RD_ENABLE = '1' then
         NEXT_RD_ADDR <= NEXT_RD_ADDR + 1;
         RD_ADDR      <= NEXT_RD_ADDR;
       end if;
     end if;
   end process GEN_RD_ADDR;


-- purpose: Route GMII outputs, now synchronous to CLK_RD.
-- type   : routing
   D_RD   <= D_FIFO_REG;
   EN_RD <= EN_FIFO_REG;
   ER_RD <= ER_FIFO_REG;



-------------------------------------------------------------------------------
-- CREATE NEARLY_FULL THRESHOLD IN WRITE CLOCK DOMAIN.
-------------------------------------------------------------------------------

-- Please refer to Xilinx Application Note 131 for a complete description of this logic.



-- purpose: Convert Binary Read Pointer to Gray Code.
-- type   : sequential
   RD_ADDRGRAY_BITS: process (CLK_RD)
   begin
     if CLK_RD'event and CLK_RD = '1' then
       if RD_RESET = '1' then
         RD_ADDRGRAY    <= (others => '0');
       elsif RD_ENABLE = '1' then
         RD_ADDRGRAY(2) <= NEXT_RD_ADDR(2);
         RD_ADDRGRAY(1) <= NEXT_RD_ADDR(2) xor NEXT_RD_ADDR(1);
         RD_ADDRGRAY(0) <= NEXT_RD_ADDR(1) xor NEXT_RD_ADDR(0);
       end if;
     end if;
end process RD_ADDRGRAY_BITS;



-- purpose: Register on CLK_WR.  By reclocking the gray code, the worst case senario is that
--          the reclocked value is only in error by -1, since only 1 bit at a time changes
--          between gray code increments.
-- type   : sequential
   RECLOCK_RD_ADDRGRAY: process (CLK_WR)
   begin
     if CLK_WR'event and CLK_WR = '1' then
       if WR_RESET = '1' then
         RAG_WRITESYNC <= (others => '0');
       else
         RAG_WRITESYNC <= RD_ADDRGRAY;
       end if;
     end if;
   end process RECLOCK_RD_ADDRGRAY;



-- purpose: Convert Gray Code read address back to binary.  This has crossed clock domains
--          from CLK_RD to CLK_WR.
-- type   : combinatorial

   RD_ADDRBIN(2) <= RAG_WRITESYNC(2);
   RD_ADDRBIN(1) <= RAG_WRITESYNC(2) xor RAG_WRITESYNC(1);
   RD_ADDRBIN(0) <= RAG_WRITESYNC(2) xor RAG_WRITESYNC(1) xor RAG_WRITESYNC(0);


-- purpose: Determine the occupancy of the FIFO.
--
-- type   : sequential
   GEN_WR_OCCUPANCY: process (WR_ADDR, RD_ADDRBIN)
   begin
     WR_OCCUPANCY <= WR_ADDR - RD_ADDRBIN;
   end process GEN_WR_OCCUPANCY;


-- purpose: Set NEARLY_FULL flag if FIFO occupancy is greater than UPPER_THRESHOLD.
-- In simulation, when RX_CLK and TX_CLK are out of phase, it is possible for WR_
-- OCCUPANCY to be 0 and RD_OCCUPANCY to be 7.  In these cases, NEARLY_FULL
-- needs to be high to pull the RD/WR address apart.
-- type   : combinatorial
   GEN_NEARLY_FULL : process (WR_OCCUPANCY)
   begin
     if ((WR_OCCUPANCY >= UPPER_THRESHOLD))
     then
       NEARLY_FULL <= '1';
     else
       NEARLY_FULL <= '0';
     end if;
   end process GEN_NEARLY_FULL;

-------------------------------------------------------------------------------
-- CREATE NEARLY_EMPTY THRESHOLD IN READ CLOCK DOMAIN.
-------------------------------------------------------------------------------

-- Please refer to Xilinx Application Note 131 for a complete description of this logic.



-- purpose: Convert Binary Write Pointer to Gray Code.
-- type   : sequential
   WR_ADDRGRAY_BITS: process (CLK_WR)
   begin
     if CLK_WR'event and CLK_WR = '1' then
       if WR_RESET = '1' then
         WR_ADDRGRAY    <= "010"; --(others => '0');
       elsif WR_ENABLE = '1' then
         WR_ADDRGRAY(2) <= NEXT_WR_ADDR(2);
         WR_ADDRGRAY(1) <= NEXT_WR_ADDR(2) xor NEXT_WR_ADDR(1);
         WR_ADDRGRAY(0) <= NEXT_WR_ADDR(1) xor NEXT_WR_ADDR(0);
       end if;
     end if;
   end process WR_ADDRGRAY_BITS;



-- purpose: Register on CLK_RD.  By reclocking the gray code, the worst case senario is that
--          the reclocked value is only in error by -1, since only 1 bit at a time changes
--          between gray code increments.
-- type   : sequential
   RECLOCK_WR_ADDRGRAY: process (CLK_RD)
   begin
     if CLK_RD'event and CLK_RD = '1' then
       if RD_RESET = '1' then
         WAG_READSYNC <= "010"; --(others => '0');
       else
         WAG_READSYNC <= WR_ADDRGRAY;
       end if;
     end if;
   end process RECLOCK_WR_ADDRGRAY;


-- purpose: Convert Gray Code read address back to binary.  This has crossed clock domains
--          from CLK_WR to CLK_RD.
-- type   : combinatorial

   WR_ADDRBIN(2) <= WAG_READSYNC(2);
   WR_ADDRBIN(1) <= WAG_READSYNC(2) xor WAG_READSYNC(1);
   WR_ADDRBIN(0) <= WAG_READSYNC(2) xor WAG_READSYNC(1) xor WAG_READSYNC(0);

-- purpose: Determine the occupancy of the FIFO.
--
-- type   : sequential
   GEN_RD_OCCUPANCY: process (WR_ADDRBIN, RD_ADDR)
   begin
     RD_OCCUPANCY <= WR_ADDRBIN - RD_ADDR;
   end process GEN_RD_OCCUPANCY;


-- purpose: Set NEARLY_EMPTY flag if FIFO occupancy is less than LOWER_THRESHOLD.
-- type   : combinatorial
   GEN_NEARLY_EMPTY : process (RD_OCCUPANCY)
   begin
     if (RD_OCCUPANCY < LOWER_THRESHOLD)
     then
       NEARLY_EMPTY <= '1';
     else
       NEARLY_EMPTY <= '0';
     end if;
   end process GEN_NEARLY_EMPTY;


end RTL;
