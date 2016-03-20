----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Kai Chen
-- 
-- Create Date:    21:33:01 12/05/2014 
-- Design Name: 
-- Module Name:    gth_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;
use work.FELIX_gbt_package.all;
entity gth_top is

    generic
(
   
    STABLE_CLOCK_PERIOD                     : integer   := 24

);
    Port ( 
	 
	 
	 -- Registers in & out 
	 
	
	 gt_txresetdone_out  : out std_logic_vector(3 downto 0);
     gt_rxresetdone_out  : out std_logic_vector(3 downto 0);
     
	 gt_txfsmresetdone_out 	: out std_logic_vector(3 downto 0);
	 gt_rxfsmresetdone_out 	: out std_logic_vector(3 downto 0);
	 
	 gt_cpllfbclklost_out 	: out std_logic_vector(3 downto 0);
	 gt_cplllock_out 			: out std_logic_vector(3 downto 0);

	 
	 gt_rxcdrlock_out 		: out std_logic_vector(3 downto 0);
	 gt_qplllock_out 			: out std_logic;
---------------------------
---- CTRL signals
---------------------------
	 gt_rxslide_in 			: in std_logic_vector(3 downto 0);
	 gt_txuserrdy_in       	: in std_logic_vector(3 downto 0);
	 gt_rxuserrdy_in       	: in std_logic_vector(3 downto 0);
	 
----------------------------------------------------------------
----------RESET SIGNALs
----------------------------------------------------------------	 
	 
	 SOFT_RESET_IN 			: in std_logic;
     GTTX_RESET_IN          : in std_logic_vector(3 downto 0);
     GTRX_RESET_IN          : in std_logic_vector(3 downto 0);
     CPLL_RESET_IN          : in std_logic_vector(3 downto 0);
     QPLL_RESET_IN          : in std_logic;
     
     SOFT_TXRST_GT          : in std_logic_vector(3 downto 0);
     SOFT_RXRST_GT          : in std_logic_vector(3 downto 0);
     SOFT_TXRST_ALL          : in std_logic;
     SOFT_RXRST_ALL          : in std_logic;

	
	
	-- GTH REFCLK, DRPCLK pins 
	 DRP_CLK_IN              : in   std_logic;
--	 GTREFCLK_PAD_N_IN       : in std_logic;
--     GTREFCLK_PAD_P_IN       : in std_logic; 
     GTH_RefClk  : in   std_logic;

	 
	 gt3_rxusrclk_in : in std_logic;
	 gt2_rxusrclk_in : in std_logic;
	 gt1_rxusrclk_in : in std_logic;
	 gt0_rxusrclk_in : in std_logic;
	 
	 gt3_txusrclk_in : in std_logic;
    gt2_txusrclk_in : in std_logic;
    gt1_txusrclk_in : in std_logic;
    gt0_txusrclk_in : in std_logic;
   
	 gt3_rxoutclk_out : out std_logic;
    gt2_rxoutclk_out : out std_logic;
    gt1_rxoutclk_out : out std_logic;
    gt0_rxoutclk_out : out std_logic;
    
    gt3_txoutclk_out : out std_logic;
   gt2_txoutclk_out : out std_logic;
   gt1_txoutclk_out : out std_logic;
   gt0_txoutclk_out : out std_logic;	 
	
	 
	-- DATA
	RX_DATA_gt0_20b : out std_logic_vector(19 downto 0);
	TX_DATA_gt0_20b : in std_logic_vector(19 downto 0);
	RX_DATA_gt1_20b : out std_logic_vector(19 downto 0);
	TX_DATA_gt1_20b : in std_logic_vector(19 downto 0);
	RX_DATA_gt2_20b : out std_logic_vector(19 downto 0);
	TX_DATA_gt2_20b : in std_logic_vector(19 downto 0);
	RX_DATA_gt3_20b : out std_logic_vector(19 downto 0);
	TX_DATA_gt3_20b : in std_logic_vector(19 downto 0);
	
	
	-- GTH Data pins 
	CXP_TX_P   : out std_logic_vector(3 downto 0);
	CXP_TX_N   : out std_logic_vector(3 downto 0);
	CXP_RX_P   : in std_logic_vector(3 downto 0);
	CXP_RX_N   : in std_logic_vector(3 downto 0)
	
);
end gth_top;

