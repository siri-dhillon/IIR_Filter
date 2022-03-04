library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity iir is
        generic(
            bit_width : integer := 24;
            width_internal : integer := 32;
            a0 : in integer;
            a1 : in integer;
            a2 : in integer;
            b1 : in integer;
            b2 : in integer
    );
        port (
                clk : in std_logic;
                rst : in std_logic;
                valid : in std_logic;
                x : in std_logic_vector(bit_width-1 downto 0);
                y : out std_logic_vector(bit_width-1 downto 0);
                valid_out : out std_logic
     );
end iir;

architecture rtl of ent is

    signal y_out : std_logic_vector(bit_width-1 downto 0);
    signal x_in : std_logic_vector(bit_width-1 downto 0);
    signal x_z1 : std_logic_vector(bit_width-1 downto 0);
    signal x_z2 : std_logic_vector(bit_width-1 downto 0);
    signal y_z1 : std_logic_vector(bit_width-1 downto 0);
    signal y_z2 : std_logic_vector(bit_width-1 downto 0);

begin

    x_in <= x;
    y <= y_out; 

    -- getting values for x_z1 and x_z2 delays from the registers
    X_Delayer : entity work.delayer
    port map(
        x => x_in,
		clk_d => clk,				
		rst_d => rst,
        z1 => x_z1,
		z2 => x_z2
        
        );

    -- getting values for y_z1 and y_z2 delays from the registers
    X_Delayer : entity work.delayer
    port map(
        x => y_out,
		clk_d => clk,				
		rst_d => rst,
        z1 => y_z1,
		z2 => y_z2
        
        );

    -- multiplications 
    -- 

    


end architecture;

