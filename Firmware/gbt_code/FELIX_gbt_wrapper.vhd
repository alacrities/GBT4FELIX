----------------------------------------------------------------------------------
-- Company:
-- Engineer: Kai Chen
--
-- Create Date:    21:33:01 12/05/2014
-- Design Name:
-- Module Name:    gbt_top - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:   The TOP MODULE FOR FELIX GBT & GTH
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;
use work.FELIX_gbt_package.all;
use work.pcie_package.all;

entity FELIX_gbt_wrapper is
  Generic (
    STABLE_CLOCK_PERIOD  : integer   := 24;  --period of the drp_clock
    GBT_NUM : integer := 24
   --QUAD_NUM : integer := 6
    );
  Port (
-------------------
---- For debug
-------------------
    -- For Latency test
    RX_FLAG_O : out std_logic_vector(GBT_NUM-1 downto 0);
    TX_FLAG_O : out std_logic_vector(GBT_NUM-1 downto 0);
    REFCLK_CXP1: out std_logic;
    REFCLK_CXP2: out std_logic;

    rst_hw : in std_logic;

-----------------------
---- Used ports
----------------------
    -- Registers
--    GTH_CTRL_REG_I        : in GTH_CTRL_REG_T;
--    GTH_STATUS_REG_O      : out GTH_STATUS_REG_T;
--    GBT_CTRL_REG_I        : in GBT_CTRL_REG_T;
--    GBT_STATUS_REG_O	    : out GBT_STATUS_REG_T;
--    GENERAL_CTRL_REG_I    : in GENERAL_CTRL_REG_T;
--    GENERAL_STATUS_REG_O  : out GENERAL_STATUS_REG_T;

    register_map_control : in    register_map_control_type;
    register_map_gbt_monitor : out     register_map_gbt_monitor_type;

    -- GTH REFCLK, DRPCLK, GREFCLK
    DRP_CLK_IN                      : in std_logic;
    Q2_CLK0_GTREFCLK_PAD_N_IN       : in std_logic;
    Q2_CLK0_GTREFCLK_PAD_P_IN       : in std_logic;
    Q8_CLK0_GTREFCLK_PAD_N_IN       : in std_logic;
    Q8_CLK0_GTREFCLK_PAD_P_IN       : in std_logic;
    GREFCLK_IN : in std_logic;

    clk40_in: in std_logic;
    clk240_in: in std_logic;
    -- for CentralRouter
    TX_120b_in : in  txrx120b_type;
    RX_120b_out : out txrx120b_type;
    FRAME_LOCKED_O: out std_logic_vector(GBT_NUM-1 downto 0);
   -- TX_ISDATA_I: in std_logic_vector(GBT_NUM-1 downto 0);
   -- RX_ISDATA_O: out std_logic_vector(GBT_NUM-1 downto 0);
   -- RX_FRAME_CLK_O : out std_logic_vector(GBT_NUM-1 downto 0);
    TX_FRAME_CLK_I : in std_logic_vector(GBT_NUM-1 downto 0);


    -- GTH Data pins
    TX_P   : out std_logic_vector(GBT_NUM-1 downto 0);
    TX_N   : out std_logic_vector(GBT_NUM-1 downto 0);
    RX_P   : in  std_logic_vector(GBT_NUM-1 downto 0);
    RX_N   : in  std_logic_vector(GBT_NUM-1 downto 0)

);
end FELIX_gbt_wrapper;