architecture Behavioral of gth_top is

signal q_clk0_refclk_i:std_logic;
signal gt0_txusrclk_i: std_logic;
signal gt0_rxusrclk_i: std_logic;
signal gt1_rxusrclk_i: std_logic;
signal gt2_rxusrclk_i: std_logic;
signal gt3_rxusrclk_i: std_logic;

signal gt0_txoutclk_i: std_logic;
signal gt0_rxoutclk_i: std_logic;
signal gt1_rxoutclk_i: std_logic;
signal gt2_rxoutclk_i: std_logic;
signal gt3_rxoutclk_i: std_logic;

--signal gt0_txoutclk_i:std_logic_vector(CH_NUM - 1 to 0);
--signal gt0_rxoutclk_i: std_logic_vector(CH_NUM - 1 to 0);

 
--type txrx20b_type is array (0 to CH_NUM-1) of std_logic_vector(19 downto 0);
--signal TX_DATA_20b : txrx20b_type := (others => ("10101010101010101010"));
--signal RX_DATA_20b : txrx20b_type := (others => ("10101010101010101010"));

signal align_OK,RX_FRAME_CLK,TX_RESET_I,RX_RESET_I,BITSLIP_MANUAL,BITSLIP_MANUAL_r: std_logic;
signal RX_DATA_HEADER_ALIGN,txrefclk_bufg,cxp1_frame_clk40, RX_HEADER_LOCKED:std_logic;
signal data84b:std_logic_vector(83 downto 0);
signal data32b:std_logic_vector(31 downto 0);
signal counter16:std_logic_vector(15 downto 0);
signal counter8:std_logic_vector(7 downto 0);
signal rx_write_address:std_logic_vector(5 downto 0);
signal rx_bitslip_nbr:std_logic_vector(4 downto 0);
signal rx_data_header_align_2r,rx_data_header_align_3r,rx_data_header_align_4r:std_logic;
signal rx_data_header_align_5r,rx_data_header_align_shifted,rx_isdata_flag_o,RX_FRAMECLK_PLL_LOCKED:std_logic;
signal rx_data_header_align_shifted_r1,rx_data_header_align_shifted_r2,rx_data_header_align_shifted_r3,RX_DATA_HEADER_ALIGN_shifted_r4:std_logic;
signal rx_data_header_align_shifted_r5,rx_data_header_align_r:std_logic;



begin



gt3_rxusrclk_i  <= gt3_rxusrclk_in;
gt2_rxusrclk_i  <= gt2_rxusrclk_in;
gt1_rxusrclk_i  <= gt1_rxusrclk_in;
gt0_rxusrclk_i  <= gt0_rxusrclk_in;
gt0_txusrclk_i  <= gt0_txusrclk_in;
--gt1_txusrclk_i  <= gt1_txusrclk_in;
--gt2_txusrclk_i  <= gt2_txusrclk_in;
--gt3_txusrclk_i  <= gt3_txusrclk_in;


gt0_rxoutclk_out <= gt0_rxoutclk_i;
gt1_rxoutclk_out <= gt1_rxoutclk_i;
gt2_rxoutclk_out <= gt2_rxoutclk_i;
gt3_rxoutclk_out <= gt3_rxoutclk_i;
gt0_txoutclk_out <= gt0_txoutclk_i;
gt1_txoutclk_out <= gt0_txoutclk_i;
gt2_txoutclk_out <= gt0_txoutclk_i;
gt3_txoutclk_out <= gt0_txoutclk_i;



------
------ GTH TOP WRAPPERS

QPLL4P8G : if PLL_SEL = QPLL generate 

gth_quad : entity work.gtwizard_qpll_4p8g_4ch

 generic map
  (
         
          STABLE_CLOCK_PERIOD           => STABLE_CLOCK_PERIOD
  )
