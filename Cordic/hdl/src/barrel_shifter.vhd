library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity barrel_shifter is
    generic (Nbit : INTEGER:=18);
    port(
         input         : in  std_logic_vector (Nbit-1 downto 0);
         shifted_input : out std_logic_vector (Nbit-1 downto 0);
         N_loc         : in  std_logic_vector (2 downto 0)
    );
end barrel_shifter;

architecture rtl of barrel_shifter is
    signal result1, result2: STD_LOGIC_VECTOR (Nbit-1 downto 0);
begin
    shift_one : process(input,N_loc(0))                              
    begin
        if(N_loc(0)='1') then	                                     -- Shifta di 1 ( il primo shifter è attivato)
            result1(Nbit-1) <= input(Nbit-1);
            result1(Nbit-2 downto 0) <= input(Nbit-1 downto 1);
        else
            result1(Nbit-1 downto 0) <= input(Nbit-1 downto 0);      -- il primo shifter è disattivo
        end if;
    end process;
    
    shift_two : process(result1,N_loc(1))                          
    begin
        if(N_loc(1)='1') then	                                     -- Shifta di 2 (il secondo shifter è attivato)
            result2(Nbit-1) <= result1(Nbit-1);
            result2(Nbit-2) <= result1(Nbit-1);
            result2(Nbit-3 downto 0) <= result1(Nbit-1 downto 2);
        else
            result2(Nbit-1 downto 0) <= result1(Nbit-1 downto 0);    -- il secondo shifter è disattivo
        end if;
    end process;
    
    shift_four : process(result2, N_loc(2))                           
    begin
        if(N_loc(2)='1') then	                                         -- Shifta di 4 (il terzo shifter è attivato)
            shifted_input(Nbit-1) <= result2(Nbit-1);
            shifted_input(Nbit-2) <= result2(Nbit-1);
            shifted_input(Nbit-3) <= result2(Nbit-1);
            shifted_input(Nbit-4) <= result2(Nbit-1);
            shifted_input(Nbit-5 downto 0) <= result2(Nbit-1 downto 4);
        else
            shifted_input(Nbit-1 downto 0) <= result2(Nbit-1 downto 0);  -- il terzo shifter è disattivo
        end if;
    end process;
end rtl;