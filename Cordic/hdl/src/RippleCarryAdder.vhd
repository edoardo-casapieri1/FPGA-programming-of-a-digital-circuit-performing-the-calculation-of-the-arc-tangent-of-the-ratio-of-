library IEEE;
use IEEE.std_logic_1164.all;

entity RippleCarryAdder is
    generic ( Nbit : positive := 18);
    port (
        in_rca_1      : in std_logic_vector(Nbit-1 downto 0) ;
       	in_rca_2      : in std_logic_vector(Nbit-1 downto 0) ;
        rca_carry_in  : in std_logic ;
        rca_sum       : out std_logic_vector(Nbit-1 downto 0) ;
        rca_carry_out : out std_logic 
    );
end RippleCarryAdder;

architecture rtl of RippleCarryAdder is
    component FullAdder is
	    port(
	    	in_1 	  : in std_logic;
	    	in_2      : in std_logic;
	    	carry_in  : in std_logic;
	    	sum       : out std_logic;
	    	carry_out : out std_logic
	    );
    end component FullAdder;

    signal cout_s : std_logic_vector (Nbit-1 downto 0)  ;

begin
    -- generazione di N istanze del FullAdder
    GEN: for i in 0 to Nbit-1 generate
        FIRST: if i = 0 generate
            FA1: FullAdder port map (in_rca_1(i), in_rca_2(i), rca_carry_in, rca_sum(i), cout_s(i));
            end generate FIRST;

        INTERNAL: if i > 0 and i < (Nbit-1) generate
            FAI: FullAdder port map(in_rca_1(i), in_rca_2(i), cout_s(i-1), rca_sum(i), cout_s(i));
            end generate INTERNAL;

        LAST: if i = (Nbit-1) generate
            FAN: FullAdder port map(in_rca_1(i), in_rca_2(i), cout_s(i-1), rca_sum(i), rca_carry_out);
            end generate LAST;

    end generate GEN;	

end rtl;