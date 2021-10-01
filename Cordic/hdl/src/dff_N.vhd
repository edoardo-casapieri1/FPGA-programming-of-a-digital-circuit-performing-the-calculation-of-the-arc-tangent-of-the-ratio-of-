library IEEE;
use IEEE.std_logic_1164.all;

entity DFF_N is
    generic( Nbit : positive := 18);
    port(
        clk    : in std_logic ;
        resetn : in std_logic ;
        d      : in std_logic_vector (Nbit-1 downto 0) ;
        q      : out std_logic_vector (Nbit-1 downto 0);
        check  : in std_logic 
    );
end DFF_N;

architecture rtl of DFF_N is
begin
    dff_n: process(resetn, clk,check)
    begin
        if resetn = '0' then
            q <= (others => '0');
        elsif (rising_edge(clk) and check = '1') then
            -- se check = 1 vuol dire che l'algoritmo ancora non è terminato e
            --  dunque si devono svolgere ulteriori iterazioni.
            q <= d;
        end if;
    end process dff_n;
end rtl;
