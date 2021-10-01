library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity rom_8x12 is
    port(
        address : in STD_LOGIC_VECTOR(2 downto 0);
        output : out STD_LOGIC_VECTOR(11 downto 0)
        );
end rom_8x12;

architecture rtl of rom_8x12 is      
	signal addr_int : integer range 0 to 7;							  -- I valori sono rappresentati come numeri reali in virgola fissa.
    type rom_t is array (0 to 7) of std_logic_vector (11 downto 0);   -- 6 bit per la parte intera e 6 bit per la parte frazionaria
    constant rom: rom_t :=								              
	(			                   
		"101101000000",      -- 45                         
		"011010100100",    	 -- 26.5625
		"001110000010",      -- 14.03125
		"000111001000",      -- 7.125
		"000011100101",      -- 3.578125
		"000001110011",      -- 1.796875
		"000000111001",      -- 0.890625
		"000000011101"       -- 0.453125
	);    
	begin
	addr_int <= TO_INTEGER(unsigned(address));
    output <= rom(addr_int);
end rtl;