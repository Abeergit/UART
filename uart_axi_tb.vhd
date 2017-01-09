library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_axi_tb is
end uart_axi_tb;

architecture main of uart_axi_tb is

   -- Users to add ports here
   signal rx : std_logic := '1';
   signal tx : std_logic;

   --Inputs
   signal s00_axi_aclk : std_logic := '0';
   signal s00_axi_aresetn : std_logic := '0';
   signal s00_axi_awaddr : std_logic_vector(3 downto 0) := (others => '0');
   signal s00_axi_awvalid : std_logic := '0';
   signal s00_axi_wdata : std_logic_vector(31 downto 0) := (others => '0');
   signal s00_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
   signal s00_axi_bready : std_logic := '0';
   signal s00_axi_araddr : std_logic_vector(3 downto 0) := (others => '0');
   signal s00_axi_arvalid : std_logic := '0';
   signal s00_axi_rready : std_logic := '0';

   --Outputs
   signal s00_axi_awready : std_logic;
   signal s00_axi_wready : std_logic;
   signal s00_axi_bvalid : std_logic;
   signal s00_axi_bresp : std_logic_vector(1 downto 0);
   signal s00_axi_arready : std_logic;
   signal s00_axi_rdata : std_logic_vector(31 downto 0);
   signal s00_axi_rvalid : std_logic;
   signal s00_axi_rresp : std_logic_vector(1 downto 0);
   
   --unused
   signal s00_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
   signal s00_axi_wvalid : std_logic;
   signal s00_axi_arprot : std_logic_vector(2 downto 0) := (others => '0');
   -- Clock period definitions
   constant s00_axi_aclk_period : time := 20 ns;
   
	begin
	
	uart_axi_uut : entity work.uart_axi_v0_1
	port map(
		
        rx => rx,
        tx => tx,

		s00_axi_aclk => s00_axi_aclk,
		s00_axi_aresetn => s00_axi_aresetn,
		s00_axi_awaddr => s00_axi_awaddr,
		s00_axi_awprot => s00_axi_awprot,
		s00_axi_awvalid => s00_axi_awvalid,
		s00_axi_awready => s00_axi_awready,
		s00_axi_wdata => s00_axi_wdata,
		s00_axi_wstrb => s00_axi_wstrb,
		s00_axi_wvalid	=> s00_axi_wvalid,
		s00_axi_wready => s00_axi_wready,
		s00_axi_bresp => s00_axi_bresp,
		s00_axi_bvalid => s00_axi_bvalid,
		s00_axi_bready => s00_axi_bready,
		s00_axi_araddr => s00_axi_araddr,
		s00_axi_arprot => s00_axi_arprot,
		s00_axi_arvalid => s00_axi_arvalid,
		s00_axi_arready => s00_axi_arready,
		s00_axi_rdata => s00_axi_rdata,
		s00_axi_rresp => s00_axi_rresp,
		s00_axi_rvalid => s00_axi_rvalid,
		s00_axi_rready => s00_axi_rready
	);
	
	  -- Clock process definitions
   s00_axi_aclk_process :process
   begin
    s00_axi_aclk <= '0';
    wait for s00_axi_aclk_period/2;
    s00_axi_aclk <= '1';
    wait for s00_axi_aclk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin    
      -- hold reset state for 50 ns.
      wait for 20 ns;  

      -- insert stimulus here

    -- Write operation 
    s00_axi_aresetn <= '1';
    
    wait for 10 ns;
    wait until rising_edge(s00_axi_aclk);
    
    s00_axi_awaddr <= "1111";
    s00_axi_awvalid <= '1';
    s00_axi_wdata <= "00000000000000000000000000000001";
    s00_axi_wvalid <= '1';
    s00_axi_wstrb <= "0001";
    s00_axi_bready <= '1';
    
    --wait for 10 ns;  
    wait until falling_edge(s00_axi_wready);
    
    s00_axi_awaddr <= "0000";
    s00_axi_awvalid <= '0'; 
    s00_axi_wvalid <= '0';
    s00_axi_wdata <= (others => '0');
    s00_axi_wstrb <= "0000";

    wait until falling_edge(s00_axi_bvalid);
    s00_axi_bready <= '0';
    
    wait for 50000 ns;
    
    -- Read operation 
    
    wait for 50 ns;
    wait until rising_edge(s00_axi_aclk);
    
    s00_axi_araddr <= "1111";
    s00_axi_arvalid <= '1';
    s00_axi_rready <= '1';
    rx <= '0';
    
    --wait for 10 ns;  
    wait until falling_edge(s00_axi_arready);
    
    s00_axi_araddr <= "0000";
    s00_axi_arvalid <= '0';
    rx <= '1';
    
    wait until falling_edge(s00_axi_rvalid);
    s00_axi_rready <= '0';
    
      wait for 50000 ns;
      assert false		--beendet die Simulation
      report "simulation complete"
      severity failure;
   end process;
end;
