LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity Cordic is
   generic ( N : positive := 12);
   port( cordic_den      :  in std_logic_vector  (N-1 downto 0);     
         cordic_num      :  in std_logic_vector  (N-1 downto 0);     
         cordic_ris      :  out std_logic_vector (N-1 downto 0);     
         cordic_clock    :  in  std_logic;
         cordic_ready    :  in  std_logic
   );
end Cordic;

architecture rtl of CORDIC is    

component inv is
	generic ( Nbit : positive := 18);
    port(
        xin  : in std_logic;
        yin  : in std_logic_vector(Nbit-1 downto 0);
        yout : out std_logic_vector(Nbit-1 downto 0)
    );
end component inv;

component adder is
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
end component adder;

component barrel_shifter is		
    generic (Nbit : INTEGER:=18);
    port(
         input         : in  std_logic_vector (Nbit-1 downto 0);
         shifted_input : out std_logic_vector (Nbit-1 downto 0);
         N_loc         : in  std_logic_vector (2 downto 0)
    );
end component barrel_shifter;

component rom_8x12 is
    port(
        address : in STD_LOGIC_vector(2 downto 0);
        output  : out STD_LOGIC_vector(11 downto 0)
    );
end component rom_8x12;

-- utilizzato per avviare o terminare il calcolo della cumulata 
signal cordic_check : std_logic := '1';
-- Segnale contenente il segno del denominatore
signal sign_den :std_logic; 
-- Segnale contenente il segno del numeratore                                                   
signal sign_num :std_logic;
-- Segnale cotenente il complemento del segno del numeratore 
signal notsign_num :std_logic;

-- Segnali utilizzati per estendere i due ingressi da 12 a 18 bit 
signal den_extended: std_logic_vector (17 downto 0); 
signal num_extended: std_logic_vector (17 downto 0); 

-- Segnale utilizzato per indicare il numero di shit da effettuare
signal num_shift: std_logic_vector (2 downto 0); 

-- Segnali dall'inverter del den o del num all'adder i-esimo 
signal inverterDen_adder1: std_logic_vector (17 downto 0); 
signal inverterNum_adder2: std_logic_vector (17 downto 0); 

-- Segnali dall'inverter i-esimo all'adder i-esimo
signal inverter2_Adder1: std_logic_vector (17 downto 0); 
signal inverter2_Adder1_connected: std_logic_vector (17 downto 0); 
signal inverter1_Adder2: std_logic_vector (17 downto 0); 
signal inverter1_Adder2_connected: std_logic_vector (17 downto 0);
signal inverterRis_Adder3: std_logic_vector (17 downto 0);
signal inverterRis_Adder3_connected: std_logic_vector (17 downto 0); 

-- Segnali dall'adder i-esimo allo shifter i-esimo 
signal adder1_shifter1: std_logic_vector (17 downto 0); 
signal adder2_shifter2: std_logic_vector (17 downto 0); 
signal adder3_output: std_logic_vector (17 downto 0); 

-- Segnali dallo shifter all'inverter i-esimo 
signal shifter1_inverter1: std_logic_vector (17 downto 0);  
signal shifter2_inverter2: std_logic_vector (17 downto 0); 

--Segnale dalla rom all'inverterRis
signal rom_inverterRis: std_logic_vector (17 downto 0);  

