library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


library unisim;
use unisim.vcomponents.all;

library axi_dma_v6_00_a;
use axi_dma_v6_00_a.axi_dma_pkg.all;


 
entity axi_dma_cmd_split is
     generic (
             C_ADDR_WIDTH  : integer range 32 to 64    := 32; 
             C_INCLUDE_S2MM : integer range 0 to 1     := 0 
             );
     port (
           clock : in std_logic;
           clock_sec : in std_logic;
           aresetn : in std_logic;

   -- command coming from _MNGR 
           s_axis_cmd_tvalid : in std_logic;
           s_axis_cmd_tready : out std_logic;
           s_axis_cmd_tdata  : in std_logic_vector ((2*C_ADDR_WIDTH+CMD_BASE_WIDTH+46)-1 downto 0);

   -- split command to DM
           s_axis_cmd_tvalid_s : out std_logic;
           s_axis_cmd_tready_s : in std_logic;
           s_axis_cmd_tdata_s  : out std_logic_vector ((2*C_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);
   -- Tvalid from Datamover
           tvalid_from_datamover    : in std_logic;
           tvalid_unsplit           : out std_logic;

   -- Tlast of stream data from Datamover
           tlast_stream_data        : in std_logic;
           tready_stream_data        : in std_logic;
           tlast_unsplit            : out std_logic;  
           tlast_unsplit_user       : out std_logic  

          );
end entity axi_dma_cmd_split;

architecture implementation of axi_dma_cmd_split is

type SPLIT_MM2S_STATE_TYPE      is (
                                IDLE,
                                SEND,
                                SPLIT
                                );

signal mm2s_cs                  : SPLIT_MM2S_STATE_TYPE;
signal mm2s_ns                  : SPLIT_MM2S_STATE_TYPE;

signal mm2s_cmd    : std_logic_vector (2*C_ADDR_WIDTH+CMD_BASE_WIDTH+46-1 downto 0);
signal command_ns    : std_logic_vector (2*C_ADDR_WIDTH+CMD_BASE_WIDTH-1 downto 0);
signal command    : std_logic_vector (2*C_ADDR_WIDTH+CMD_BASE_WIDTH-1 downto 0);

signal cache_info  : std_logic_vector (31 downto 0);
signal vsize_data  : std_logic_vector (22 downto 0);
signal vsize_data_int  : std_logic_vector (22 downto 0);
signal vsize       : std_logic_vector (22 downto 0);
signal counter     : std_logic_vector (22 downto 0);
signal counter_tlast     : std_logic_vector (22 downto 0);
signal split_cmd   : std_logic_vector (31 downto 0);
signal stride_data : std_logic_vector (22 downto 0);
signal vsize_over   : std_logic;

signal cmd_proc_cdc_from    : std_logic;
signal cmd_proc_cdc_to    : std_logic;
signal cmd_proc_cdc    : std_logic;
signal cmd_proc_ns    : std_logic;

signal cmd_out    : std_logic;
signal cmd_out_ns    : std_logic;

signal split_out    : std_logic;
signal split_out_ns    : std_logic;

signal command_valid : std_logic;
signal command_valid_ns : std_logic;
signal command_ready : std_logic;
signal reset_lock : std_logic;
signal reset_lock_tlast : std_logic;


signal tvalid_unsplit_int : std_logic;
signal tlast_stream_data_int : std_logic;

signal ready_for_next_cmd : std_logic;
signal ready_for_next_cmd_tlast : std_logic;
signal ready_for_next_cmd_tlast_cdc_from : std_logic;
signal ready_for_next_cmd_tlast_cdc_to : std_logic;
signal ready_for_next_cmd_tlast_cdc : std_logic;

signal tmp1, tmp2, tmp3, tmp4 : std_logic;
signal tlast_int : std_logic;

signal eof_bit : std_logic;
signal eof_bit_cdc_from : std_logic;
signal eof_bit_cdc_to : std_logic;
signal eof_bit_cdc : std_logic;
signal eof_set : std_logic;
signal over_ns, over : std_logic;

signal cmd_in : std_logic;
begin

s_axis_cmd_tvalid_s <= command_valid;
command_ready <= s_axis_cmd_tready_s;
s_axis_cmd_tdata_s <= command;


REGISTER_STATE_MM2S : process(clock)
    begin
        if(clock'EVENT and clock = '1')then
            if(aresetn = '0')then
                mm2s_cs     <= IDLE;
                cmd_proc_cdc_from <= '0';
                cmd_out <= '0';
                command <= (others => '0');
                command_valid <= '0';
                split_out <= '0';
                over <= '0';
            else
                mm2s_cs     <= mm2s_ns;
                cmd_proc_cdc_from <= cmd_proc_ns;
                cmd_out <= cmd_out_ns;
                command <= command_ns;
                command_valid <= command_valid_ns;
                split_out <= split_out_ns;
                over <= over_ns;
            end if;
        end if;
    end process REGISTER_STATE_MM2S;


-- grab the MM2S command coming from MM2S_mngr
REGISTER_MM2S_CMD : process(clock)
    begin
        if(clock'EVENT and clock = '1')then
            if(aresetn = '0')then
                mm2s_cmd <= (others => '0');
                s_axis_cmd_tready <= '0';
                cache_info <= (others => '0');
                vsize_data <= (others => '0');
                vsize_data_int <= (others => '0');
                stride_data <= (others => '0');
                eof_bit_cdc_from <= '0';
                cmd_in <= '0';
            elsif (s_axis_cmd_tvalid = '1' and ready_for_next_cmd = '1' and cmd_proc_cdc_from = '0' and ready_for_next_cmd_tlast_cdc = '1') then  -- when there is no processing being done, means it is ready to accept
                mm2s_cmd     <= s_axis_cmd_tdata;
                s_axis_cmd_tready <= '1';
                cache_info <= s_axis_cmd_tdata (149 downto 118);
                vsize_data <= s_axis_cmd_tdata (117 downto 95);
                vsize_data_int <= s_axis_cmd_tdata (117 downto 95) - '1';
                stride_data <= s_axis_cmd_tdata (94 downto 72);
                eof_bit_cdc_from <= s_axis_cmd_tdata (30);
                cmd_in <= '1';
            else
                mm2s_cmd     <= mm2s_cmd; --split_cmd;
                vsize_data   <= vsize_data;
                vsize_data_int   <= vsize_data_int;
                stride_data   <= stride_data;
                cache_info <= cache_info;
                s_axis_cmd_tready <= '0';
                eof_bit_cdc_from <= eof_bit_cdc_from;
                cmd_in <= '0';
            end if;
        end if;
    end process REGISTER_MM2S_CMD;


REGISTER_DECR_VSIZE : process(clock)
    begin
        if(clock'EVENT and clock = '1')then
            if(aresetn = '0')then
                vsize <= "00000000000000000000000";
            elsif (command_valid = '1' and command_ready = '1' and (vsize < vsize_data_int)) then  -- sending a cmd out to DM
                vsize <= vsize + '1';
            elsif (cmd_proc_cdc_from = '0') then  -- idle or when all cmd are sent to DM
                vsize <= "00000000000000000000000";
            else 
                vsize <= vsize;    
            end if;
        end if;
    end process REGISTER_DECR_VSIZE;

    vsize_over <= '1' when (vsize = vsize_data_int) else '0';
  --  eof_set <= eof_bit when (vsize = vsize_data_int) else '0';


 REGISTER_SPLIT : process(clock)
     begin
         if(clock'EVENT and clock = '1')then
             if(aresetn = '0')then
                 split_cmd <= (others => '0');
             elsif (s_axis_cmd_tvalid = '1' and cmd_proc_cdc_from = '0' and ready_for_next_cmd = '1' and ready_for_next_cmd_tlast_cdc = '1') then
                 split_cmd <= s_axis_cmd_tdata (63 downto 32);          -- capture the ba when a new cmd arrives
             elsif (split_out = '1') then  -- add stride to previous ba
                 split_cmd <= split_cmd + stride_data;
             else 
                 split_cmd <= split_cmd;
             end if;

         end if;
     end process REGISTER_SPLIT;



MM2S_MACHINE : process(mm2s_cs,
                       s_axis_cmd_tvalid,
                       cmd_proc_cdc_from, 
                       vsize_over, command_ready
                       )
    begin

        -- Default signal assignment
        case mm2s_cs is

            -------------------------------------------------------------------
            when IDLE =>
                       command_ns <=  cache_info & mm2s_cmd (72 downto 65) & split_cmd & mm2s_cmd (31) & eof_set & mm2s_cmd (29 downto 0); -- buf length remains the same
                  --     command_ns <=  cache_info & mm2s_cmd (72 downto 65) & split_cmd & mm2s_cmd (31 downto 0); -- buf length remains the same
                   if (cmd_in = '1' and cmd_proc_cdc_from = '0') then
                       cmd_proc_ns <= '1';      -- new command has come in and i need to start processing
                       mm2s_ns <= SEND;
                       over_ns <= '0'; 
                       split_out_ns <= '1'; 
                       command_valid_ns <= '1';
                   else 
                       mm2s_ns <= IDLE; 
                       over_ns <= '0'; 
                       cmd_proc_ns <= '0';      -- ready to receive new command 
                       split_out_ns <= '0'; 
                       command_valid_ns <= '0';
                   end if;

            -------------------------------------------------------------------
            when SEND =>
                       cmd_out_ns <= '1';
                       command_ns <=  command;

                       if (vsize_over = '1' and command_ready = '1') then
                         mm2s_ns <= IDLE; 
                         cmd_proc_ns <= '1';
                         command_valid_ns <= '0';
                         split_out_ns <= '0'; 
                         over_ns <= '1'; 
                       elsif  (command_ready = '0') then --(command_valid = '1' and command_ready = '0') then
                         mm2s_ns <= SEND;
                         command_valid_ns <= '1';
                         cmd_proc_ns <= '1'; 
                         split_out_ns <= '0'; 
                         over_ns <= '0';
                       else 
                         mm2s_ns <= SPLIT;
                         command_valid_ns <= '0';
                         cmd_proc_ns <= '1';
                         over_ns <= '0'; 
                         split_out_ns <= '0'; 
                       end if;
                  
            -------------------------------------------------------------------
            when SPLIT =>
                         cmd_proc_ns <= '1';
                         mm2s_ns <= SEND; 
                         command_ns <=  cache_info & mm2s_cmd (72 downto 65) & split_cmd & mm2s_cmd (31) & eof_set & mm2s_cmd (29 downto 0); -- buf length remains the same
        --                 command_ns <=  cache_info & mm2s_cmd (72 downto 65) & split_cmd & mm2s_cmd (31 downto 0); -- buf length remains the same
                         cmd_out_ns <= '0';
                         split_out_ns <= '1'; 
                         command_valid_ns <= '1';

            -------------------------------------------------------------------
            when others =>
                mm2s_ns <= IDLE;

        end case;
    end process MM2S_MACHINE;


SWALLOW_TVALID : process(clock)
    begin
        if(clock'EVENT and clock = '1')then
            if(aresetn = '0')then
                counter <= (others => '0');
                tvalid_unsplit_int <= '0';
                reset_lock <= '1';
                ready_for_next_cmd <= '0';
            elsif (vsize_data_int = "00000000000000000000000") then
                tvalid_unsplit_int <= '0';
                ready_for_next_cmd <= '1';
                reset_lock <= '0';
            elsif ((tvalid_from_datamover = '1') and (counter < vsize_data_int)) then
                counter <= counter + '1';
                tvalid_unsplit_int <= '0';
                ready_for_next_cmd <= '0';
                reset_lock <= '0';
            elsif ((counter = vsize_data_int) and (reset_lock = '0') and (tvalid_from_datamover = '1')) then
                counter <= (others => '0');
                tvalid_unsplit_int <= '1';
                ready_for_next_cmd <= '1';
            else
                counter <= counter;
                tvalid_unsplit_int <= '0';
                if (cmd_proc_cdc_from = '1') then
                   ready_for_next_cmd <= '0';
                else
                   ready_for_next_cmd <= ready_for_next_cmd;
                end if;
            end if;
        end if;
    end process SWALLOW_TVALID;

                tvalid_unsplit <= tvalid_from_datamover when (counter = vsize_data_int) else '0'; --tvalid_unsplit_int;


SWALLOW_TLAST_GEN : if C_INCLUDE_S2MM = 0 generate
begin


    eof_set <= '1'; --eof_bit when (vsize = vsize_data_int) else '0';

CDC_CMD_PROC : process (clock_sec)
   begin
        if (clock_sec'EVENT and clock_sec = '1') then
           if (aresetn = '0') then
              cmd_proc_cdc_to <= '0';
              cmd_proc_cdc <= '0';
              eof_bit_cdc_to <= '0';
              eof_bit_cdc <= '0';
              ready_for_next_cmd_tlast_cdc_from <= '0';
           else
              cmd_proc_cdc_to <= cmd_proc_cdc_from;
              cmd_proc_cdc <= cmd_proc_cdc_to;
              eof_bit_cdc_to <= eof_bit_cdc_from;
              eof_bit_cdc <= eof_bit_cdc_to;
              ready_for_next_cmd_tlast_cdc_from <= ready_for_next_cmd_tlast;
           end if;
        end if;
end process CDC_CMD_PROC;


CDC_CMDTLAST_PROC : process (clock)
   begin
        if (clock'EVENT and clock = '1') then
           if (aresetn = '0') then
              ready_for_next_cmd_tlast_cdc_to <= '0';
              ready_for_next_cmd_tlast_cdc <= '0';
           else
              ready_for_next_cmd_tlast_cdc_to <= ready_for_next_cmd_tlast_cdc_from;
              ready_for_next_cmd_tlast_cdc <= ready_for_next_cmd_tlast_cdc_to;
           end if;
         end if;  
end process CDC_CMDTLAST_PROC;

SWALLOW_TLAST : process(clock_sec)
    begin
        if(clock_sec'EVENT and clock_sec = '1')then
            if(aresetn = '0')then
                counter_tlast <= (others => '0');
                tlast_stream_data_int <= '0';
                reset_lock_tlast <= '1';
                ready_for_next_cmd_tlast <= '0';
            elsif (vsize_data_int = "00000000000000000000000") then
                tlast_stream_data_int <= '0';
                ready_for_next_cmd_tlast <= '1';
                reset_lock_tlast <= '0';
            elsif ((tlast_stream_data = '1' and tready_stream_data = '1') and (counter_tlast < vsize_data_int)) then
                counter_tlast <= counter_tlast + '1';
                tlast_stream_data_int <= '0';
                ready_for_next_cmd_tlast <= '0';
                reset_lock_tlast <= '0';
            elsif ((counter_tlast = vsize_data_int) and (reset_lock_tlast = '0') and (tlast_stream_data = '1' and tready_stream_data = '1')) then
                counter_tlast <= (others => '0');
                tlast_stream_data_int <= '1';
                ready_for_next_cmd_tlast <= '1';
            else
                counter_tlast <= counter_tlast;
                tlast_stream_data_int <= '0';
                if (cmd_proc_cdc = '1') then
                   ready_for_next_cmd_tlast <= '0';
                else
                   ready_for_next_cmd_tlast <= ready_for_next_cmd_tlast;
                end if;
            end if;
        end if;
    end process SWALLOW_TLAST;
                
          tlast_unsplit <= tlast_stream_data when (counter_tlast = vsize_data_int and eof_bit_cdc = '1') else '0';
          tlast_unsplit_user <= tlast_stream_data when (counter_tlast = vsize_data_int) else '0';
       --   tlast_unsplit <= tlast_stream_data; -- when (counter_tlast = vsize_data_int) else '0';


end generate SWALLOW_TLAST_GEN;

SWALLOW_TLAST_GEN_S2MM : if C_INCLUDE_S2MM = 1 generate
begin

    eof_set <= eof_bit_cdc_from;
ready_for_next_cmd_tlast_cdc <= '1';

end generate SWALLOW_TLAST_GEN_S2MM;


end implementation;