port map
(
-------------------------------------
---	CLK ---------------------------
-------------------------------------
	q2_clk0_refclk_in					=> 	GTH_RefClk,
	DRP_CLK_IN    						=> 	DRP_CLK_IN,
	 
	 --- RX clock, for each channel
	 gt0_rxusrclk_in  => gt0_rxusrclk_i,
	 gt0_rxoutclk_out	=> gt0_rxoutclk_i,
	 
	 gt1_rxusrclk_in  => gt1_rxusrclk_i,
	 gt1_rxoutclk_out => gt1_rxoutclk_i,
	 
	 gt2_rxusrclk_in  => gt2_rxusrclk_i,
	 gt2_rxoutclk_out => gt2_rxoutclk_i,
	 
	 gt3_rxusrclk_in  => gt3_rxusrclk_i,
	 gt3_rxoutclk_out => gt3_rxoutclk_i,
	 
	 --- TX clock, shared by all channels
	 gt0_txusrclk_in	=> gt0_txusrclk_i,
	 gt0_txoutclk_out => gt0_txoutclk_i,

-----------------------------------------
---- STATUS signals
-----------------------------------------
	 gt_txresetdone_out   	=> gt_txresetdone_out(3 downto 0),
	 gt_rxresetdone_out   	=> gt_rxresetdone_out(3 downto 0),
     
	 gt_txfsmresetdone_out 	=> gt_txfsmresetdone_out(3 downto 0),
	 gt_rxfsmresetdone_out 	=> gt_rxfsmresetdone_out(3 downto 0),
	 
	 gt_cpllfbclklost_out 	=> gt_cpllfbclklost_out(3 downto 0),
	 gt_cplllock_out 			=> gt_cplllock_out(3 downto 0),

	 
	 gt_rxcdrlock_out 		=> gt_rxcdrlock_out(3 downto 0),
	 gt_qplllock_out 			=> gt_qplllock_out,
---------------------------
---- CTRL signals
---------------------------
	 gt_rxslide_in 			=> gt_rxslide_in(3 downto 0),
	 gt_txuserrdy_in       	=> gt_txuserrdy_in(3 downto 0),
	 gt_rxuserrdy_in       	=> gt_rxuserrdy_in(3 downto 0),
	 
----------------------------------------------------------------
----------RESET SIGNALs
----------------------------------------------------------------	 
	 
	 SOFT_RESET_IN 			=> SOFT_RESET_IN,
    GTTX_RESET_IN          => GTTX_RESET_IN(3 downto 0),
    GTRX_RESET_IN          => GTRX_RESET_IN(3 downto 0),
    CPLL_RESET_IN          => CPLL_RESET_IN(3 downto 0),
    QPLL_RESET_IN          => QPLL_RESET_IN,
    
    SOFT_TXRST_GT       =>  SOFT_TXRST_GT(3 downto 0),
    SOFT_RXRST_GT       =>  SOFT_RXRST_GT(3 downto 0),
    SOFT_TXRST_ALL      => SOFT_TXRST_ALL,
    SOFT_RXRST_ALL      => SOFT_RXRST_ALL,

-----------------------------------------------------------
----------- Data and TX/RX Ports
-----------------------------------------------------------
	 
	 RX_DATA_gt0_20b 		=> 	RX_DATA_gt0_20b,
	 TX_DATA_gt0_20b 		=> 	TX_DATA_gt0_20b,
	 RX_DATA_gt1_20b 		=> 	RX_DATA_gt1_20b,
	 TX_DATA_gt1_20b 		=> 	TX_DATA_gt1_20b,
	 RX_DATA_gt2_20b 		=> 	RX_DATA_gt2_20b,
	 TX_DATA_gt2_20b 		=> 	TX_DATA_gt2_20b,
	 RX_DATA_gt3_20b 		=> 	RX_DATA_gt3_20b,
	 TX_DATA_gt3_20b 		=> 	TX_DATA_gt3_20b,
	 
    RXN_IN                   =>               CXP_RX_N(3 downto 0),
    RXP_IN                   =>               CXP_RX_P(3 downto 0),
    TXN_OUT                  =>               CXP_TX_N(3 downto 0),
    TXP_OUT                  =>               CXP_TX_P(3 downto 0)
);



end generate;
 CPLL4P8G : if PLL_SEL = CPLL generate 
 
gth_quad : entity work.gth_quad_4p8g_cpll_exdes
 generic map
 (
        
         STABLE_CLOCK_PERIOD           => STABLE_CLOCK_PERIOD
 )
