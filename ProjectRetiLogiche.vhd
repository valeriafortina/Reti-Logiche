----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Valeria Fortina, Alessio Galluccio
-- 
-- Create Date: 03.03.2019 16:45:31
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0));
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

type state_type is (RESET, READ_MASCH,COPY_MASCH,ADD_IND, READ_X,COPY_X, READ_Y,COPY_Y,CALC_DIST, INSERISCI, TROVA_MIN, CONFRONTA, WRITE_MASCH, FINE);

--segnali per la memorizzazione delle distanze

signal dist_1, next_dist_1 : std_logic_vector(9 downto 0) := "1111111111";
signal dist_2, next_dist_2 : std_logic_vector(9 downto 0) := "1111111111";
signal dist_3, next_dist_3 : std_logic_vector(9 downto 0) := "1111111111";
signal dist_4, next_dist_4 : std_logic_vector(9 downto 0) := "1111111111";
signal dist_5, next_dist_5 : std_logic_vector(9 downto 0) := "1111111111";
signal dist_6, next_dist_6 : std_logic_vector(9 downto 0) := "1111111111";
signal dist_7, next_dist_7 : std_logic_vector(9 downto 0) := "1111111111";
signal dist_8, next_dist_8 : std_logic_vector(9 downto 0) := "1111111111";
signal distanza, next_distanza :std_logic_vector(9 downto 0) := "1111111111";

--segnali per coordinate punto x e y

signal px, next_px : std_logic_vector(7 downto 0) := "00000000";
signal py, next_py : std_logic_vector(7 downto 0) := "00000000";

--segnali per valori temporali di x e y

signal temp_x, next_temp_x :std_logic_vector(7 downto 0) := "00000000";
signal temp_y, next_temp_y :std_logic_vector(7 downto 0):= "00000000";

--segnale per la distanza minima

signal dist_min, next_dist_min :std_logic_vector(9 downto 0) := "0000000000";

--segnale maschera input

signal masch_in, next_masch_in :std_logic_vector(7 downto 0):= "00000000";

--segnale maschera output

signal masch_out, next_masch_out :std_logic_vector(7 downto 0):= "00000000";

--segnale indirizzo RAM

signal ind_ram, next_ind_ram :std_logic_vector(15 downto 0) := "0000000000000000";

--Contatore
 
signal cont, next_cont : std_logic_vector(2 downto 0) := "000";

--Stati

signal state : state_type := RESET; 
signal next_state : state_type := RESET;

--segnale next_o_done

signal next_o_done: std_logic := '0';



-- BEGIN
begin

-- processo di update dei segnali al fronte di salita del clock
state_reg_update: process(i_clk)
begin
	if rising_edge(i_clk) then
	    state <= next_state;
		dist_1 <= next_dist_1; 
		dist_2 <= next_dist_2;
		dist_3 <= next_dist_3;
		dist_4 <= next_dist_4;
		dist_5 <= next_dist_5;
		dist_6 <= next_dist_6;
		dist_7 <= next_dist_7;
		dist_8 <= next_dist_8;
		px <= next_px;
		py <= next_py;
		temp_x <= next_temp_x;
		temp_y <= next_temp_y;
		dist_min <= next_dist_min;
		masch_in <= next_masch_in;
		masch_out <= next_masch_out;
		ind_ram <= next_ind_ram;
		cont <= next_cont;
		o_done <= next_o_done;
		distanza <= next_distanza;
	end if;
end process;



main: process(i_clk, i_rst)
    