architecture Behavioral of FELIX_gbt_wrapper is

 -- constant QUAD_NUM : integer := GBT_NUM / 4;

  signal rxslide_manual, RxSlide_c, RxSlide_i: std_logic_vector(23 downto 0);
  signal rxslide_sel: std_logic_vector(23 downto 0);
  signal txusrrdy: std_logic_vector(23 downto 0);
  signal rxusrrdy: std_logic_vector(23 downto 0);
  signal gttx_reset: std_logic_vector(23 downto 0);

  signal gtrx_reset: std_logic_vector(23 downto 0);
  signal soft_reset: std_logic_vector(5 downto 0);
  signal cpll_reset: std_logic_vector(23 downto 0);
  signal qpll_reset: std_logic_vector(5 downto 0);
  signal txresetdone: std_logic_vector(23 downto 0);

  signal clk_sampled: std_logic_vector(23 downto 0);

  signal rxresetdone: std_logic_vector(23 downto 0);
  signal txfsmresetdone: std_logic_vector(23 downto 0);
  signal rxfsmresetdone: std_logic_vector(23 downto 0);
  signal cpllfbclklost: std_logic_vector(23 downto 0);
  signal cplllock: std_logic_vector(23 downto 0);
  signal rxcdrlock: std_logic_vector(23 downto 0);
  signal qplllock : std_logic_vector(5 downto 0);

  signal tx_is_data: std_logic_vector(23 downto 0);
  signal TX_RESET, TX_RESET_i: std_logic_vector(23 downto 0);

  signal RX_RESET, RX_RESET_i: std_logic_vector(23 downto 0);
  signal gbt_data_format: std_logic_vector(47 downto 0);

  SIGNAL CXP1_TX_PLL_LOCKEd, CXP2_TX_PLL_LOCKED, cpu_rst, RX_ALIGN_SW,RX_ALIGN_TB_SW: STD_logic;

  signal rx_pll_locked , outsel_i,outsel_ii,outsel_o: std_logic_vector(23 downto 0);

  signal rx_is_header, alignment_done: std_logic_vector(23 downto 0);
  signal rx_is_data: std_logic_vector(23 downto 0);
  signal RX_HEADER_FOUND: std_logic_vector(23 downto 0);

  signal cxp1_rx_bitslip_nbr, cxp2_rx_bitslip_nbr: std_logic_vector(71 downto 0);

  signal RxSlide : std_logic_vector(23 downto 0);

  signal GT_TX_WORD_CLK,TX_TC_METHOD : std_logic_vector(23 downto 0);

  type data20barray is array (0 to GBT_NUM-1) of std_logic_vector(19 downto 0);
  signal TX_DATA_20b  : data20barray := (others => ("00000000000000000000"));
  signal RX_DATA_20b  : data20barray := (others => ("00000000000000000000"));

  signal GT_RX_WORD_CLK,alignment_chk_rst_c,alignment_chk_rst_c1,alignment_chk_rst : std_logic_vector(23 downto 0);

  signal rstframeclk, alignment_chk_rst_i,rstframeclk1, rx_frame_phase_ok_cxp1, rx_frame_phase_ok_cxp2:std_logic;

  signal CXP2_GTH_REF_CLK_BUF, CXP1_GTH_REF_CLK, CXP2_GTH_REF_CLK, CXP1_GTH_REF_CLK_BUF, DESMUX_USE_SW: std_logic;
  signal counterbig, counterbig1:std_logic_vector(26 downto 0);

  signal rstframeclk_3r, rstframeclk_r, rstframeclk_2r,rstframeclk1_3r, rstframeclk1_r, rstframeclk1_2r,cxp1_tx_pll_rst,cxp2_tx_pll_rst:std_logic;
  signal SOFT_TXRST_GT, TopBot, TopBot_C,TopBot_i :std_logic_vector(23 downto 0);
  signal SOFT_RXRST_GT :std_logic_vector(23 downto 0);
  signal SOFT_TXRST_ALL :std_logic_vector(5 downto 0);
  signal SOFT_RXRST_ALL :std_logic_vector(5 downto 0);
  signal TX_OPT, RX_OPT :std_logic_vector(95 downto 0);
  SIGNAL DATA_TXFORMAT, DATA_TXFORMAT_i :std_logic_vector(47 downto 0);
  SIGNAL DATA_RXFORMAT, DATA_RXFORMAT_i :std_logic_vector(47 downto 0);

  SIGNAL OddEven, OddEven_i, OddEven_c, ext_trig_realign  :std_logic_vector(23 downto 0);



  signal General_ctrl : std_logic_vector(63 downto 0);


  signal GBT_RXSLIDE          : std_logic_vector(63 downto 0);
  signal GBT_TXUSRRDY         : std_logic_vector(63 downto 0);
  signal GBT_RXUSRRDY         : std_logic_vector(63 downto 0);  
  signal GBT_GTTX_RESET       : std_logic_vector(63 downto 0);
  signal GBT_GTRX_RESET       : std_logic_vector(63 downto 0);
  signal GBT_PLL_RESET        : std_logic_vector(63 downto 0);
  signal GBT_SOFT_TX_RESET    : std_logic_vector(63 downto 0);
  signal GBT_SOFT_RX_RESET    : std_logic_vector(63 downto 0);
  signal GBT_ODDEVEN          : std_logic_vector(63 downto 0);
  signal GBT_TOPBOT           : std_logic_vector(63 downto 0);
  signal GBT_TX_TC_DLY_VALUE1 : std_logic_vector(63 downto 0);
  signal GBT_TX_TC_DLY_VALUE2 : std_logic_vector(63 downto 0);
  signal GBT_TX_OPT           : std_logic_vector(63 downto 0);  
  signal GBT_RX_OPT           : std_logic_vector(63 downto 0);
  signal GBT_DATA_TXFORMAT    : std_logic_vector(63 downto 0);
  signal GBT_DATA_RXFORMAT    : std_logic_vector(63 downto 0);
  signal GBT_TX_RESET         : std_logic_vector(63 downto 0);
  signal GBT_RX_RESET         : std_logic_vector(63 downto 0);
  signal GBT_TX_TC_METHOD     : std_logic_vector(63 downto 0);
  signal GBT_OUTMUX_SEL       : std_logic_vector(63 downto 0);
   
  SIGNAL GBT_TXRESET_DONE     : std_logic_vector(63 downto 0);
  SIGNAL GBT_RXRESET_DONE     : std_logic_vector(63 downto 0);
  SIGNAL GBT_TXFSMRESET_DONE  : std_logic_vector(63 downto 0);
  SIGNAL GBT_RXFSMRESET_DONE  : std_logic_vector(63 downto 0);
  SIGNAL GBT_CPLL_FBCLK_LOST  : std_logic_vector(63 downto 0);
  SIGNAL GBT_PLL_LOCK         : std_logic_vector(63 downto 0);
  SIGNAL GBT_RXCDR_LOCK       : std_logic_vector(63 downto 0);
  SIGNAL GBT_CLK_SAMPLED      : std_logic_vector(63 downto 0);
  SIGNAL GBT_RX_IS_HEADER     : std_logic_vector(63 downto 0);
  SIGNAL GBT_RX_IS_DATA       : std_logic_vector(63 downto 0);
  SIGNAL GBT_RX_HEADER_FOUND  : std_logic_vector(63 downto 0);
  SIGNAL GBT_ALIGNMENT_DONE   : std_logic_vector(63 downto 0);
  SIGNAL GBT_OUT_MUX_STATUS   : std_logic_vector(63 downto 0);
  SIGNAL GBT_ERROR            : std_logic_vector(63 downto 0);
  SIGNAL GBT_GBT_TOPBOT_C     : std_logic_vector(63 downto 0);
   
  type txrx4b_24ch_type        is array (23 downto 0) of std_logic_vector(3 downto 0);
  --E
  signal RxWordCnt_out : txrx4b_24ch_type;

  SIGNAL LOGIC_RST, Mode_ctrl : std_logic_vector(63 downto 0);
  SIGNAL TX_TC_DLY_VALUE : std_logic_vector(95 downto 0);

  signal data_sel: std_logic_vector(95 downto 0);

  signal GTH_RefClk : std_logic_vector(5 downto 0);
   
  signal pulse_cnt: std_logic_vector(29 downto 0);
  signal pulse_lg : std_logic;

  signal CXP1_GTH_RefClk, CXP2_GTH_RefClk, des_rxusrclk_cxp1, des_rxusrclk_cxp2:std_logic;

  signal clksampled, des_rxusrclk, error, FSM_RST, auto_gth_rxrst, auto_gbt_rxrst, gbt_rx_reset_i, gtrx_reset_i:std_logic_vector(23 downto 0);

  signal TX_LINERATE, RX_LINERATE, GT_RXOUTCLK, GT_TXOUTCLK:std_logic_vector(23 downto 0);


