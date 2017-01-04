library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_gen is
   generic(
      M: integer := 16    -- Divisor for sample rate (clk/sample_rate)	
  );
  
   port(
      clk, reset: in std_logic;
      max_tick: out std_logic
   );
   
end baud_gen;

architecture main of baud_gen is

   signal r_reg, r_next: integer range 0 to (M-1);

begin

   -- register
   process(clk,reset,r_reg, r_next)
   begin
       if (rising_edge(clk) and clk='1') then
          if (reset='1') then
             r_reg <= 0;
	  elsif (reset = '0') then
             r_reg <= r_next;
          end if;
       end if;
   end process;
   
   -- next-state logic
   r_next <= 0 when r_reg=(M-1) else r_reg + 1;
			 
   -- output logic
	max_tick <= '1' when r_reg=(M-1) else '0';
   
end main;
