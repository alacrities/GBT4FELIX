----------------------------------------------------------------------------------
-- Company: 
-- Engineer:    Kai Chen
-- 
-- Create Date:    23:54:10 12/05/2014 
-- Design Name: 
-- Module Name:    gbtRx - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:   the FELIX GBT Rx Top-Level file
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.FELIX_gbt_package.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gbtRx_FELIX is
  Port
    ( 
      RX_FRAME_CLK_O 		: out std_logic;
      RX_FLAG ,error            : out std_logic;
    --  RxWordCnt_out : out std_logic_vector(2 downto 0);
      RX_RESET_I  		: in  std_logic;
      data_sel                  : in std_logic_vector(3 downto 0);
      RX_LATOPT_DES             : in  std_logic;
      RX_WORDCLK_I 		: in  std_logic;
      des_rxusrclk              : in std_logic;
     -- L40M : in std_logic;
      OddEven, TopBot	        : in  std_logic;
      HeaderFlag 	        : out std_logic;  --For 40MHz generation
      header_found     	        : out std_logic;
      Rx_Data_Format            : in std_logic_vector(1 downto 0);
      
      RX_ISDATA_FLAG_O          : out std_logic;
    
      RX_DATA_20b_I             : in  std_logic_vector(19 downto 0);	
      
      RX_HEADER_O               : out std_logic_vector(3 downto 0);
      	
      RX_DATA_84b_O             : out std_logic_vector(83 downto 0);
      RX_EXTRA_DATA_WIDEBUS_O   : out std_logic_vector(31 downto 0)
      );

end gbtRx_FELIX;

architecture Behavioral of gbtRx_FELIX is

   
  signal Rx_40M_FrameClk, Rx_240M_WordClk,data_valid_i           : std_logic;
  signal RxIsData             		: std_logic;
  signal RxCommon84b            	: std_logic_vector(83 downto 0);
  signal RxExtraWidebus32b      	: std_logic_vector(31 downto 0);     
  signal Descrambler_enable, Descrambler_enable_r    ,error_i   ,error_buf         : std_logic;
  signal RxFrame120b : std_logic_vector(119 downto 0);
  signal RX_HEADER_r, RX_HEADER: std_logic_vector(3 downto 0);
  signal cnta:std_logic_vector(2 downto 0);
  signal HeaderLocked_5r, HeaderLocked_4r, HeaderLocked_3r, HeaderLocked_2r, HeaderLocked_r, HeaderLocked,Rx_40M_FrameClk_A:std_logic;
   
begin

  RX_FLAG <= Descrambler_enable;
	
  ---- RxGearBox for Felix
  Rx_240M_WordClk <= RX_WORDCLK_I;
 
  RX_FRAME_CLK_O <= Rx_40M_FrameClk;--Rx_40M_FrameClk;


  FelixRxGearbox: entity work.gbt_rx_gearbox_FELIX
    
    port map
    (
                      -- RxWordCnt_out => RxWordCnt_out,
                         ---- Ctrl & Status
      OddEven                   => OddEven,
      TopBot                    => TopBot,
      HeaderFlag                => HeaderFlag,
      HeaderLocked              => HeaderLocked,
      Descrambler_enable        => Descrambler_enable,
      Rx_40M_FrameClk_O         => Rx_40M_FrameClk,
      Rx_240M_WordClk_I         => Rx_240M_WordClk,
      RX_ISDATA_FLAG_O          => RxIsData,
      RX_LATOPT_DES             => RX_LATOPT_DES,
      Rx_Data_Format            => Rx_Data_Format,
      ---- Data in & out
      Rx_Word_In                => RX_DATA_20b_I,
      Rx_Frame_O                => RxFrame120b
      );  
    
   	  

  
  ---- Decoder, some unused signals, ports is removed
  Decoder: entity work.gbt_rx_decoder_FELIX 
    port map
    (
      --RX_ISDATA_FLAG_O                       => RxIsData,
      --RX_HEADER_LOCKED_FLAG                  => HeaderLocked,
      RX_HEADER                                 => RX_HEADER,
      Rx_240M_WordClk_I                         => Rx_240M_WordClk,
      error                                     => error_i,
      ---------------------------------------
      RX_FRAME_I                                => RxFrame120b,
      DATA_MODE_CFG                             => Rx_Data_Format,
      ---------------------------------------
      RX_COMMON_FRAME_O                         => RxCommon84b,
      RX_EXTRA_FRAME_WIDEBUS_O                  => RxExtraWidebus32b        
      ); 
      
 -- data_valid <= data_valid_i;
  
  process(des_rxusrclk)--Rx_240M_WordClk)
  begin
    if des_rxusrclk'event and  des_rxusrclk='1' then
--  if Rx_240M_WordClk'event and Rx_240M_WordClk='1' then
      RX_HEADER_r <= RX_HEADER;
      Descrambler_enable_r <= Descrambler_enable;
 --   Descrambler_enable_2r <= Descrambler_enable_r;
      HeaderLocked_5r <= HeaderLocked_4r;
      HeaderLocked_4r <= HeaderLocked_3r;
      HeaderLocked_3r <= HeaderLocked_2r;
      HeaderLocked_2r <= HeaderLocked_r;
      HeaderLocked_r <= HeaderLocked;
      header_found <= HeaderLocked;

          
      if Descrambler_enable='1' then
        error_buf <= error_i;
      else
        error_buf<=error_buf;
      end if;
      
    end if;
  end process;
  error <= error_buf;
  
  

  
  ---- Descrambler, CTRL signal is added, clock is changed
   
  FelixDescrambler: entity work.gbt_rx_descrambler_FELIX
    port map
    (
    
      RX_HEADER_O                               => RX_HEADER_O,
      RX_HEADER_I                               => RX_HEADER,
    
      RX_RESET_I                             	=> RX_RESET_I, 
      RX_FRAMECLK_I                          	=> Rx_40M_FrameClk, 
      RX_WORDCLK_I                           	=> des_rxusrclk,--Rx_240M_WordClk, 
      Descrambler_enable		         => Descrambler_enable,
      DATA_MODE_CFG                             => Rx_Data_Format,
      ---------------------------------------
      ---------------------------------------
      RX_COMMON_FRAME_I                      	=> RxCommon84b,
      RX_DATA_O                              	=> RX_DATA_84b_O ,
      ---------------------------------------
      RX_EXTRA_FRAME_WIDEBUS_I               	=> RxExtraWidebus32b,
      RX_EXTRA_DATA_WIDEBUS_O                	=> RX_EXTRA_DATA_WIDEBUS_O
      );

end Behavioral;

