library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_axi_v0_1 is
	generic (
		-- Users to add parameters here
        DBIT : integer := 8; --Databits
        SB_TICK : integer := 16; --Stopbit ticks (16/24/32 -> 1, 1.5, 2)
        DVSR : integer := 27; -- Baud rate Divisor
        FIFO_W : integer := 2; -- # of FIFO Addressbits
        PARITY_EN : std_logic := '1'; -- Parity enable(1) / disable(0)
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
        rx : in std_logic;
        tx : out std_logic;
        rts : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end uart_axi_v0_1;

architecture arch_imp of uart_axi_v0_1 is

    --User signals
    signal uart_slave_tx_full : std_logic;
    signal uart_slave_rx_empty : std_logic;
    signal wr_enable : std_logic;
    signal rd_enable : std_logic;
    signal rd_data_byte : std_logic_vector(7 downto 0);
    signal wr_data_byte : std_logic_vector(7 downto 0);
    
	-- component declaration
	component uart_axi_v0_1_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port ( 
		uart_tx_full : in std_logic;
		uart_rx_empty : in std_logic;
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component uart_axi_v0_1_S00_AXI;
	
		component uart is
generic(
        DBIT : integer := 8; --Databits
        SB_TICK : integer := 16; --Stopbit ticks (16/24/32 -> 1, 1.5, 2)
        DVSR : integer := 27; -- Baud rate Divisor
        FIFO_W : integer := 2; -- # of FIFO Addressbits
        PARITY_EN : std_logic := '1' -- Parity enable(1) / disable(0)
        );
    port(
        clk : in std_logic;
        reset : in std_logic;
        rd_uart, wr_uart : in std_logic;
        rx : in std_logic;
        w_data : in std_logic_vector(7 downto 0);
        tx_full : out std_logic;
        rx_empty : out std_logic;
        r_data : out std_logic_vector(7 downto 0);
        tx : out std_logic
        );
        end component uart;
        	
begin

-- Instantiation of Axi Bus Interface S00_AXI
uart_axi_v0_1_S00_AXI_inst : uart_axi_v0_1_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    uart_tx_full => uart_slave_tx_full,
	    uart_rx_empty => uart_slave_rx_empty,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> wr_enable,--s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> open,--s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> rd_enable,--s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here

	s00_axi_wready <= wr_enable;
	s00_axi_rvalid <= rd_enable;
	wr_data_byte <= s00_axi_wdata(7 downto 0);
	s00_axi_rdata <= "000000000000000000000000"&rd_data_byte;
	rts <= '1';
	
uart_inst : uart
    generic map(
        DBIT => DBIT,
        SB_TICK => SB_TICK, --Stopbit ticks (16/24/32 -> 1, 1.5, 2)
        DVSR => DVSR, -- Baud rate Divisor
        FIFO_W => FIFO_W, -- # of FIFO Addressbits
        PARITY_EN => PARITY_EN -- Parity enable(1) / disable(0)
        )
    port map(
        clk => s00_axi_aclk,
        reset => s00_axi_aresetn,
        rd_uart => rd_enable,
        wr_uart => wr_enable,
        rx => rx,
        w_data => wr_data_byte,--s00_axi_wdata,
        tx_full => uart_slave_tx_full,
        rx_empty => uart_slave_rx_empty,
        r_data => rd_data_byte,
        tx => tx
        );

	-- User logic ends

end arch_imp;