begin

  FRAME_LOCKED_O <= RX_HEADER_FOUND(GBT_NUM-1 downto 0);

  GTHREFCLK_1 : if GTHREFCLK_SEL = '0' generate
    --IBUFDS_GTE2

    REFCLK_CXP1 <= CXP1_GTH_RefClk;
    REFCLK_CXP2 <= CXP2_GTH_RefClk;

    ibufds_instq2_clk0 : IBUFDS_GTE2
      port map
      (
        O               => 	CXP1_GTH_RefClk,
        ODIV2           =>    open,
        CEB             => 	'0',
        I               => 	Q2_CLK0_GTREFCLK_PAD_P_IN,
        IB              => 	Q2_CLK0_GTREFCLK_PAD_N_IN
        );  
    GTH_RefClk(0) <= CXP1_GTH_RefClk;
    GTH_RefClk(1) <= CXP1_GTH_RefClk;
    GTH_RefClk(5) <= CXP1_GTH_RefClk;
        --IBUFDS_GTE2
    ibufds_instq8_clk0 : IBUFDS_GTE2
    port map
    (
        O               => 	CXP2_GTH_RefClk,
        ODIV2           =>    open,
        CEB             => 	'0',
        I               => 	Q8_CLK0_GTREFCLK_PAD_P_IN,
        IB              => 	Q8_CLK0_GTREFCLK_PAD_N_IN
        );
    GTH_RefClk(3) <= CXP2_GTH_RefClk;
    GTH_RefClk(4) <= CXP2_GTH_RefClk;
    GTH_RefClk(2) <= CXP2_GTH_RefClk;

  end generate;

  GTHREFCLK_2 : if GTHREFCLK_SEL = '1' generate
    GTH_RefClk(0)  <= GREFCLK_IN;
    GTH_RefClk(1)  <= GREFCLK_IN;
    GTH_RefClk(2)  <= GREFCLK_IN;
    GTH_RefClk(3)  <= GREFCLK_IN;
    GTH_RefClk(4)  <= GREFCLK_IN;
    GTH_RefClk(5)  <= GREFCLK_IN;

    REFCLK_CXP1 <= GREFCLK_IN;
    REFCLK_CXP2 <= GREFCLK_IN;
  end generate;

--    GTH_CTRL_REG0 <= GTH_CTRL_REG_I(0);
--    GTH_CTRL_REG1 <= GTH_CTRL_REG_I(1);
--    GTH_CTRL_REG2 <= GTH_CTRL_REG_I(2);
--    GTH_CTRL_REG3 <= GTH_CTRL_REG_I(3);
--    GTH_CTRL_REG4 <= GTH_CTRL_REG_I(4);
--    GTH_CTRL_REG5 <= GTH_CTRL_REG_I(5);
--    GTH_CTRL_REG6 <= GTH_CTRL_REG_I(6);
--    GTH_CTRL_REG7 <= GTH_CTRL_REG_I(7);
--    GTH_STATUS_REG_O(0) <= GTH_STATUS_REG0;
--    GTH_STATUS_REG_O(1) <= GTH_STATUS_REG1;
--    GTH_STATUS_REG_O(2) <= GTH_STATUS_REG2;
--    GTH_STATUS_REG_O(3) <= GTH_STATUS_REG3;
--    GTH_STATUS_REG_O(4) <= GTH_STATUS_REG4;

--    GBT_CTRL_REG0 <= GBT_CTRL_REG_I(0);
--    GBT_CTRL_REG1 <= GBT_CTRL_REG_I(1);
--    GBT_CTRL_REG2 <= GBT_CTRL_REG_I(2);
--    GBT_CTRL_REG3 <= GBT_CTRL_REG_I(3);
--    GBT_CTRL_REG4 <= GBT_CTRL_REG_I(4);
--    GBT_CTRL_REG5 <= GBT_CTRL_REG_I(5);
--    GBT_CTRL_REG6 <= GBT_CTRL_REG_I(6);
--    GBT_CTRL_REG7 <= GBT_CTRL_REG_I(7);
--    GBT_CTRL_REG8 <= GBT_CTRL_REG_I(8);
--    GBT_STATUS_REG_O(0) <= GBT_STATUS_REG0;
--    GBT_STATUS_REG_O(1) <= GBT_STATUS_REG1;
--    GBT_STATUS_REG_O(2) <= GBT_STATUS_REG2;
--    GBT_STATUS_REG_O(3) <= GBT_STATUS_REG3;
--    GBT_STATUS_REG_O(4) <= GBT_STATUS_REG4;
--    GBT_STATUS_REG_O(5) <= GBT_STATUS_REG5;

--    LOGIC_RST <= GENERAL_CTRL_REG_I(0);
--    General_ctrl <= GENERAL_CTRL_REG_I(1);



