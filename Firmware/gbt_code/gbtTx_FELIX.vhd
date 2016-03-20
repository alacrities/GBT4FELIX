----------------------------------------------------------------------------------
-- Company: 
-- Engineer:    Kai Chen
-- 
-- Create Date:    23:19:44 12/05/2014 
-- Design Name: 
-- Module Name:    gbtTx - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:   GBT TX top 
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
use work.FELIX_gbt_package.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gbtTx_FELIX is
  generic
    (
      channel                   : integer   := 0
      );
  Port
    ( 
      TX_FLAG                   : out std_logic;
      TX_RESET_I  	        : in  std_logic;
      TX_FRAMECLK_I 	        : in std_logic;
      TX_WORDCLK_I 	        : in std_logic;
      Tx_latopt_scr             : in std_logic;
      TX_LATOPT_TC              : in std_logic;
      TX_TC_METHOD              : in std_logic;
      DATA_MODE_CFG             : in std_logic_vector(1 downto 0);
      
      TX_TC_DLY_VALUE           : in std_logic_vector(2 downto 0); 
	
      TX_HEADER_I               : in std_logic_vector(3 downto 0);
      --TX_ISDATA_SEL_I  			: in  std_logic;
      TX_DATA_84b_I		: in  std_logic_vector(83 downto 0);
      TX_EXTRA_DATA_WIDEBUS_I 	: in  std_logic_vector(31 downto 0); 
	
      TX_DATA_20b_O	        : out std_logic_vector(19 downto 0)
    );
end gbtTx_FELIX;

architecture Behavioral of gbtTx_FELIX is
  
    
  signal Scrambler_Enable, Tx_Align_Signal, Tx_latopt_tc_i :std_logic;
  signal TX_HEADER :std_logic_vector(3 downto 0);
  signal TxExtraWidebus32b :std_logic_vector(31 downto 0);
  signal TxCommon84b :std_logic_vector(83 downto 0);
  signal TxFrame120b :std_logic_vector(119 downto 0);
  
begin

  TX_FLAG <= Scrambler_Enable;
  -- Scrambler, clock changed, ctrl signal added.
  Tx_latopt_tc_i <= '1' when TX_DLY_SW_CTRL='1' else Tx_latopt_tc;
  FelixScrambler: entity work.gbt_tx_scrambler_FELIX
    generic map
    (
      channel                                   => channel       
      )
    port map ( 
        --CTRL 
      TX_TC_METHOD                              => TX_TC_METHOD,
      Scrambler_Enable                          => Scrambler_Enable,
      Tx_Align_Signal                           => Tx_Align_Signal,
      Tx_latopt_tc                              => Tx_latopt_tc_i,-- Tx_latopt_tc,
               
      TX_RESET_I                                => TX_RESET_I,
      TX_WORDCLK_I                              => TX_WORDCLK_I,
      TX_FRAMECLK_I                             => TX_FRAMECLK_I,
      
      TX_TC_DLY_VALUE                           => TX_TC_DLY_VALUE,
        ---------------------------------------  
        --TX_ISDATA_SEL_I                            => TX_ISDATA_SEL_I,
      TX_HEADER_I                               => TX_HEADER_I,
        
      TX_HEADER_O                               => TX_HEADER,
        ---------------------------------------  
      TX_DATA_I                                 => TX_DATA_84b_I,
      TX_COMMON_FRAME_O                         => TxCommon84b,
        ---------------------------------------
      TX_EXTRA_DATA_WIDEBUS_I                   => TX_EXTRA_DATA_WIDEBUS_I,
      TX_EXTRA_FRAME_WIDEBUS_O                  => TxExtraWidebus32b
      );
  
  

  -- Encoder
  encoder: entity work.gbt_tx_encoder_FELIX
    port map (
      
      TX_HEADER_I                            => TX_HEADER,
      DATA_MODE_CFG                          => DATA_MODE_CFG,
      ---------------------------------------
      TX_COMMON_FRAME_I                      => TxCommon84b,
      TX_EXTRA_FRAME_WIDEBUS_I               => TxExtraWidebus32b,
      ---------------------------------------
      TX_FRAME_O                             => TxFrame120b
      );    

  ---- TxGearBox, control signal added,
  ---- The timing crossing is deleted. A new robust one is moved before scrambler.
  ---- Gearbox signal is latched, without latency added for GBT-FRAME Mode.

  FELIXTxGearbox: entity work.gbt_tx_gearbox_FELIX   
    generic map
    (
      channel                                   => channel       
      ) 
    port map (
      Scrambler_Enable_o     	       		=> Scrambler_Enable,
      Tx_Align_Signal     	      		=> Tx_Align_Signal,
      TX_LATOPT_SCR                             => '1',--TX_LATOPT_SCR,
      
      TX_RESET_I                             	=> TX_RESET_I,
      TX_FRAMECLK_I                          	=> TX_FRAMECLK_I,
      TX_WORDCLK_I                           	=> TX_WORDCLK_I,
      ---------------------------------------
      TX_FRAME_I                             	=> TxFrame120b,
      TX_WORD_OO                              	=> TX_DATA_20b_o
      );

end Behavioral;

