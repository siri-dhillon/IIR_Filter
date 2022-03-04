library IEEE;
use IEEE.std_logic_1164.all;

entity register is   
		generic(N_bit : integer); 
		port(
			d       : in std_logic_vector(N_bit - 1 downto 0);   
			q       : out std_logic_vector(N_bit - 1 downto 0); 
			clk     : in std_logic;   
			resetn : in std_logic    
		);
end register;

architecture rtl of register is

begin

	parallel_dff_proc : process(clk, resetn) 	
	begin
		if(resetn = '0') then 					
			q <= (others => '0'); 				

		elsif (rising_edge(clk)) then 			
			q <= d; 					
		end if;
	end process;

end rtl;