--    GENERAL_STATUS_REG_O(0) <=  GBT_VERSION;

  --
  --
  LOGIC_RST              <= register_map_control.GBT_LOGIC_RESET;
  General_ctrl           <= register_map_control.GBT_GENERAL_CTRL;
    
  GBT_RXSLIDE(47 downto 0)            <= register_map_control.GBT_RXSLIDE.S2312 & register_map_control.GBT_RXSLIDE.S1100 & register_map_control.GBT_RXSLIDE.M2312 & register_map_control.GBT_RXSLIDE.M1100;
  GBT_TXUSRRDY(23 downto 0)           <= register_map_control.GBT_TXUSRRDY.B2312 & register_map_control.GBT_TXUSRRDY.B1100;
  GBT_RXUSRRDY(23 downto 0)           <= register_map_control.GBT_RXUSRRDY.B2312 & register_map_control.GBT_RXUSRRDY.B1100;
  GBT_GTTX_RESET(29 downto 0)         <= register_map_control.GBT_GTTX_RESET.B0503 & register_map_control.GBT_GTTX_RESET.B2312 & register_map_control.GBT_GTTX_RESET.B0200 & register_map_control.GBT_GTTX_RESET.B1100;
  GBT_GTRX_RESET(23 downto 0)         <= register_map_control.GBT_GTRX_RESET.B2312 & register_map_control.GBT_GTRX_RESET.B1100;
  GBT_PLL_RESET(29 downto 0)          <= register_map_control.GBT_PLL_RESET.B0503 & register_map_control.GBT_PLL_RESET.B2312 & register_map_control.GBT_PLL_RESET.B0200 & register_map_control.GBT_PLL_RESET.B1100;
  GBT_SOFT_TX_RESET(29 downto 0)      <= register_map_control.GBT_SOFT_TX_RESET.B0503 & register_map_control.GBT_SOFT_TX_RESET.B2312 & register_map_control.GBT_SOFT_TX_RESET.B0200 & register_map_control.GBT_SOFT_TX_RESET.B1100;
  GBT_SOFT_RX_RESET(29 downto 0)      <= register_map_control.GBT_SOFT_RX_RESET.B0503 & register_map_control.GBT_SOFT_RX_RESET.B2312 & register_map_control.GBT_SOFT_RX_RESET.B0200 & register_map_control.GBT_SOFT_RX_RESET.B1100;
    
  GBT_ODDEVEN(23 downto 0)            <= register_map_control.GBT_ODD_EVEN.B2312 & register_map_control.GBT_ODD_EVEN.B1100;
  GBT_TOPBOT(23 downto 0)             <= register_map_control.GBT_TOPBOT.B2312 & register_map_control.GBT_TOPBOT.B1100;
  GBT_TX_TC_DLY_VALUE1(47 downto 0)   <= register_map_control.GBT_TX_TC_DLY_VALUE1;
  GBT_TX_TC_DLY_VALUE2(47 downto 0)   <= register_map_control.GBT_TX_TC_DLY_VALUE2;
  GBT_TX_OPT(47 downto 0)             <= register_map_control.GBT_TX_OPT;
  GBT_RX_OPT(47 downto 0)             <= register_map_control.GBT_RX_OPT;
  GBT_DATA_TXFORMAT(47 downto 0)      <= register_map_control.GBT_DATA_TXFORMAT.B4724 & register_map_control.GBT_DATA_TXFORMAT.B2300;
  GBT_DATA_RXFORMAT(47 downto 0)      <= register_map_control.GBT_DATA_RXFORMAT.B4724 & register_map_control.GBT_DATA_RXFORMAT.B2300;
    
  GBT_TX_RESET(23 downto 0)           <= register_map_control.GBT_TX_RESET.B2312 & register_map_control.GBT_TX_RESET.B1100;
  GBT_RX_RESET(23 downto 0)           <= register_map_control.GBT_RX_RESET.B2312 & register_map_control.GBT_RX_RESET.B1100;
  GBT_TX_TC_METHOD(23 downto 0)       <= register_map_control.GBT_TX_TC_METHOD.B2312 & register_map_control.GBT_TX_TC_METHOD.B1100;
  GBT_OUTMUX_SEL(23 downto 0)         <= register_map_control.GBT_OUTMUX_SEL.B2312 & register_map_control.GBT_OUTMUX_SEL.B1100;   
 
  register_map_gbt_monitor.GBT_VERSION.DATE           <=  GBT_VERSION(63 downto 48);  
  register_map_gbt_monitor.GBT_VERSION.GBT_VERSION           <=  GBT_VERSION(23 downto 20);  
  register_map_gbt_monitor.GBT_VERSION.GTH_IP_VERSION           <=  GBT_VERSION(19 downto 16);  
  register_map_gbt_monitor.GBT_VERSION.RESERVED           <=  GBT_VERSION(15 downto 3);  
  register_map_gbt_monitor.GBT_VERSION.GTHREFCLK_SEL           <=  GBT_VERSION(2 downto 2);  
  register_map_gbt_monitor.GBT_VERSION.RX_CLK_SEL           <=  GBT_VERSION(1 downto 1);  
  register_map_gbt_monitor.GBT_VERSION.PLL_SEL           <=  GBT_VERSION(0 downto 0);  

  --
  --
  register_map_gbt_monitor.GBT_TXRESET_DONE.B1100      <= TxResetDone(11 downto 0);
  register_map_gbt_monitor.GBT_TXRESET_DONE.B2312      <= TxResetDone(23 downto 12);
  register_map_gbt_monitor.GBT_RXRESET_DONE.B1100      <= RxResetDone(11 downto 0);
  register_map_gbt_monitor.GBT_RXRESET_DONE.B2312      <= RxResetDone(23 downto 12);
  register_map_gbt_monitor.GBT_TXFSMRESET_DONE.B1100   <= TxFsmResetDone(11 downto 0);
  register_map_gbt_monitor.GBT_TXFSMRESET_DONE.B2312   <= TxFsmResetDone(23 downto 12);
  register_map_gbt_monitor.GBT_RXFSMRESET_DONE.B1100   <= RxFsmResetDone(11 downto 0);
  register_map_gbt_monitor.GBT_RXFSMRESET_DONE.B2312   <= RxFsmResetDone(23 downto 12);
  register_map_gbt_monitor.GBT_CPLL_FBCLK_LOST.B1100   <= CpllFbClkLost(11 downto 0);
  register_map_gbt_monitor.GBT_CPLL_FBCLK_LOST.B2312   <= CpllFbClkLost(23 downto 12);  
  register_map_gbt_monitor.GBT_CPLL_LOCK.B1100          <= CpllLock(11 downto 0); 
  register_map_gbt_monitor.GBT_CPLL_LOCK.B2312          <= CpllLock(23 downto 12);
  register_map_gbt_monitor.GBT_CPLL_LOCK.B0200          <= QpllLock(2 downto 0);
  register_map_gbt_monitor.GBT_CPLL_LOCK.B0503          <= QpllLock(5 downto 3);  
  register_map_gbt_monitor.GBT_RXCDR_LOCK.B1100        <= RxCdrLock(11 downto 0);
  register_map_gbt_monitor.GBT_RXCDR_LOCK.B2312        <= RxCdrLock(23 downto 12);  
  register_map_gbt_monitor.GBT_CLK_SAMPLED.B1100       <= clk_sampled(11 downto 0);
  register_map_gbt_monitor.GBT_CLK_SAMPLED.B2312       <= clk_sampled(23 downto 12);
  
  register_map_gbt_monitor.GBT_RX_IS_HEADER.B1100      <= RX_IS_HEADER(11 downto 0);
  register_map_gbt_monitor.GBT_RX_IS_HEADER.B2312      <= RX_IS_HEADER(23 downto 12);
  register_map_gbt_monitor.GBT_RX_IS_DATA.B1100        <= RX_IS_DATA(11 downto 0);
  register_map_gbt_monitor.GBT_RX_IS_DATA.B2312        <= RX_IS_DATA(23 downto 12);
  register_map_gbt_monitor.GBT_RX_HEADER_FOUND.B1100   <= RX_HEADER_FOUND(11 downto 0);
  register_map_gbt_monitor.GBT_RX_HEADER_FOUND.B2312   <= RX_HEADER_FOUND(23 downto 12);
  register_map_gbt_monitor.GBT_ALIGNMENT_DONE.B1100    <= alignment_done(11 downto 0);
  register_map_gbt_monitor.GBT_ALIGNMENT_DONE.B2312    <= alignment_done(23 downto 12);
  register_map_gbt_monitor.GBT_OUT_MUX_STATUS.B1100    <= outsel_o(11 downto 0);
  register_map_gbt_monitor.GBT_OUT_MUX_STATUS.B2312    <= outsel_o(23 downto 12);
  register_map_gbt_monitor.GBT_ERROR.B1100             <= error(11 downto 0);
  register_map_gbt_monitor.GBT_ERROR.B2312             <= error(23 downto 12);
  register_map_gbt_monitor.GBT_GBT_TOPBOT_C.B1100      <= TopBot_c(11 downto 0);
  register_map_gbt_monitor.GBT_GBT_TOPBOT_C.B2312      <= TopBot_c(23 downto 12);








