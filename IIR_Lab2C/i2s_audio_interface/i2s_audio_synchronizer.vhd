library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_audio_syncronizer is
    port (
        fpga_clk : in std_logic;
        rst : in std_logic;
        b_clk: in std_logic;
        lr_clk: in std_logic;
        sdata_in: in std_logic;
        sdata_out: out std_logic; --metastable, output from synchronizer
        b_clk_out: out std_logic;
        lr_clk_out: out std_logic;
        bclk_is_rising_edge: out std_logic;
        bclk_is_falling_edge: out std_logic;
        lrclk_is_rising_edge: out std_logic;
        lrclk_is_falling_edge: out std_logic
    );
end i2s_audio_syncronizer;

architecture rtl of i2s_audio_syncronizer is

    signal b_clk_sig: std_logic; -- bclk synchronizer 
    signal b_clk_sig_past: std_logic; 


    signal lr_clk_sig: std_logic; -- lrclk synchronizer ??
    signal lr_clk_sig_past: std_logic;

    signal sdata_sig: std_logic; --stablizied

    signal b_sync_counter: integer := 0;
    signal lr_sync_counter: integer := 0;
    signal sdata_sync_counter: integer := 0;

    signal bclk_rising_edge: std_logic := '0'; 
    signal bclk_falling_edge: std_logic:= '0'; 
    signal lrclk_rising_edge: std_logic := '0'; 
    signal lrclk_falling_edge: std_logic := '0'; 

    -- function
    function is_Rising_Edge(
        present: std_logic;
        past: std_logic
    ) return std_logic is 
    variable rising: std_logic;
     begin
        if present = past then
            rising := '0';
        elsif present = '1' then
            rising := '1';
        else
            rising := '0';
        end if;
     return rising; 
    end is_Rising_Edge;

    function is_Falling_Edge(
        present: std_logic;
        past: std_logic
    ) return std_logic is 
    variable falling: std_logic;
     begin
        if present = past then
            falling := '0';
        elsif present = '0' then
            falling := '1';
        else
        falling := '0';
        end if;
     return falling; 
    end is_Falling_Edge;
    
begin
    b_synchronizer : process(fpga_clk, b_clk)
    begin
        if rising_edge(fpga_clk) then
            if(rst='1') then 
                b_clk_sig <= '0';
                b_sync_counter <= 0;
            elsif (b_sync_counter = 0) then --initialize FF 1
                b_clk_sig_past <= b_clk_sig;  
                b_clk_sig <= b_clk; 
                b_sync_counter <= b_sync_counter + 1; 
            else --other two FF
                b_clk_sig <= b_clk_sig;
                b_sync_counter <= b_sync_counter + 1;
                if (b_sync_counter = 3) then
                    b_clk_out <= b_clk_sig; 
                    bclk_rising_edge <= is_Rising_Edge(b_clk_sig, b_clk_sig_past); 
                    bclk_falling_edge <= is_Falling_Edge(b_clk_sig, b_clk_sig_past);
                    b_sync_counter <= 0;
                end if;
            end if;
        end if;
    end process;

    bclk_is_rising_edge <= bclk_rising_edge; 
    bclk_is_falling_edge <= bclk_falling_edge;

    lr_synchronizer : process(fpga_clk, lr_clk)
    begin
        if rising_edge(fpga_clk) then
            if(rst='1') then 
                lr_clk_sig <= '0';
                lr_sync_counter <= 0;
            elsif (lr_sync_counter = 0) then --initialize FF 1
                lr_clk_sig_past <= lr_clk_sig;  
                lr_clk_sig <= lr_clk;
                lr_sync_counter <= lr_sync_counter + 1; 
            else --other two FF
                lr_clk_sig <= lr_clk_sig;
                lr_sync_counter <= lr_sync_counter + 1;
                if (lr_sync_counter = 3) then 
                    lr_clk_out <= lr_clk_sig;
                    lrclk_rising_edge <= is_Rising_Edge(lr_clk_sig, lr_clk_sig_past);
                    lrclk_falling_edge <= is_Falling_Edge(lr_clk_sig, lr_clk_sig_past);
                    lr_sync_counter <= 0;
                end if;
            end if;
        end if;
    end process;
    lrclk_is_rising_edge <= lrclk_rising_edge; 
    lrclk_is_falling_edge <= lrclk_falling_edge;


    sdata_syncronizer : process(fpga_clk, bclk_rising_edge, lrclk_rising_edge, lrclk_falling_edge)
    begin
        if rising_edge(fpga_clk) then
            if(rst='1') then 
                sdata_sig <= '0';
                sdata_sync_counter <= 0;
            else
                if (bclk_rising_edge = '1' )  then --right channel
                    if (sdata_sync_counter = 0) then --initialize FF 1
                        sdata_sig <= sdata_in;  
                        sdata_sync_counter <= sdata_sync_counter + 1; 
                    else --other two FF
                        sdata_sig <= sdata_sig;
                        sdata_sync_counter <= sdata_sync_counter + 1;
                        if (sdata_sync_counter = 3) then 
                            sdata_out <= sdata_sig; -- SDATA OUTPUT at the end of each synchronizer cycle
                            sdata_sync_counter <= 0;
                        end if;
                     end if;
                end if;
            end if;
        end if;
    end process;


    
end architecture;