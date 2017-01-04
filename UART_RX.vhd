library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is

	generic ( DBIT    : integer :=  8;   --Anzahl Datenbits
		  SB_TICK  : integer := 16;  --Anzahl ticks für Stopbit
		  PARITY_EN: std_logic := '1'  );
	port (clk          : in  std_logic;   --clock
	      reset        : in  std_logic;   --reset
              rx           : in  std_logic;   --empfangenes bit
	      s_tick       : in  std_logic;   --sample tick, für (16x baudrate)
	      rx_done_tick : out std_logic;   --tick welches angibt, dass die Uebertragung abgeschlossen ist
	      framing_error_tick: out std_logic;
	      dout         : out std_logic_vector (7 downto 0);  --die aufgenommenen Bits in paralleler Form
	      parity_error : out std_logic);	
end uart_rx; 

architecture main of uart_rx is

	type state_type is (idle, start, data, parity, stop);
	signal parity_bit, parity_rx : std_logic;
	signal state_reg, state_next : state_type;		--Status Register
	signal s_reg, s_next : unsigned (3 downto 0);		--sample register
	signal n_reg, n_next : unsigned (3 downto 0);		--Anzahl empfangener Datenbits
	signal b_reg, b_next : std_logic_vector (7 downto 0);	--Datenwort

begin
   process(clk,reset)
   begin
      if (rising_edge(clk) and clk='1') then
	 if reset = '1' then
         	state_reg <= idle;
         	s_reg <= (others=>'0');
         	n_reg <= (others=>'0');
         	b_reg <= (others=>'0');
	 elsif reset = '0' then
         	state_reg <= state_next;
         	s_reg <= s_next;
         	n_reg <= n_next;
         	b_reg <= b_next;
         end if;
      end if;
   end process;

process(state_reg, s_reg, n_reg, b_reg, s_tick, rx)
begin
	state_next <= state_reg;
	s_next <= s_reg;
	n_next <= n_reg;
	b_next <= b_reg;
	rx_done_tick <= '0';
	framing_error_tick <= '0';

case state_reg is					
	when idle =>					
	if (rx='0') then	
	  state_next <= start;
	  s_next <= (others => '0');
	end if;

	when start =>					
	if (s_tick = '1') then
		if (s_reg = 7) then        
		  state_next <= data;
		  s_next <= (others => '0');
		  n_next <= (others => '0');
	        else
		  s_next <= s_reg + 1;
		end if;
	end if;

	when data =>					
	if (s_tick = '1') then
		if (s_reg = 15) then		
		  s_next <= (others => '0');
		  b_next <= rx & b_reg(7 downto 1);     
                  if n_reg=(DBIT-1) then               
			if PARITY_EN = '1' then
			   state_next <= parity;
			elsif PARITY_EN = '0' then
                           state_next <= stop;
			end if;
		  else
		    n_next <= n_reg + 1;                
		  end if;
		else
		  s_next <= s_reg + 1;
		end if;
	end if;

	when parity =>
	parity_bit <= (b_reg(0) xor b_reg(1)) xor (b_reg(2) xor b_reg(3)) xor (b_reg(4) xor b_reg(5)) xor (b_reg(6) xor b_reg(7)); --even parity
	if (s_tick = '1') then
	   if s_reg = 15 then	
	   s_next <= (others => '0');
	   parity_rx <= rx;
	   parity_error <= rx xor parity_bit;
	   state_next <= stop;
           else 
	   s_next <= s_reg + 1;	
	   end if;
	end if;   	

	when stop =>					
	if (s_tick = '1') then
	   if (s_reg = SB_TICK - 1) then
	      rx_done_tick <= '1';	
	      if (rx = '1') then	 			
		 state_next <= idle;
	      else
		 framing_error_tick <= '1';
		 if (rx = '1') then
		    state_next <= idle;
		 end if;	
	      end if;
	   else 
	      s_next <= s_reg + 1;
	      if (rx = '0') then
	         framing_error_tick <= '1';
	      end if;			
	   end if;
	end if;

end case;
end process;

	dout <= b_reg;

end main;
		  
		 


