----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Kai CHEN @ BNL
-- 
-- Create Date:    23:54:10 12/05/2014 
-- Design Name: 
-- Module Name:   
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:     GBT TxRx Top Level
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
library UNISIM;
use UNISIM.VComponents.all;

entity gbtTxRx_FELIX is
  generic
    (
      channel                   : integer   := 0
      );
  Port
    ( 
      alignment_chk_rst         : in std_logic;
      alignment_done_O          : out std_logic;
      
      outsel_i                  : in std_logic;
      outsel_o                  : out std_logic;
      error_o                   : out std_logic;
      
      TX_TC_DLY_VALUE           : in std_logic_vector(2 downto 0); 
      TX_TC_METHOD              : in std_logic;
    
      BITSLIP_MANUAL	       	: in  std_logic;
      BITSLIP_SEL 	     	: in  std_logic; --backup for auto bitslip
      GT_RXSLIDE		: out std_logic;
      OddEven, TopBot		: in std_logic;
      data_sel                  : in std_logic_vector(3 downto 0);
      RX_FLAG , TX_FLAG         : out std_logic;
      Tx_latopt_scr             : in std_logic;
      Tx_latopt_tc              : in std_logic;
      RX_LATOPT_DES             : in std_logic;
      Tx_DATA_FORMAT       	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      Rx_Data_Format            : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      
      RX_RESET_I  		: in  std_logic;
      RX_FRAME_CLK_O 		: out std_logic;
      RX_HEADER_FOUND 		: out std_logic;
      RX_WORD_IS_HEADER_O 	: out std_logic;
      RX_WORDCLK_I 		: in std_logic;
      RX_ISDATA_FLAG_O    	: out std_logic;		
      
      L40M                      : in std_logic;
      RX_DATA_20b_I       	: in  std_logic_vector(19 downto 0);
      RX_DATA_120b_O       	: out std_logic_vector(119 downto 0);
      
      TX_RESET_I 		: in  std_logic;
      TX_FRAMECLK_I		: in  std_logic;
      des_rxusrclk              : in std_logic;
      TX_WORDCLK_I 		: in  std_logic;
     -- TX_ISDATA_SEL_I			: in  std_logic;
      TX_DATA_120b_I		: in std_logic_vector(119 downto 0);
      TX_DATA_20b_O		: out  std_logic_vector(19 downto 0)
      );

end gbtTxRx_FELIX;

architecture Behavioral of gbtTxRx_FELIX is
--=========--

  signal BITSLIP_MANUAL_r, BITSLIP_MANUAL_2r :std_logic:='0'; 
  signal RX_FRAME_CLK, alignment_done :std_logic;
  signal header_found, HeaderFlag :std_logic;
  signal outsel_gen,error,error_i :std_logic;
  signal RX_DATA_120b_Oi,RX_DATA_120b_O_r :std_logic_vector(119 downto 0);

