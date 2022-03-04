library ieee;
use ieee.std_logic_1164.all;

entity delayer is 	
	generic (bit_width : integer); 	
	port (
		x : in std_logic_vector(bit_width - 1 downto 0); 	
		clk_d : in std_logic; 							
		rst_d : in std_logic; 						
		z1 : out std_logic_vector(bit_width - 1 downto 0);
		z2 : out std_logic_vector(bit_width - 1 downto 0) 
	);
end entity delayer;

architecture rtl of delayer is 					
	component register is 							
		generic (N_bit : integer); 						
		port (
			d 	: in std_logic_vector(bit_width - 1 downto 0); 
			q 	: out std_logic_vector(bit_width - 1 downto 0);
			clk : in std_logic;
			resetn: in std_logic
		);
	end component register;

	signal xz1 	: std_logic_vector(bit_width - 1 downto 0); 	
	signal xz2 	: std_logic_vector(bit_width - 1 downto 0); 	

begin
	
	x_z1: register 								
		generic map (N_bit => bit_width) 				
		port map (
			d => x, 								
			q => xz1, 								
			clk => clk_d, 							
			resetn => rst_d 						
		);

	x_z2: register 								
		generic map (N_bit => bit_width) 				
		port map (
			d => xz1, 								
			q => xz2, 								
			clk => clk_d,
			resetn => rst_d
		);
		
	z1 <= xz1;
	z2 <= xz2;
	
end architecture rtl;