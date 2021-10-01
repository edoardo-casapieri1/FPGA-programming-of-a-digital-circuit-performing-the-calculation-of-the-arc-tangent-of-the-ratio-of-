library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity inv is 
	generic ( Nbit : positive := 18);
	port(
			xin  : in std_logic;
			yin  : in std_logic_vector(Nbit-1 downto 0);
			yout : out std_logic_vector(Nbit-1 downto 0)	
	);
end inv;

architecture rtl of inv is
begin
	inv:process(xin,yin)
	begin
		if(xin = '1') then
			yout <= std_logic_vector (unsigned(not yin) + 1);
		else
			yout <= yin;
		end if;
	end process inv; 
end rtl;