----------------------------------------
------ REGISTERS MAPPING
----------------------------------------
  alignment_chk_rst_i <= General_ctrl(0);


  DESMUX_USE_SW <= register_map_control.GBT_MODE_CTRL.DESMUX_USE_SW(0); --Mode_ctrl(0);
  RX_ALIGN_SW <= register_map_control.GBT_MODE_CTRL.RX_ALIGN_SW(1); --Mode_ctrl(1);
  RX_ALIGN_TB_SW <= register_map_control.GBT_MODE_CTRL.RX_ALIGN_TB_SW(2); --Mode_ctrl(2);


---- Bit slip register: address 0ffset + 0x80
  RxSlide_Manual(11 downto 0)   <= GBT_RXSLIDE(11 downto 0); -- Default: 0x000
  RxSlide_Manual(23 downto 12)  <= GBT_RXSLIDE(23 downto 12); -- Default: 0x000
  RxSlide_Sel(11 downto 0)      <= GBT_RXSLIDE(35 downto 24); -- Default: 0x000
  RxSlide_Sel(23 downto 12)     <= GBT_RXSLIDE(47 downto 36); -- Default: 0x000

---- Tx User Ready register: address 0ffset + 0x90
  TxUsrRdy(11 downto 0)         <= GBT_TXUSRRDY(11 downto 0); ---- Default: 0xFFF
  TxUsrRdy(23 downto 12)        <= GBT_TXUSRRDY(23 downto 12); ---- Default: 0xFFF

---- Rx User Ready register: address 0ffset + 0xA0
  RxUsrRdy(11 downto 0)         <= GBT_RXUSRRDY(11 downto 0); ---- Default: 0xFFF
  RxUsrRdy(23 downto 12)        <= GBT_RXUSRRDY(23 downto 12); ---- Default: 0xFFF

---- SOFT RESET & GTH TX RESET register: address 0ffset + 0xB0
  GTTX_RESET(11 downto 0)       <= GBT_GTTX_RESET(11 downto 0); -- Default: 0b000
  GTTX_RESET(23 downto 12)      <= GBT_GTTX_RESET(26 downto 15); -- Default: 0b000
  SOFT_RESET(2 downto 0)        <= GBT_GTTX_RESET(14 downto 12);  -- Default: 0b000
  SOFT_RESET(5 downto 3)        <= GBT_GTTX_RESET(29 downto 27);  -- Default: 0b000

---- GTH RX RESET register: address 0ffset + 0xC0
  GTRX_RESET(11 downto 0)       <= GBT_GTRX_RESET(11 downto 0); -- Default: 0b000
  GTRX_RESET(23 downto 12)      <= GBT_GTRX_RESET(23 downto 12); -- Default: 0b000
 
---- CPLL QPLL RESET register: address 0ffset + 0xD0
  CPLL_RESET(11 downto 0)       <= GBT_PLL_RESET(11 downto 0); -- Default: 0b000
  CPLL_RESET(23 downto 12)      <= GBT_PLL_RESET(26 downto 15); -- Default: 0b000
  QPLL_RESET(2 downto 0)        <= GBT_PLL_RESET(14 downto 12);  -- Default: 0b000
  QPLL_RESET(5 downto 3)        <= GBT_PLL_RESET(29 downto 27); -- Default: 0b000

---- SOFT TX RESET register: address 0ffset + 0xE0
  SOFT_TXRST_GT(11 downto 0)    <= GBT_SOFT_TX_RESET(11 downto 0);  -- Default: 0b000
  SOFT_TXRST_GT(23 downto 12)   <= GBT_SOFT_TX_RESET(26 downto 15); -- Default: 0b000
  SOFT_TXRST_ALL(2 downto 0)    <= GBT_SOFT_TX_RESET(14 downto 12);
  SOFT_TXRST_ALL(5 downto 3)    <= GBT_SOFT_TX_RESET(29 downto 27);

---- SOFT RX RESETregister: address 0ffset + 0xF0
  SOFT_RXRST_GT(11 downto 0)    <= GBT_SOFT_RX_RESET(11 downto 0);  -- Default: 0b000
  SOFT_RXRST_GT(23 downto 12)   <= GBT_SOFT_RX_RESET(26 downto 15); -- Default: 0b000
  SOFT_RXRST_ALL(2 downto 0)    <= GBT_SOFT_RX_RESET(14 downto 12);
  SOFT_RXRST_ALL(5 downto 3)    <= GBT_SOFT_RX_RESET(29 downto 27);

---- ODDEVEN register: address 0ffset + 0x100
  OddEven(11 downto 0)  <= GBT_ODDEVEN(11 downto 0);
  OddEven(23 downto 12) <= GBT_ODDEVEN(23 downto 12);

---- TOPBOT register: address 0ffset + 0x110
  TopBot(23 downto 12)  <= GBT_TOPBOT(23 downto 12);
  TopBot(11 downto 0)   <= GBT_TOPBOT(11 downto 0);