begin
  -- BitSlip Genaration
  process(RX_WORDCLK_I)
  begin
    if RX_WORDCLK_I'event and RX_WORDCLK_I='1' then
      BITSLIP_MANUAL_r <= BITSLIP_MANUAL;
      BITSLIP_MANUAL_2r <= BITSLIP_MANUAL_r;
      GT_RXSLIDE <= BITSLIP_MANUAL_r and (not BITSLIP_MANUAL_2r);
    end if;
  end process;

  --- FELIX RX top
  ---
  outsel_o <= outsel_gen;
  
  process(RX_RESET_I,L40M)
  begin 
    if L40M'event and L40M='1' then
      if RX_RESET_I='1' then
        outsel_gen <= RX_FRAME_CLK;
      else
        outsel_gen <=outsel_gen;
      end if;
    end if;
    
  end process;
   
   
  desmux_en : if RX_DESCR_MUX_EN='1' generate
    process(RX_RESET_I,L40M)
    begin 
      if L40M'event and L40M='0' then
        RX_DATA_120b_O_r <=RX_DATA_120b_Oi;
      end if;
    end process;
    RX_DATA_120b_O <= RX_DATA_120b_Oi when outsel_i='1' else RX_DATA_120b_O_r;
  end generate;
  
  desmux_un : if RX_DESCR_MUX_EN='0' generate
    RX_DATA_120b_O <= RX_DATA_120b_Oi;
  end generate;  
 -- RX_FLAG <= RX_FRAME_CLK;
 -- TX_FLAG <= L40M;
  
  gbtRx_inst: entity work.gbtRx_FELIX
    Port Map( 
      RX_FLAG                   => RX_FLAG,
      error                     => error,
      RX_RESET_I  		=> RX_RESET_I,
      RX_FRAME_CLK_O 		=> RX_FRAME_CLK,
      RX_WORDCLK_I 		=> RX_WORDCLK_I,
      des_rxusrclk              => des_rxusrclk,
	--  L40M => L40M,   
      OddEven 			=> OddEven,
      TopBot                    => TopBot,
      data_sel                  => data_sel,
      HeaderFlag		=> HeaderFlag,
      header_found		=> header_found,
      Rx_Data_Format            => Rx_Data_Format,
      RX_ISDATA_FLAG_O          => RX_ISDATA_FLAG_O,
      RX_LATOPT_DES             => RX_LATOPT_DES,
            
      RX_DATA_20b_I    		=> RX_DATA_20b_I,
      RX_HEADER_O               => RX_DATA_120b_Oi(119 downto 116),
      RX_DATA_84b_O    		=> RX_DATA_120b_Oi(115 downto 32),
      RX_EXTRA_DATA_WIDEBUS_O   => RX_DATA_120b_Oi(31 downto 0) 
      );

  RX_HEADER_FOUND <= header_found;
  RX_FRAME_CLK_O <= RX_FRAME_CLK;
  RX_WORD_IS_HEADER_O <= HeaderFlag;
  
  alignment_done_O <= alignment_done;
  
--  process(RX_FRAME_CLK)
--  begin
--  if RX_FRAME_CLK'event and RX_FRAME_CLK='1' then
--    if alignment_chk_rst = '1' then
--        alignment_done <= '1';
--    elsif header_found='0' then
--        alignment_done <= '0';
--    else
--        alignment_done <= alignment_done;
--    end if;
--    end if;
--  end process;
  
  process(L40M)
  begin
    if L40M'event and L40M='1' then
      if alignment_chk_rst = '1' then
        alignment_done <= '1';
        
      elsif header_found='0' then
        alignment_done <= '0';
      else
        alignment_done <= alignment_done;
      end if;
    
      if alignment_chk_rst = '1' or alignment_done = '0' then
         
        error_i <='0';
      elsif error='1' then
        error_i <= '1';
      else
        error_i <= error_i;
      end if;
    end if;
  end process;
  error_o <= error_i;


  --- FELIX TX top
  gbtTx_inst: entity work.gbtTx_FELIX
    generic map
    (
    channel                     => channel       
    )
  
    Port map
    ( 
      TX_FLAG                   => TX_FLAG,
      TX_RESET_I                => TX_RESET_I,
      TX_FRAMECLK_I             => TX_FRAMECLK_I,
      TX_WORDCLK_I              => TX_WORDCLK_I,
      TX_TC_METHOD              => TX_TC_METHOD,
      Tx_latopt_scr             => Tx_latopt_scr,
      TX_LATOPT_TC              => TX_LATOPT_TC,
      DATA_MODE_CFG             => Tx_DATA_FORMAT,
	
      TX_TC_DLY_VALUE           => TX_TC_DLY_VALUE,
      --TX_ISDATA_SEL_I  => TX_ISDATA_SEL_I,
      TX_HEADER_I               => TX_DATA_120b_I(119 downto 116),
      TX_DATA_84b_I             => TX_DATA_120b_I(115 downto 32),
      TX_EXTRA_DATA_WIDEBUS_I   => TX_DATA_120b_I(31 downto 0),
      TX_DATA_20b_O	        => TX_DATA_20b_O
      );
 

end Behavioral;

