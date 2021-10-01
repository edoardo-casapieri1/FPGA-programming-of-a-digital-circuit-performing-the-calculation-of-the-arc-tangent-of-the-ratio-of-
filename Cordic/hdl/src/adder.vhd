library IEEE;
use IEEE.std_logic_1164.all;

entity adder is
    generic ( Nbit : positive := 18);
    port (
   		add_in_1  : in std_logic_vector(Nbit-1 downto 0);
   		add_in_2  : in std_logic_vector(Nbit-1 downto 0);
   		add_out   : out std_logic_vector(Nbit-1 downto 0);
   		add_clk   : in std_logic;
   		add_ready : in std_logic;
   		add_rst   : in std_logic;
   		add_check : in std_logic
    );
end adder;

architecture rtl of adder is

	component RippleCarryAdder is
    generic ( Nbit : positive := 18);
    port (
        in_rca_1      : in std_logic_vector(Nbit-1 downto 0) ;
       	in_rca_2      : in std_logic_vector(Nbit-1 downto 0) ;
        rca_carry_in  : in std_logic ;
        rca_sum       : out std_logic_vector(Nbit-1 downto 0) ;
        rca_carry_out : out std_logic 
    );
	end component RippleCarryAdder;

	component DFF_N is
	    port(
	        clk    : in std_logic ;
	        resetn : in std_logic ;
	        d      : in std_logic_vector (Nbit-1 downto 0) ;
	        q      : out std_logic_vector (Nbit-1 downto 0) ;
	        check  : in std_logic
	    );
	end component DFF_N;

	-- segnale prima del ripple carry adder 
	signal before_rca: std_logic_vector(Nbit-1 downto 0);
	-- segnale dopo il ripple carry adder
	signal after_rca: std_logic_vector(Nbit-1 downto 0); 
	-- segnale dopo il flip flop 
	signal after_dff : std_logic_vector(Nbit-1 downto 0);
	
	begin
	
	    DFF_ADDER: DFF_N 
	    port map(add_clk, add_rst, after_rca, after_dff, add_check);

	    RCA: RippleCarryAdder port map(before_rca,add_in_2,'0',after_rca,open);

		MULTIPLEXER: process(add_in_1, after_dff, add_ready)
		begin
			if (add_ready = '1') then 
				before_rca <= add_in_1;
			else
				before_rca <= after_dff;
			end if; 
		end process MULTIPLEXER;


		add_out <= after_dff;

end rtl;