port map
(
-------------------------------------
---	CLK ---------------------------
-------------------------------------
	q2_clk0_refclk_in					=> 	GTH_RefClk,
	DRP_CLK_IN    						=> 	DRP_CLK_IN,
	 
	 --- RX clock, for each channel
	 gt0_rxusrclk_in  => gt0_rxusrclk_i,
	 gt0_rxoutclk_out	=> gt0_rxoutclk_i,
	 
	 gt1_rxusrclk_in  => gt1_rxusrclk_i,
	 gt1_rxoutclk_out => gt1_rxoutclk_i,
	 
	 gt2_rxusrclk_in  => gt2_rxusrclk_i,
	 gt2_rxoutclk_out => gt2_rxoutclk_i,
	 
	 gt3_rxusrclk_in  => gt3_rxusrclk_i,
	 gt3_rxoutclk_out => gt3_rxoutclk_i,
	 
	 --- TX clock, shared by all channels
	 gt0_txusrclk_in	=> gt0_txusrclk_i,
	 gt0_txoutclk_out => gt0_txoutclk_i,

-----------------------------------------
---- STATUS signals
-----------------------------------------
	 gt_txresetdone_out   	=> gt_txresetdone_out(3 downto 0),
	 gt_rxresetdone_out   	=> gt_rxresetdone_out(3 downto 0),
     
	 gt_txfsmresetdone_out 	=> gt_txfsmresetdone_out(3 downto 0),
	 gt_rxfsmresetdone_out 	=> gt_rxfsmresetdone_out(3 downto 0),
	 
	 gt_cpllfbclklost_out 	=> gt_cpllfbclklost_out(3 downto 0),
	 gt_cplllock_out 			=> gt_cplllock_out(3 downto 0),

	 
	 gt_rxcdrlock_out 		=> gt_rxcdrlock_out(3 downto 0),
	 gt_qplllock_out 			=> gt_qplllock_out,
---------------------------
---- CTRL signals
---------------------------
	 gt_rxslide_in 			=> gt_rxslide_in(3 downto 0),
	 gt_txuserrdy_in       	=> gt_txuserrdy_in(3 downto 0),
	 gt_rxuserrdy_in       	=> gt_rxuserrdy_in(3 downto 0),
	 
----------------------------------------------------------------
----------RESET SIGNALs
----------------------------------------------------------------	 
	 
	 SOFT_RESET_IN 			=> SOFT_RESET_IN,
    GTTX_RESET_IN          => GTTX_RESET_IN(3 downto 0),
    GTRX_RESET_IN          => GTRX_RESET_IN(3 downto 0),
    CPLL_RESET_IN          => CPLL_RESET_IN(3 downto 0),
    QPLL_RESET_IN          => QPLL_RESET_IN,
    
    SOFT_TXRST_GT       =>  SOFT_TXRST_GT(3 downto 0),
    SOFT_RXRST_GT       =>  SOFT_RXRST_GT(3 downto 0),
    SOFT_TXRST_ALL      => SOFT_TXRST_ALL,
    SOFT_RXRST_ALL      => SOFT_RXRST_ALL,

-----------------------------------------------------------
----------- Data and TX/RX Ports
-----------------------------------------------------------
	 
	 RX_DATA_gt0_20b 		=> 	RX_DATA_gt0_20b,
	 TX_DATA_gt0_20b 		=> 	TX_DATA_gt0_20b,
	 RX_DATA_gt1_20b 		=> 	RX_DATA_gt1_20b,
	 TX_DATA_gt1_20b 		=> 	TX_DATA_gt1_20b,
	 RX_DATA_gt2_20b 		=> 	RX_DATA_gt2_20b,
	 TX_DATA_gt2_20b 		=> 	TX_DATA_gt2_20b,
	 RX_DATA_gt3_20b 		=> 	RX_DATA_gt3_20b,
	 TX_DATA_gt3_20b 		=> 	TX_DATA_gt3_20b,
	 
    RXN_IN                   =>               CXP_RX_N(3 downto 0),
    RXP_IN                   =>               CXP_RX_P(3 downto 0),
    TXN_OUT                  =>               CXP_TX_N(3 downto 0),
    TXP_OUT                  =>               CXP_TX_P(3 downto 0)
);

end generate;


end Behavioral;

