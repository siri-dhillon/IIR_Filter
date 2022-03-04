library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity i2s_audio_interface_testbench is
end i2s_audio_interface_testbench;

architecture sim of i2s_audio_interface_testbench is

    constant FPGA_clk_hz : integer := 100e6;
    constant FPGA_clk_period : time := 1 sec / FPGA_clk_hz;

    constant B_clk_hz : integer := 3072e3;
    constant B_clk_period : time := 1 sec / B_clk_hz;

    constant LR_clk_hz : integer := 48e3;
    constant LR_clk_period : time := 1 sec / LR_clk_hz;

    signal FPGA_clk : std_logic := '1';
    signal B_clk : std_logic := '1';
    signal LR_clk : std_logic := '1';

    signal rst : std_logic := '1';

    signal s_data_out:  std_logic;


    constant s_data_in: std_logic_vector(31 downto 0) := "00000000101010101010101010101010";

    --connecting signals
    signal audio_valid:  std_logic; 
    signal audio_r:  std_logic_vector(23 downto 0); 
    signal audio_l:  std_logic_vector(23 downto 0);

    signal b_clk_counter: integer:= 0;
    signal s_data_1b: std_logic;

begin

    FPGA_clk <= not FPGA_clk after FPGA_clk_period / 2;
    B_clk <= not B_clk after B_clk_period / 2;
    LR_clk <= not LR_clk after LR_clk_period / 2;

    DUT : entity work.i2s_audio_interface
    port map (
        fpga_clk => FPGA_clk,
        rst => rst,
        b_clk => B_clk,
        lr_clk => LR_clk,

        sdata_in => s_data_1b,       

        audio_valid_adau =>  audio_valid,
        audio_r_adau => audio_r,
        audio_l_adau => audio_l,

        sdata_out => s_data_out,
        
        audio_valid_pl => audio_valid,
        audio_r_pl => audio_r,
        audio_l_pl => audio_l
    );

    SEQUENCER_PROC : process
    begin
        --wait for FPGA_clk_period * 2;

        rst <= '1';

        wait for FPGA_clk_period * 2;
        rst <= '0';

        wait for FPGA_clk_period * 100000;
        rst <= '1';

    end process;

    
    S_DATA_PROC : process (B_clk, LR_clk)
    begin
        --rst <= '0';
            if (rising_edge(LR_clk)) then
                    b_clk_counter <= 0;
            elsif (rising_edge(B_clk)) then
                if (b_clk_counter < 32) then
                    s_data_1b <= s_data_in(31 - b_clk_counter);
                    b_clk_counter <= b_clk_counter + 1;
                else
                    b_clk_counter <= 0;
                end if;
            end if;
    end process;








end architecture;