begin 
 
    if i_rst = '1' then
        next_state <= RESET;

    elsif falling_edge(i_clk) then
    
        case state is
        
        --resetta i segnali
        --imposta il primo indirizzo da leggere dalla RAM e inizia il processo se segnale start è alto   
        when RESET =>
            next_o_done <= '0';
            o_en <= '0';
            o_we <= '0';
            o_data <= "00000000";            
            if(i_start = '1') then
                next_ind_ram <= "0000000000000000";
                next_state <= READ_MASCH;
            else
                next_state <= RESET;
            end if;
    
        --imposta i segnali per leggere la maschera di ingresso dalla RAM
        when READ_MASCH =>
            o_address <= ind_ram;
            o_en <= '1';
            o_we <= '0';
            next_state <= COPY_MASCH;
            
        --copia il valore della maschera di ingresso dalla RAM nel segnale apposito
        when COPY_MASCH =>
            next_masch_in <= i_data;
            next_state <= ADD_IND;
            
        --modifica il segnale ind_ram a seconda dei casi:
        --      se la macchina ha appena letto la maschera di ingresso, porta l'indirizzo a quello del punto da studiare (indirizzo 15)
        --      se la macchina ha appena letto le coordinate del punto da studiare, porta l'indirizzo a quello del primo centroide (indirizzo 1)
        --      se la macchina ha appena letto un centroide, porta l'indirizzo al prossimo centroide (aumenta di 2 l'indirizzo)            
        when ADD_IND =>      
            if ind_ram(4 downto 0) = "00000" then
                next_ind_ram <= "0000000000010001";
                next_state <= READ_X;
            elsif ind_ram(4 downto 0) = "10001" then
                next_ind_ram <= "0000000000000001";
                next_state <= READ_X; 
            else
                next_ind_ram <= std_logic_vector(unsigned(ind_ram) + 2);
                next_state <= READ_X;
            end if;
            
        --imposta i valori per leggere dalla memoria la coordinata X  
        when READ_X =>
                o_en <= '1';
                o_we <= '0';
                o_address <= ind_ram;
                next_state <= COPY_X;                
        
        --copia il valore della coordinata X nel segnale temporaneo se è un centroide
        --copia il valore della coordinata X nel segnale apposito se è il punto di riferimento    
        when COPY_X =>
            if ind_ram(4 downto 0) = "10001" then
                next_px <= i_data;
            else
                next_temp_x <= i_data;
            end if;
            next_state <= READ_Y;
        
        --imposta i valori per leggere dalla memoria la coordinata Y    
        when READ_Y =>
            o_en <= '1';
            o_we <= '0';
            o_address <= std_logic_vector(unsigned(ind_ram) + 1); 
            next_state <= COPY_Y; 
   
        --copia il valore della coordinata Y nel segnale temporaneo se è un centroide
        --copia il valore della coordinata Y nel segnale apposito se è il punto di riferimento 
        when COPY_Y =>
            if ind_ram(4 downto 0) = "10001" then
                next_py <= i_data;
                next_state <= ADD_IND;
            else
                next_temp_y <= i_data;
                next_state <= CALC_DIST;
            end if;
              
          
        --calcola la distanza di Manhattan del centroide dal punto studiato e la inserisce nel segnale corrispondente
        --se ha calcolato la distanza dell'ultimo centroide, passa alla fase di calcolo della distanza minima   
        when CALC_DIST =>
                if unsigned(temp_x) > unsigned(px) then
                    if unsigned(temp_y) > unsigned(py) then
                        next_distanza <= std_logic_vector( unsigned("00" & temp_x) - unsigned("00" & px) + unsigned("00" & temp_y) - unsigned("00" & py) );
                    else
                        next_distanza <= std_logic_vector( unsigned ("00" & temp_x) - unsigned ("00" & px) + unsigned("00" & py) - unsigned("00" & temp_y) );
                    end if;
                else
                    if unsigned(temp_y) > unsigned(py) then
                        next_distanza <= std_logic_vector( unsigned("00" & px) - unsigned("00" & temp_x) + unsigned("00" & temp_y) - unsigned("00" & py) );
                    else
                        next_distanza <= std_logic_vector( unsigned ("00" & px) - unsigned("00" & temp_x) + unsigned("00" & py) - unsigned("00" & temp_y) );
                    end if;
                end if;
				next_state <= INSERISCI;
            
                
		--copia la distanza calcolata nello stato precedente nel segnale corretto		
		when INSERISCI =>	
		
				case ind_ram(4 downto 0) is
            
                    when "00001" => -- indirizzo 1, centroide 1
                        if masch_in(0) = '0' then
                            next_dist_1 <= "1111111111";
                        elsif masch_in(0) = '1' then
                            next_dist_1 <= distanza;
                        end if;
            
                    when  "00011" => -- indirizzo 3, centroide 2
                        if masch_in(1) = '0' then
                            next_dist_2 <= "1111111111";
                        elsif masch_in(1) = '1' then
                            next_dist_2 <= distanza;
                        end if;
            
                    when  "00101" => -- indirizzo 5, centroide 3
                        if masch_in(2) = '0' then
                            next_dist_3 <= "1111111111";
                        elsif masch_in(2) = '1' then
                            next_dist_3 <= distanza;
                        end if;    
            
                    when  "00111" => -- indirizzo 7, centroide 4
                        if masch_in(3) = '0' then
                            next_dist_4 <= "1111111111";
                        elsif masch_in(3) = '1' then
                            next_dist_4 <= distanza;
                        end if;
            
                    when "01001" => -- indirizzo 9, centroide 5
                        if masch_in(4) = '0' then
                            next_dist_5 <= "1111111111";
                        elsif masch_in(4) = '1' then
                            next_dist_5 <= distanza;
                        end if;
            
                    when "01011" => -- indirizzo 11, centroide 6
                        if masch_in(5) = '0' then
                            next_dist_6 <= "1111111111";
                        elsif masch_in(5) = '1' then
                            next_dist_6 <= distanza;
                        end if;
            
                    when "01101" =>-- indirizzo 13, centroide 7
                        if masch_in(6) = '0' then
                            next_dist_7 <= "1111111111";
                        elsif masch_in(6) = '1' then
                            next_dist_7 <= distanza;
                        end if;
            
                    when "01111" => -- indirizzo 15, centroide 8
                        if masch_in(7) = '0' then
                            next_dist_8 <= "1111111111";
                        elsif masch_in(7) = '1' then
                            next_dist_8 <= distanza;
                        end if;
                        
                
                    when others =>  --azione vuota
            
                end case;
                
                if ind_ram = "0000000000001111" then    --indirizzo 15, ha calcolato l'ultimo centroide e ha finito
                    next_cont <= "000";
                    next_state <= TROVA_MIN;
                else
                    next_state <= ADD_IND;  --ha altri centroidi da calcolare
                end if;
                
                
		--trova la distanza minima e la salva       
		when TROVA_MIN =>
		
			--utilizza un contatore, ogni volta confronta la distanza minima
			if(cont = "000") then
				next_dist_min <= dist_1;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <= TROVA_MIN;
				
			elsif(cont = "001") then 
				if(dist_min >= dist_2) then
					next_dist_min <= dist_2;
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <= TROVA_MIN;
			
			elsif(cont = "010") then 
				if(dist_min >= dist_3) then
					next_dist_min <= dist_3;
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <= TROVA_MIN;
			
			elsif(cont = "011") then 
				if(dist_min >= dist_4) then
					next_dist_min <= dist_4;
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <= TROVA_MIN;
			
			elsif(cont = "100") then 
				if(dist_min >= dist_5) then
					next_dist_min <= dist_5;
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <= TROVA_MIN;
				
			elsif(cont = "101") then 
				if(dist_min >= dist_6) then
					next_dist_min <= dist_6;
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <= TROVA_MIN;
				
			elsif(cont = "110") then 
				if(dist_min >= dist_7) then
					next_dist_min <= dist_7;
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <= TROVA_MIN;
				
			elsif(cont = "111") then 
				if(dist_min >= dist_8) then
					next_dist_min <= dist_8;
				end if;
				next_cont <= "000";
				next_masch_out<= "00000000";
				next_state <= CONFRONTA;
				
		
			end if; --distanza minima trovata
					
						
                        
		-- trova quali distanze sono uguali alla distanza minima e somma sulla maschera in uscita            
		when CONFRONTA =>
		
			--utilizza un contatore
			if(cont = "000") then
			
			--se la disanza è infinita allora la maschera in ingresso era di soli 0 e quindi l'uscita è di soli zero
				if (dist_min = "1111111111") then
				  
				   next_masch_out<= "00000000";
				   next_state <= WRITE_MASCH;
				   
			--altrimenti prosegue confrontando le distanze e sommando sulla maschera in uscita
				else 
					 if (dist_min = dist_1) then
						 next_masch_out <= std_logic_vector( unsigned (masch_out) + 1);
					 end if;
					 next_cont <= std_logic_vector( unsigned (cont) + 1);
					 next_state <=CONFRONTA;
				end if;
				
		--per ogni valore del contatore ripete la verifica e eventuale somma
			elsif(cont = "001") then
				if (dist_min = dist_2) then
					next_masch_out <= std_logic_vector( unsigned (masch_out) + 2);
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <=CONFRONTA;
				
			
			elsif(cont = "010") then
				if (dist_min = dist_3) then
					next_masch_out <= std_logic_vector( unsigned (masch_out) + 4);
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <=CONFRONTA;
				
			
			elsif(cont = "011") then
				if (dist_min = dist_4) then
					next_masch_out <= std_logic_vector( unsigned (masch_out) + 8);
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <=CONFRONTA;
				
			
			elsif(cont = "100") then
				if (dist_min = dist_5) then
					next_masch_out <= std_logic_vector( unsigned (masch_out) + 16);
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <=CONFRONTA;
				
			
			elsif(cont = "101") then
				if (dist_min = dist_6) then
					next_masch_out <= std_logic_vector( unsigned (masch_out) + 32);
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <=CONFRONTA;
			
			
			elsif(cont = "110") then
				if (dist_min = dist_7) then
					next_masch_out <= std_logic_vector( unsigned (masch_out) + 64);
				end if;
				next_cont <= std_logic_vector( unsigned (cont) + 1);
				next_state <=CONFRONTA;
				
				
			elsif(cont = "111") then
				if (dist_min = dist_8) then
					next_masch_out <= std_logic_vector( unsigned (masch_out) + 128);
				end if;
				
				next_state <= WRITE_MASCH;
			end if;
		
		--scrive la maschera di uscita nelll'indirizzo corretto della RAM
		when WRITE_MASCH =>		
			o_data <= masch_out;
			o_address <= "0000000000010011";
			o_en <= '1';
			o_we <= '1';
			next_state <= FINE;
		
		--compie le operazioni di terminazione della computazione e ritorna allo stato di RESET	
		when FINE =>		
			if i_start = '1' then
				next_o_done <= '1';
				next_state <= FINE;
			elsif i_start = '0' then
				next_o_done <= '0';
				next_state <= RESET;
			end if;
                        
                            
                         
        end case;
    end if;   
end process;

end Behavioral;
