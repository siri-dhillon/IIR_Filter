library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier32 is
    port (
        A: in STD_LOGIC_VECTOR (31 downto 0);
	    B: in STD_LOGIC_VECTOR (31 downto 0);
	    S: out STD_LOGIC_VECTOR (31 downto 0)
    );
end multiplier32;

architecture rtl of multiplier32 is

    signal carry : STD_LOGIC_VECTOR (31 downto 0); 
begin


    GEN : for i in 0 to  generate
		FIRST: if i = 0 generate 	
			ADD_32 : entity work.adder32 port map (
                a 	 => A(i),
                b 	 => B(i),	
                cin  => carry(i),	
                cout => carry(i+1), 	
                s 	 => S(i)

                
            );
		end generate FIRST;
	end generate GEN;    

end architecture;