-- Tx Timedomain crossing phase selection :address 0ffset + 0x120 & 0x130
  TX_TC_DLY_VALUE(47 downto 0) <= GBT_TX_TC_DLY_VALUE1(47 DOWNTO 0);
  TX_TC_DLY_VALUE(95 downto 48) <= GBT_TX_TC_DLY_VALUE2(47 DOWNTO 0);

  --Adjust the Tx Optimization Selection
  TX_OPT(47 downto 0)   <= GBT_TX_OPT(47 DOWNTO 0);  --
  --Adjust the Rx Optimization Selection
  RX_OPT(47 downto 0)   <= GBT_RX_OPT(47 DOWNTO 0);  --
  -- GBT-FRAME, WIDEBUS, FELIX_8B10B for Tx
  DATA_TXFORMAT(23 downto 0)        <= GBT_DATA_TXFORMAT(23 DOWNTO 0);  --
  DATA_TXFORMAT(47 downto 24)       <= GBT_DATA_TXFORMAT(47 DOWNTO 24);  --
  -- GBT-FRAME, WIDEBUS, FELIX_8B10B for Rx
  DATA_RXFORMAT(23 downto 0)        <= GBT_DATA_RXFORMAT(23 DOWNTO 0);  --
  DATA_RXFORMAT(47 downto 24)       <= GBT_DATA_RXFORMAT(47 DOWNTO 24);  --

  -- GBT Tx LOGIC RESET
  TX_RESET(11 downto 0)             <= GBT_TX_RESET(11 DOWNTO 0);
  TX_RESET(23 downto 12)            <= GBT_TX_RESET(23 DOWNTO 12);
  -- GBT Rx LOGIC RESET                 
  RX_RESET(11 downto 0)             <= GBT_RX_RESET(11 DOWNTO 0);
  RX_RESET(23 downto 12)            <= GBT_RX_RESET(23 DOWNTO 12);


  -- Tx time domain crossing method sel
  TX_TC_METHOD(11 downto 0)             <= GBT_TX_TC_METHOD(11 DOWNTO 0);
  TX_TC_METHOD(23 downto 12)            <= GBT_TX_TC_METHOD(23 DOWNTO 12);
  -- descrambler output MUX selection
  outsel_i(11 downto 0)                 <= GBT_OUTMUX_SEL(11 DOWNTO 0);
  outsel_i(23 downto 12)                <= GBT_OUTMUX_SEL(23 DOWNTO 12);
  
  -------


--  GBT_TXRESET_DONE(11 downto 0)         <= TxResetDone(11 downto 0);  --- Normal Value: 0xFFF
--  GBT_TXRESET_DONE(27 downto 16)        <= TxResetDone(23 downto 12); --- Normal Value: 0xFFF
                                        
--  GBT_RXRESET_DONE(11 downto 0)         <= RxResetDone(11 downto 0); --- Normal Value: 0xFFF
--  GBT_RXRESET_DONE(27 downto 16)        <= RxResetDone(23 downto 12); --- Normal Value: 0xFFF

--  GBT_TXFSMRESET_DONE(11 downto 0)      <= TxFsmResetDone(11 downto 0); --- Normal Value: 0xFFF
--  GBT_TXFSMRESET_DONE(27 downto 16)     <= TxFsmResetDone(23 downto 12); --- Normal Value: 0xFFF
  
--  GBT_RXFSMRESET_DONE(11 downto 0)      <= RxFsmResetDone(11 downto 0); --- Normal Value: 0xFFF
--  GBT_RXFSMRESET_DONE(27 downto 16)     <= RxFsmResetDone(23 downto 12); --- Normal Value: 0xFFF

--  GBT_CPLL_FBCLK_LOST(11 downto 0)      <=  CpllFbClkLost(11 downto 0); --- Normal Value: 0x000
--  GBT_CPLL_FBCLK_LOST(27 downto 16)     <= CpllFbClkLost(23 downto 12); --- Normal Value: 0x000
  
--  GBT_PLL_LOCK(11 downto 0)            <= CpllLock(11 downto 0); --- Normal Value: 0xFFF
--  GBT_PLL_LOCK(27 downto 16)           <= CpllLock(23 downto 12); --- Normal Value: 0xFFF
--  GBT_PLL_LOCK(14 downto 12)           <= QpllLock(2 downto 0); --- Normal Value: 0b111
--  GBT_PLL_LOCK(30 downto 28)           <= QpllLock(5 downto 3); --- Normal Value: 0b111

--  GBT_RXCDR_LOCK(11 downto 0)           <= RxCdrLock(11 downto 0);  --- Normal Value: 0xFFF

--  GBT_RXCDR_LOCK(27 downto 16)          <= RxCdrLock(23 downto 12);  --- Normal Value: 0xFFF


--  GBT_CLK_SAMPLED(11 DOWNTO 0)          <= clk_sampled(11 downto 0);
--  GBT_CLK_SAMPLED(27 DOWNTO 16)         <= clk_sampled(23 downto 12);

--  GBT_RX_IS_HEADER(11 downto 0)         <= RX_IS_HEADER(11 downto 0);
--  GBT_RX_IS_HEADER(27 downto 16)        <= RX_IS_HEADER(23 downto 12);

--  GBT_RX_IS_DATA(11 downto 0)           <= RX_IS_DATA(11 downto 0);
--  GBT_RX_IS_DATA(27 downto 16)          <= RX_IS_DATA(23 downto 12);
  
--  GBT_RX_HEADER_FOUND(11 downto 0)      <= RX_HEADER_FOUND(11 downto 0);
--  GBT_RX_HEADER_FOUND(27 downto 16)     <= RX_HEADER_FOUND(23 downto 12);

--  GBT_ALIGNMENT_DONE(11 downto 0)       <= alignment_done(11 downto 0);
--  GBT_ALIGNMENT_DONE(27 downto 16)      <= alignment_done(23 downto 12);

--  GBT_OUT_MUX_STATUS(11 downto 0)       <= outsel_o(11 downto 0);
--  GBT_OUT_MUX_STATUS(27 downto 16)      <= outsel_o(23 downto 12);

--  GBT_ERROR(11 downto 0)                <= error(11 downto 0);
--  GBT_ERROR(27 downto 16)               <= error(23 downto 12);
  
