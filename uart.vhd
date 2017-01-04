-- 
-- UART Top Module
-- uart_rx, uart_tx, baud_gen, parity_gen, fifo_buffer
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
generic(
	DBIT : integer := 8; --Databits
	SB_TICK : integer := 16; --Stopbit ticks (16/24/32 -> 1, 1.5, 2)
	DVSR : integer := 16; -- Baud rate Divisor
	FIFO_W : integer := 2; -- # of FIFO Addressbits
	PARITY_EN : std_logic := '1' -- Parity enable(1) / disable(0)
	);
port(
	clk, reset : in std_logic;
	rd_uart, wr_uart : in std_logic;
	rx : in std_logic;
	w_data : in std_logic_vector(7 downto 0);
	tx_full, rx_empty : out std_logic;
	r_data : out std_logic_vector(7 downto 0);
	tx : out std_logic
	);
end uart;

architecture main of uart is

	signal tick : std_logic;
	signal rx_done_tick : std_logic;
	signal tx_fifo_out : std_logic_vector(7 downto 0);
	signal rx_data_out : std_logic_vector(7 downto 0);
	signal tx_empty, tx_fifo_not_empty : std_logic;
	signal tx_done_tick : std_logic;
	signal parity_bit : std_logic;

begin
	baud_gen_unit: entity work.baud_gen
	generic map(
		M=>DVSR)
	port map(
		clk => clk, reset => reset,
		max_tick => tick);

	uart_rx_unit: entity work.uart_rx
	generic map(
		DBIT => DBIT, SB_TICK => SB_TICK,
		PARITY_EN => PARITY_EN)
	port map(
		clk => clk, reset => reset, rx => rx,
		s_tick => tick, rx_done_tick => rx_done_tick,
		dout => rx_data_out, framing_error_tick => open,
		parity_error => open);

	fifo_rx_unit: entity work.fifo_buffer
	generic map(
		B => DBIT, W => FIFO_W)
	port map(
		clk => clk, reset => reset, rd => rd_uart,
		wr => rx_done_tick, w_data => rx_data_out,
		empty => rx_empty, full => open, r_data => r_data);

	uart_tx_unit: entity work.uart_tx
	generic map(
		DBIT => DBIT, SB_TICK => SB_TICK,
		PARITY_EN => PARITY_EN)
	port map(
		clk => clk, reset => reset, tx_start => tx_fifo_not_empty,
		s_tick => tick, din => tx_fifo_out, tx_done_tick => tx_done_tick,
		tx => tx, parity_bit => parity_bit);

	fifo_tx_unit: entity work.fifo_buffer
	generic map(
		B => DBIT, W => FIFO_W)
	port map(
		clk => clk, reset => reset, rd => tx_done_tick,
		wr => wr_uart, w_data => w_data, empty => tx_empty,
		full => tx_full, r_data => tx_fifo_out);

	parity_gen: entity work.parity_gen
	port map(vec_in => tx_fifo_out, parity_bit => parity_bit);
	tx_fifo_not_empty <= not tx_empty;
end main;
	
	

