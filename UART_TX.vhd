library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
   generic(
      DBIT: integer := 8;     -- Anzahl Datenbits
      PARITY_EN: std_logic := '1'; -- Parity bit (1 = enable, 0 = disable)
      SB_TICK: integer := 16   -- Anzahl s_tick f stopbbit
   );
   port(
      clk, reset: in std_logic;
      tx_start: in std_logic;
      s_tick: in std_logic;
      din: in std_logic_vector(7 downto 0);
      tx_done_tick: out std_logic;
      tx: out std_logic;
      parity_bit: in std_logic
   );
end uart_tx ;

architecture main of uart_tx is

   type state_type is (idle, start, data, parity, stop);-- FSM status typen
   signal state_reg, state_next: state_type;            -- Status Register 
   signal s_reg, s_next: unsigned(4 downto 0);    -- Register für Stop Bit
   signal n_reg, n_next: unsigned(3 downto 0);          -- Anzahl empfangener bits
   signal b_reg, b_next: std_logic_vector(7 downto 0);  -- Datenwort
   signal tx_reg, tx_next: std_logic;                   -- tx_reg: transmission register, routed to tx
   
begin

   -- register
   process(clk,reset)
   begin
      if (rising_edge(clk) and clk='1') then
	 if reset = '1' then
         	state_reg <= idle;
         	s_reg <= (others=>'0');
         	n_reg <= (others=>'0');
         	b_reg <= (others=>'0');
         	tx_reg <= '1';
	 elsif reset = '0' then
         	state_reg <= state_next;
         	s_reg <= s_next;
         	n_reg <= n_next;
         	b_reg <= b_next;
         	tx_reg <= tx_next;
         end if;
      end if;
   end process;
   
   -- next-state logic & data path functional units/routing
   process(state_reg,s_reg,n_reg,b_reg,s_tick,
           tx_reg,tx_start,din, parity_bit)
   begin
   
      state_next <= state_reg;
      s_next <= s_reg;
      n_next <= n_reg;
      b_next <= b_reg;
      tx_next <= tx_reg ;
      tx_done_tick <= '0';
      
      case state_reg is					-- state machine (idle, start, data, stop)
      
         when idle =>                                   --idle
            tx_next <= '1';				-- tx = 1 während idle
            if tx_start='1' then			-- tx_start = 1 => state: data
               state_next <= start;
               s_next <= (others=>'0');
               b_next <= din;                           --b_next = 8 bit Datenwort aus din
            end if;
            
         when start =>                                  --start
            tx_next <= '0';                             --startbit
            if (s_tick = '1') then
               if s_reg=7 then                         --nach 15 sample ticks status => data                     
                  state_next <= data;
                  s_next <= (others=>'0');
                  n_next <= (others=>'0');
               else
                  s_next <= s_reg + 1;
               end if;
            end if;
            
         when data =>                                   --data
            tx_next <= b_reg(0);
            if (s_tick = '1') then
               if s_reg=15 then
                  s_next <= (others=>'0');
                  b_next <= '0' & b_reg(7 downto 1) ;   --shift register
                  if n_reg=(DBIT-1) then                --then n_reg = 8 => stop
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
	    tx_next <= parity_bit;	
	    if s_tick = '1' then
	       if s_reg = 15 then
	       s_next <= (others=>'0');
	       state_next <= stop;
	       else 
	       s_next <= s_reg + 1;	
	       end if;
	    end if;	

         when stop =>                                   --stop
            tx_next <= '1';
            if (s_tick = '1') then
               if s_reg=(SB_TICK-1) then
                  state_next <= idle;
                  tx_done_tick <= '1';
               else
                  s_next <= s_reg + 1;
               end if;
            end if;

      end case;
   end process;
   
   tx <= tx_reg;
   
end main;


