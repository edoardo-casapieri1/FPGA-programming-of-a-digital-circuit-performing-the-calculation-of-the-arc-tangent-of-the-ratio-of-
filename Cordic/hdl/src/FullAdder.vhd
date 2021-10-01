library IEEE;
use IEEE.std_logic_1164.all;

entity FullAdder is
    port(
    	in_1 	  : in std_logic;
    	in_2      : in std_logic;
    	carry_in  : in std_logic;
    	sum       : out std_logic;
    	carry_out : out std_logic
    );
end FullAdder;

architecture rtl of FullAdder is
begin
    sum <= in_1 XOR in_2 XOR carry_in;
    carry_out <= (in_1 AND in_2 ) OR (in_2 AND carry_in) OR (in_1 AND carry_in);
end rtl;