--  GBT_GBT_TOPBOT_C(11 downto 0)         <= TopBot_c(11 downto 0);
--  GBT_GBT_TOPBOT_C(27 downto 16)        <= TopBot_c(23 downto 12);

  --GBT_STATUS_REG4(15 downto 0) <=RxWordCnt_out(3) & RxWordCnt_out(2) & RxWordCnt_out(1) & RxWordCnt_out(0);


  datamod_gen1 : if DYNAMIC_DATA_MODE_EN='1' generate
    DATA_TXFORMAT_i <= DATA_TXFORMAT;
    DATA_RXFORMAT_i <= DATA_RXFORMAT;
  end generate;

  datamod_gen2 : if DYNAMIC_DATA_MODE_EN='0' generate
    DATA_TXFORMAT_i <= GBT_DATA_TXFORMAT_PACKAGE;
    DATA_RXFORMAT_i <= GBT_DATA_RXFORMAT_PACKAGE;
  end generate;


  process(clk40_in)
  begin
    if clk40_in'event and clk40_in='1' then
      pulse_lg <= pulse_cnt(29);
      if pulse_cnt(29)='1' then
        pulse_cnt <=(others=>'0');
      else    
        pulse_cnt <= pulse_cnt+'1';
      end if;
    end if;
  end process;


  rxalign_auto : for i in GBT_NUM-1 downto 0 generate
 
    auto_rxrst : entity work.FELIX_GBT_RX_AUTO_RST
      port map
      (
        FSM_CLK                 => clk40_in,
        pulse_lg                => pulse_lg,
        GTHRXRESET_DONE         => RxResetDone(i) and RxFsmResetDone(i),
        alignment_chk_rst       => alignment_chk_rst_c1(i),
        GBT_LOCK                => alignment_done(i),
        AUTO_GTH_RXRST          => auto_gth_rxrst(i),
        ext_trig_realign        => ext_trig_realign(i),
        AUTO_GBT_RXRST          => auto_gbt_rxrst(i)
        );
  
  
  

    rafsm : entity work.FELIX_GBT_RX_ALIGN_FSM
      port map
      (
        ext_trig_realign        => ext_trig_realign(i),
        TB_SEL                  => RX_ALIGN_TB_SW,
        TB_SW                   => TopBot(i),
        FSM_RST                 => FSM_RST(i),
        FSM_CLK                 => clk40_in,
        OddEven                 => OddEven_c(i),
        TopBot                  => TopBot_c(i),
        GBT_LOCK                => alignment_done(i),
        RxSlide                 => RxSlide_c(i),
        clk_sampled             => clk_sampled(i),
        alignment_chk_rst       => alignment_chk_rst_c(i),
        RX_ALIGN_SW             => RX_ALIGN_SW
        );

    FSM_RST(i) <= RX_RESET(i) or RX_ALIGN_SW;
    GTRX_RESET_i(i) <= GTRX_RESET(i) when RX_ALIGN_SW='1' else
                       (GTRX_RESET(i) or auto_gth_rxrst(i));
    RX_RESET_i(i) <= RX_RESET(i) when RX_ALIGN_SW='1' else
                     (RX_RESET(i) or auto_gbt_rxrst(i));
    alignment_chk_rst(i) <= alignment_chk_rst_i when RX_ALIGN_SW='1' else
                            (alignment_chk_rst_i or alignment_chk_rst_c(i) or alignment_chk_rst_c1(i));
	
    TX_RESET_i(i) <= TX_RESET(i) or (not TxResetDone(i)) or (not TxFsmResetDone(i));
  end generate;




  outsel_ii <= outsel_o when DESMUX_USE_SW = '0' else
               outsel_i;

  OddEven_i <= OddEven_c when RX_ALIGN_SW ='0' else
               OddEven;

  TopBot_i <= TopBot_c when RX_ALIGN_SW='0' else --and RX_ALIGN_TB_SW='0'  else
              TopBot;

  RxSlide_i <= RxSlide_c when RX_ALIGN_SW='0' else
               RxSlide_Manual;


  gbtRxTx : for i in GBT_NUM-1 downto 0 generate

    gbtTxRx_inst: entity work.gbtTxRx_FELIX
      generic map
      (
        channel => i
        )

      port map
      (
        error_o                 => error(i),
        RX_FLAG                 => RX_FLAG_O(i),
        TX_FLAG                 => TX_FLAG_O(i),

        Tx_DATA_FORMAT          => DATA_TXFORMAT_i(2*i+1 downto 2*i),
        Rx_DATA_FORMAT          => DATA_RXFORMAT_i(2*i+1 downto 2*i),

        Tx_latopt_tc            => TX_OPT(i),
        Tx_latopt_scr           => TX_OPT(24+i),
        RX_LATOPT_DES           => RX_OPT(i),

        TX_TC_METHOD            => TX_TC_METHOD(i),
        TX_TC_DLY_VALUE  	=> TX_TC_DLY_VALUE(4*i+2 downto 4*i),

        alignment_chk_rst       => alignment_chk_rst(i),
        alignment_done_O        => alignment_done(i),
        L40M                    => clk40_in,
        outsel_i                => outsel_ii(i),
        outsel_o                => outsel_o(i),

        BITSLIP_MANUAL	        => RxSlide_i(i),
        BITSLIP_SEL 	        => RxSlide_Sel(i),
        GT_RXSLIDE		=> RxSlide(i),
        OddEven			=> OddEven_i(i),
        TopBot                  => TopBot_i(i),
        data_sel                => data_sel(4*i+3 downto 4*i),

        TX_RESET_I 		=> TX_RESET_i(i),
        TX_FRAMECLK_I	        => TX_FRAME_CLK_I(i),
        TX_WORDCLK_I 	        => GT_TX_WORD_CLK(i),
       -- TX_ISDATA_SEL_I	=> TX_IS_DATA(i),
        TX_DATA_120b_I	        => TX_120b_in(i),
        TX_DATA_20b_O	        => TX_DATA_20b(i),

        RX_RESET_I  		=> RX_RESET_i(i),
        RX_FRAME_CLK_O 		=> open,--RX_FRAME_CLK_O(i),
        RX_WORD_IS_HEADER_O     => RX_IS_HEADER(i),
        RX_HEADER_FOUND	        => RX_HEADER_FOUND(i),
        RX_ISDATA_FLAG_O        => RX_IS_DATA(i),
        RX_DATA_20b_I    	=> RX_DATA_20b(i),
        RX_DATA_120b_O    	=> RX_120b_out(i),
        des_rxusrclk            => GT_RX_WORD_CLK(i),
        RX_WORDCLK_I      	=> GT_RX_WORD_CLK(i)

        );

  end generate;



 

