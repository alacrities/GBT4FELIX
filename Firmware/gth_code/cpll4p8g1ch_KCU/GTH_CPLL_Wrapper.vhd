----------------------------------------------------------------------------------
-- Company:   BNL
-- Engineer:   Kai Chen
-- 
-- Create Date: 02/24/2016 03:08:01 AM
-- Design Name: 
-- Module Name: GTH_Wrapper - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity GTH_Wrapper is
  Port ( 
  
     gthrxn_in                              : in std_logic_vector(0 downto 0);
     gthrxp_in                              : in std_logic_vector(0 downto 0);
     gthtxn_out                             : out std_logic_vector(0 downto 0);
     gthtxp_out                             : out std_logic_vector(0 downto 0);
     
     drpclk_in                              : in std_logic_vector(0 downto 0);
     gtrefclk0_in                           : in std_logic_vector(0 downto 0);
     
     
     userdata_tx_in                         : in std_logic_vector(19 downto 0);
     userdata_rx_out                        : out std_logic_vector(19 downto 0);
     

     userclk_rx_reset_in                  : in std_logic_vector(0 downto 0);
     userclk_tx_reset_in                  : in std_logic_vector(0 downto 0);
    
    -- reset_clk_freerun_in                    : in std_logic_vector(0 downto 0);
     reset_all_in                            : in std_logic_vector(0 downto 0);
     reset_tx_pll_and_datapath_in            : in std_logic_vector(0 downto 0);
     reset_tx_datapath_in                    : in std_logic_vector(0 downto 0);
     reset_rx_pll_and_datapath_in            : in std_logic_vector(0 downto 0);
     reset_rx_datapath_in                    : in std_logic_vector(0 downto 0);
    
  
     rxslide_in                              : in std_logic_vector(0 downto 0);

     local_rx_240m_in                        : in std_logic_vector(0 downto 0);     
     txusrclk_out                            : out std_logic_vector(0 downto 0);
     RX_OUT_CLK                              : out std_logic_vector(0 downto 0);
     
     rxpmaresetdone_out                      : out std_logic_vector(0 downto 0);
     txpmaresetdone_out                      : out std_logic_vector(0 downto 0);
     
     reset_tx_done_out                       : out std_logic_vector(0 downto 0);
     reset_rx_done_out                       : out std_logic_vector(0 downto 0);
     reset_rx_cdr_stable_out                 : out std_logic_vector(0 downto 0)
  
  
  
  
  );
end GTH_Wrapper;

architecture Behavioral of GTH_Wrapper is


signal rxusrclk,txoutclk_int,rxoutclk_int,rxusrclk_int,rxusrclk2_int,txusrclk_int,txusrclk2_int,userclk_tx_active_out,userclk_rx_active_out,userclk_rx_active_out_p,userclk_tx_active_out_p: std_logic_vector(0 downto 0);
signal txusrclk:std_logic;
COMPONENT gtwizard_ultrascale_single_channel_cpll
  PORT (
    gtwiz_userclk_tx_active_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_rx_active_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_tx_reset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_tx_start_user_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_tx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_tx_error_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_clk_freerun_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_all_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_pll_and_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_pll_and_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_cdr_stable_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userdata_tx_in : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
    gtwiz_userdata_rx_out : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
    drpclk_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthrxn_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthrxp_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtrefclk0_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxslide_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxusrclk_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxusrclk2_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    txusrclk_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    txusrclk2_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthtxn_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthtxp_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxoutclk_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxpmaresetdone_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    txoutclk_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    txpmaresetdone_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;
begin

  -- RxUsrClk
  rxusrclk     <= local_rx_240m_in;
  rxusrclk_int  <= rxusrclk;
  rxusrclk2_int <= rxusrclk;
  
  RX_OUT_CLK <= rxoutclk_int;--(0 downto 0);
  
  -- TxUsrClk
  tx_usrclk_bufg: bufg_gt
  port map(
    i => txoutclk_int(0),
    div =>"000",
    clr =>'0',--userclk_tx_reset_in,--'0',
    cemask =>'0',
    clrmask=>'0',
    ce=>'1',
    o => txusrclk
  );
  
  txusrclk_int(0)  <= txusrclk;
  txusrclk2_int(0) <= txusrclk;
  txusrclk_out(0)  <= txusrclk;

  process(userclk_tx_reset_in(0), txusrclk)
  begin
    if userclk_tx_reset_in(0) = '1' then
      userclk_tx_active_out(0) <= '0';
    elsif txusrclk'event and txusrclk = '1' then
      userclk_tx_active_out_p(0) <= '1';
      userclk_tx_active_out <= userclk_tx_active_out_p;
    end if;
  end process;
  
  process(userclk_rx_reset_in(0), rxusrclk(0))
  begin
    if userclk_rx_reset_in(0) = '1' then
      userclk_rx_active_out(0) <= '0';
    elsif rxusrclk(0)'event and rxusrclk(0) = '1' then
      userclk_rx_active_out_p(0) <= '1';
      userclk_rx_active_out <= userclk_rx_active_out_p;
    end if;
  end process;
 
  gtwizard_ultrascale_single_channel_cpll_inst: gtwizard_ultrascale_single_channel_cpll  
  port map(
   gthrxn_in                               => gthrxn_in,
   gthrxp_in                               => gthrxp_in,
   gthtxn_out                              => gthtxn_out,
   gthtxp_out                              => gthtxp_out,
   
   gtwiz_userclk_tx_active_in              => userclk_tx_active_out,
   gtwiz_userclk_rx_active_in              => userclk_rx_active_out,
   gtwiz_buffbypass_tx_reset_in            => "0",--buffbypass_tx_reset_in,
   gtwiz_buffbypass_tx_start_user_in       => "0",--buffbypass_tx_start_user_in,
   gtwiz_buffbypass_tx_done_out            => open,--buffbypass_tx_done_out,
   gtwiz_buffbypass_tx_error_out           => open,--buffbypass_tx_error_out,
   
   gtwiz_reset_clk_freerun_in              => drpclk_in,--gtwiz_reset_clk_freerun_in,
   
   gtwiz_reset_all_in                      => reset_all_in,
   
   gtwiz_reset_tx_pll_and_datapath_in      => reset_tx_pll_and_datapath_in,
   gtwiz_reset_tx_datapath_in              => reset_tx_datapath_in,
   gtwiz_reset_rx_pll_and_datapath_in      => reset_rx_pll_and_datapath_in,
   gtwiz_reset_rx_datapath_in              => reset_rx_datapath_in,
   
   gtwiz_reset_rx_cdr_stable_out           => reset_rx_cdr_stable_out,
   gtwiz_reset_tx_done_out                 => reset_tx_done_out,
   gtwiz_reset_rx_done_out                 => reset_rx_done_out,
   
   gtwiz_userdata_tx_in                    => userdata_tx_in,
   gtwiz_userdata_rx_out                   => userdata_rx_out,
   
   drpclk_in                               => drpclk_in,
   gtrefclk0_in                            => gtrefclk0_in,
   rxusrclk_in                             => rxusrclk_int,
   rxusrclk2_in                            => rxusrclk2_int,
   txusrclk_in                             => txusrclk_int,
   txusrclk2_in                            => txusrclk2_int,
   rxoutclk_out                            => rxoutclk_int,
   rxslide_in                              => rxslide_in,
   rxpmaresetdone_out                      => rxpmaresetdone_out,
   txoutclk_out                            => txoutclk_int,
   txpmaresetdone_out                      => txpmaresetdone_out
);

end Behavioral;
