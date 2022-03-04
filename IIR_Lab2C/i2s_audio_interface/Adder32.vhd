library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder32 is
    port (
        A: in STD_LOGIC_VECTOR (31 downto 0);
	    B: in STD_LOGIC_VECTOR (31 downto 0);
	    S: out STD_LOGIC_VECTOR (31 downto 0)
    );
end adder32;

architecture rtl of adder32 is

    signal carry : STD_LOGIC_VECTOR (31 downto 0); 
begin

    
    ADD_0 : entity work.fulladder
    port map(
        a 	 => A(0),
		b 	 => B(0),	
		cin  => '0',	
		cout => carry(1), 	
		s 	 => S(0)
        );

    GEN : for i in 0 to 31 generate
		FIRST: if i = 0 generate 	
			ADD_32 : entity work.fulladder port map (
                a 	 => A(i),
                b 	 => B(i),	
                cin  => carry(i),	
                cout => carry(i+1), 	
                s 	 => S(i)

                
            );
		end generate FIRST;
	end generate GEN;    

end architecture;