-------------------------------
------ GTH TOP WRAPPER
-------------------------------

  GTH_inst : for i in (GBT_NUM-1)/4 downto 0 generate
    GTH_TOP_INST: entity work.gth_top
      generic map
      (

        STABLE_CLOCK_PERIOD           => STABLE_CLOCK_PERIOD
        )
      Port map
      (

--------- Registers in & out

        gt_txresetdone_out         => TxResetDone(4*i+3 downto 4*i),
        gt_rxresetdone_out         => RxResetDone(4*i+3 downto 4*i),

        gt_txfsmresetdone_out      => TxFsmResetDone(4*i+3 downto 4*i),
        gt_rxfsmresetdone_out      => RxFsmResetDone(4*i+3 downto 4*i),

        gt_cpllfbclklost_out       => CpllFbClkLost(4*i+3 downto 4*i),
        gt_cplllock_out            => CpllLock(4*i+3 downto 4*i),

        gt_rxcdrlock_out           => RxCdrLock(4*i+3 downto 4*i),
        gt_qplllock_out            => QpllLock(i),
---------------------------
---- CTRL signals
---------------------------
        gt_rxslide_in              => RxSlide(4*i+3 downto 4*i),
        gt_txuserrdy_in            => TxUsrRdy(4*i+3 downto 4*i),
        gt_rxuserrdy_in            => RxUsrRdy(4*i+3 downto 4*i),

----------------------------------------------------------------
----------RESET SIGNALs
----------------------------------------------------------------

        SOFT_RESET_IN              => SOFT_RESET(i) or rst_hw,
        GTTX_RESET_IN              => GTTX_RESET(4*i+3 downto 4*i),
        GTRX_RESET_IN              => GTRX_RESET_i(4*i+3 downto 4*i),
        CPLL_RESET_IN              => CPLL_RESET(4*i+3 downto 4*i),
        QPLL_RESET_IN              => QPLL_RESET(i),

        SOFT_TXRST_GT              => SOFT_TXRST_GT(4*i+3 downto 4*i),
        SOFT_RXRST_GT              => SOFT_RXRST_GT(4*i+3 downto 4*i),
        SOFT_TXRST_ALL             => SOFT_TXRST_ALL(i) or rst_hw,
        SOFT_RXRST_ALL             => SOFT_RXRST_ALL(i),

---------- Clocks
        DRP_CLK_IN                 => DRP_CLK_IN,

        GTH_RefClk                 => GTH_RefClk(i),

        gt3_rxoutclk_out           => GT_RXOUTCLK(4*i+3),
        gt2_rxoutclk_out           => GT_RXOUTCLK(4*i+2),
        gt1_rxoutclk_out           => GT_RXOUTCLK(4*i+1),
        gt0_rxoutclk_out           => GT_RXOUTCLK(4*i),


        gt3_txoutclk_out           => GT_TXOUTCLK(4*i+3),
        gt2_txoutclk_out           => GT_TXOUTCLK(4*i+2),
        gt1_txoutclk_out           => GT_TXOUTCLK(4*i+1),
        gt0_txoutclk_out           => GT_TXOUTCLK(4*i),

        gt3_rxusrclk_in            => GT_RX_WORD_CLK(4*i+3),
        gt2_rxusrclk_in            => GT_RX_WORD_CLK(4*i+2),
        gt1_rxusrclk_in            => GT_RX_WORD_CLK(4*i+1),
        gt0_rxusrclk_in            => GT_RX_WORD_CLK(4*i),


        gt3_txusrclk_in            => GT_TX_WORD_CLK(4*i+3),
        gt2_txusrclk_in            => GT_TX_WORD_CLK(4*i+2),
        gt1_txusrclk_in            => GT_TX_WORD_CLK(4*i+1),
        gt0_txusrclk_in            => GT_TX_WORD_CLK(4*i),


---------- DATA
        RX_DATA_gt0_20b            => RX_DATA_20b(4*i),
        TX_DATA_gt0_20b            => TX_DATA_20b(4*i),
        RX_DATA_gt1_20b            => RX_DATA_20b(4*i+1),
        TX_DATA_gt1_20b            => TX_DATA_20b(4*i+1),
        RX_DATA_gt2_20b            => RX_DATA_20b(4*i+2),
        TX_DATA_gt2_20b            => TX_DATA_20b(4*i+2),
        RX_DATA_gt3_20b            => RX_DATA_20b(4*i+3),
        TX_DATA_gt3_20b            => TX_DATA_20b(4*i+3),

--------- GTH Data pins
        CXP_TX_P                   => TX_P(4*i+3 downto 4*i),
        CXP_TX_N                   => TX_N(4*i+3 downto 4*i),
        CXP_RX_P                   => RX_P(4*i+3 downto 4*i),
        CXP_RX_N                   => RX_N(4*i+3 downto 4*i)

        );


  end generate;


  usrclk_inst : for i in (GBT_NUM-1)/4 downto 0 generate
    gthusrclk_gen: entity work.gth_usrclk_gen
      port map
      (

        GTREFCLK_IN            => GTH_RefClk(i),
        clksample              => clk_sampled(4*i+3 downto 4*i),
        L240M_RX               => clk240_in, --L240M_RX(i),
        L240M_TX               => clk240_in,

        GT0_TXUSRCLK_OUT       => GT_TX_WORD_CLK(4*i),
        GT0_TXOUTCLK_IN        => GT_TXOUTCLK(4*i),

        GT1_TXUSRCLK_OUT       => GT_TX_WORD_CLK(4*i+1),
        GT1_TXOUTCLK_IN        => GT_TXOUTCLK(4*i+1),

        GT2_TXUSRCLK_OUT       => GT_TX_WORD_CLK(4*i+2),
        GT2_TXOUTCLK_IN        => GT_TXOUTCLK(4*i+2),

        GT3_TXUSRCLK_OUT       => GT_TX_WORD_CLK(4*i+3),
        GT3_TXOUTCLK_IN        => GT_TXOUTCLK(4*i+3),

        GT0_RXUSRCLK_OUT       => GT_RX_WORD_CLK(4*i),
        GT0_RXOUTCLK_IN        => GT_RXOUTCLK(4*i),

        GT1_RXUSRCLK_OUT       => GT_RX_WORD_CLK(4*i+1),
        GT1_RXOUTCLK_IN        => GT_RXOUTCLK(4*i+1),

        GT2_RXUSRCLK_OUT       => GT_RX_WORD_CLK(4*i+2),
        GT2_RXOUTCLK_IN        => GT_RXOUTCLK(4*i+2),

        GT3_RXUSRCLK_OUT       => GT_RX_WORD_CLK(4*i+3),
        GT3_RXOUTCLK_IN        => GT_RXOUTCLK(4*i+3)

        );
  end generate;

end Behavioral;