begin                                             

    -- INVERTER
	
    INVERTERDEN: inv
        port map (
                    xin => sign_den,
                    yin => den_extended,
                    yout => inverterDen_adder1
        );

    INVERTERNUM: inv
        port map (
                    xin => sign_den,
                    yin => num_extended,
                    yout => inverterNum_adder2
        );

    INVERTER1: inv
        port map (
                    xin => notsign_num,
                    yin => shifter1_inverter1,
                    yout => inverter1_Adder2
        );

    INVERTER2: inv
        port map (
                    xin => sign_num,
                    yin => shifter2_inverter2,
                    yout => inverter2_Adder1
        );

    INVERTERRIS: inv
        port map (
                    xin => sign_num,
                    yin => rom_inverterRis,
                    yout => inverterRis_Adder3
        );
    
    -- ADDER

    -- Lo stato iniziale dei registri utilizzati non è significativo 
    -- in quanto viene sovrascritto appena arriva un fronte in salita del clock
    -- mentre ready è ad '1'. Per tale motivo non vi sono segnali di reset.

    ADDER1: adder
        port map (
                    add_in_1 => inverterDen_adder1,
                    add_in_2 => inverter2_Adder1_connected,
                    add_out => adder1_shifter1,
                    add_clk => cordic_clock,
                    add_ready => cordic_ready,
                    add_rst => '1',
                    add_check => cordic_check
        );

    ADDER2: adder
        port map (
                    add_in_1 => inverterNum_adder2,
                    add_in_2 => inverter1_Adder2_connected,
                    add_out => adder2_shifter2,
                    add_clk => cordic_clock,
                    add_ready => cordic_ready,
                    add_rst => '1',
                    add_check => cordic_check
        );

    -- Il calcolo della cumulata deve partire da 0 
    ADDER3: adder
        port map (
                    add_in_1 => B"000000000000000000",
                    add_in_2 => inverterRis_Adder3_connected,
                    add_out => adder3_output,
                    add_clk => cordic_clock,
                    add_ready => cordic_ready,
                    add_rst => '1',
                    add_check => cordic_check
        );


    -- SHIFTER

    SHIFTER1: barrel_shifter
        port map ( 
                    input => adder1_shifter1,
                    shifted_input => shifter1_inverter1,
                    N_loc => num_shift
        );

    SHIFTER2: barrel_shifter
        port map ( 
                    input => adder2_shifter2,
                    shifted_input => shifter2_inverter2,
                    N_loc => num_shift
        );

    -- ROM

    ROM: rom_8x12
        port map(
                    address => num_shift,
                    output => rom_inverterRis(11 downto 0)
        );

    -- MULTIPLEXER

    -- Multiplexer tra l'inverter2 e l'adder 1
    MULTIPLEXER1:process(cordic_ready,inverter2_Adder1)
    begin
        if(cordic_ready = '1') then
                inverter2_Adder1_connected <= (others => '0');
        else
                inverter2_Adder1_connected <= inverter2_Adder1;
        end if;
    end process MULTIPLEXER1;
    
    -- Multiplexer tra l'inverter1 e l'adder 2
    MULTIPLEXER2:process(cordic_ready,inverter1_Adder2)
    begin
        if(cordic_ready = '1') then
                inverter1_Adder2_connected <= (others => '0');
        else
                inverter1_Adder2_connected <= inverter1_Adder2;
        end if;
    end process MULTIPLEXER2;
    
    -- Multiplexer tra l'inverterRis e l'adder 3
    MULTIPLEXER3:process(cordic_ready,inverterRis_Adder3)
    begin
        if(cordic_ready = '1') then
                inverterRis_Adder3_connected <= (others => '0');
        else
                inverterRis_Adder3_connected <= inverterRis_Adder3;
        end if;
    end process MULTIPLEXER3;

    --CORE
    
    -- Core: all'interno si effettuano le iterazioni e viene stabilito quando 
    -- ritornare il risultato
    CORE:process(cordic_clock, cordic_check)
    -- core_start stabilisce quando devono cominciare le iterazioni
    variable core_start:std_logic := '0'; 
    -- core_counter viene utilizzata per tenere conto del numero di iterazioni
    variable core_counter: integer range 0 to 15;  
    begin                                                     
        if (rising_edge(cordic_clock) and cordic_check = '1') then                                  
            -- cordic_ready viene utilizzata per comunicare che l'utente
            -- ha fornito in ingresso un valore valido
            if (cordic_ready ='1') then
                -- Se il numeratore è uguale a 0 viene restituito 0 
                if (cordic_num = B"000000000000") then
                    core_start := '0';
                    cordic_ris <= B"000000000000";
                    cordic_check <= '0';
                -- Se il denominatore è uguale a 0 viene restituito +90 o -90 a 
                -- seconda del segno del numeratore
                elsif (cordic_den = B"000000000000") then
                        core_start := '0';
                        if(cordic_num(11) = '0') then
                            cordic_ris <= B"010110100000"; -- 1 bit per il segno 
                                                           -- 7 bit per la parte intera 
                                                           -- 4 bit per la parte frazionaria      
                        else 
                            cordic_ris <= B"101001100000"; 
                        end if;
                        cordic_check <= '0';
                else 
                        core_start := '1';
                        core_counter := 0;                                
                        -- Si inizializza num_shift che viene utilizzato anche 
                        -- per accedere alla rom
                        num_shift <=std_logic_vector(to_unsigned(core_counter,3));
                end if;  
            elsif ( core_start = '1'  and core_counter < 8) then
                    if ( adder2_shifter2 = B"000000000000000000") then
                        -- Il risultato è stato trovato poichè num vale 0
                        core_start := '0';
                        core_counter := 0;

                        cordic_ris (10 downto 0) <= adder3_output(12 downto 2);
                        cordic_ris(11) <= adder3_output(17);
                        cordic_check <= '0';
                    else   
                        -- risultato ancora non trovato
                        -- occorre effettuare una nuova iterazione
                        core_counter := core_counter +1;
                        num_shift <= std_logic_vector(to_unsigned(core_counter,3));            
                    end if;
            elsif ( core_start = '1') then
                    -- Risultato trovato poichè sono terminate le iterazioni oppure poichè il num vale 0
                    core_start := '0';
                    core_counter := 0;

                    cordic_ris (10 downto 0) <= adder3_output(12 downto 2);
                    cordic_ris(11) <= adder3_output(17);
                    cordic_check <= '0';

            end if;
        end if;
    end process CORE;
    
    -- Estrazione del segno del numeratore e del denominatore
    -- Questi sono utilizzati come variabili di comando degl inverter
    sign_den <=  cordic_den(11);
    sign_num <=  adder2_shifter2(17);
    notsign_num <= NOT sign_num;

    rom_inverterRis(17 downto 12) <= B"000000";

    -- Estensione del numeratore e del denominatore da 12 a 18 bit 

    num_extended(15 downto 4) <= cordic_num;
    num_extended(17) <= cordic_num(11);
    num_extended(16) <= cordic_num(11);
    num_extended(3) <= '0';
    num_extended(2) <= '0';
    num_extended(1) <= '0';
    num_extended(0) <= '0';

    den_extended(15 downto 4) <= cordic_den;
    den_extended(17) <= cordic_den(11);
    den_extended(16) <= cordic_den(11);
    den_extended(3) <= '0';
    den_extended(2) <= '0';
    den_extended(1) <= '0';
    den_extended(0) <= '0';

end rtl;