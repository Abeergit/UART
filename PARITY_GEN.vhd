library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity parity_gen is
	port(
	vec_in         : in std_logic_vector (7 downto 0);
	parity_bit     : out std_logic);
end parity_gen;

architecture main of parity_gen is

	signal parity : std_logic;

begin
process(vec_in)
begin

	parity <= (vec_in(0) xor vec_in(1)) xor (vec_in(2) xor vec_in(3)) xor (vec_in(4) xor vec_in(5)) xor (vec_in(6) xor vec_in(7)); --even parity
	
end process;

	parity_bit <= parity;

end main;
