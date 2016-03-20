-------------------------------------------------------------------------------
-- Based on CERN GBT-FPGA project v3
-- Modified by K. Chen  @ Dec. 2014, Clock changed, in/out control signal added.
-- Crossing time domain logic is included, time margin is added, it can be
-- dynamic adjusted, or adjusted through the package file.

-- Low-level 16/21 bit scrambler is almost same with GBT-FPGA project, one
-- enable signal is added.
-------------------------------------------------------------------------------



library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;
 
use work.FELIX_gbt_package.all;

entity gbt_tx_scrambler_FELIX is
  generic

(
channel             : integer   := 0
);
  port
    (
      
      TX_TC_METHOD : in std_logic;
      Scrambler_Enable	: in  std_logic;
      Tx_Align_Signal   : out std_logic;
      TX_LATOPT_TC     : in  std_logic;
      
	  TX_TC_DLY_VALUE  : in std_logic_vector(2 downto 0);   
      
      TX_WORDCLK_I      : in  std_logic;
      TX_RESET_I        : in  std_logic;
      TX_FRAMECLK_I     : in  std_logic;
      
      --TX_ISDATA_SEL_I   : in  std_logic;
      TX_HEADER_I   : in std_logic_vector( 3 downto 0);
      
      TX_HEADER_O                               : out std_logic_vector( 3 downto 0);
      
      TX_DATA_I                                 : in  std_logic_vector(83 downto 0);
      TX_COMMON_FRAME_O                         : out std_logic_vector(83 downto 0);
      
      TX_EXTRA_DATA_WIDEBUS_I                   : in  std_logic_vector(31 downto 0);
      TX_EXTRA_FRAME_WIDEBUS_O                  : out std_logic_vector(31 downto 0)
      
      
      
   );
end gbt_tx_scrambler_FELIX;


architecture Behavior of gbt_tx_scrambler_FELIX is   

  --signal tx_frameclk_i_shifted, tx_frameclk_i_shifted_p : std_logic;
  signal fsm_rst ,Tx_Align_Signal_A,Tx_Align_Signal_B                               : std_logic := '0';
  signal frame_clk_stop, frame_clk_stop_p       : std_logic := '1';
  signal cnt                                    : std_logic_vector(2 downto 0) :="000";
  signal frame_clk_stop_a, frame_clk_stop_b,frame_clk_stop_c,frame_clk_stop_d     : std_logic := '1';

begin                
--=================================================================================================--

   --==================================== User Logic =====================================--

   --==============--
   -- Frame header --
   --==============--
   
--  headerSel: process(TX_RESET_I, TX_FRAMECLK_I)
--  begin
--    if TX_RESET_I = '1' then
--      TX_HEADER_O                            	<= (others => '0');
--    elsif rising_edge(TX_FRAMECLK_I) then      
--      if TX_ISDATA_SEL_I = '1' then
--        TX_HEADER_O                         <= DATA_HEADER_PATTERN;
--      else           
--        TX_HEADER_O                         <= IDLE_HEADER_PATTERN;      
--      end if; 
--    end if;
--  end process;
 
 ------------------------------------------------------------------------------
 ---- Addde by K. Chen
 ---- Dec. 2014
 ---- For time domain crossing, >1 or >0.5 WordClk Margin is added.
 ------------------------------------------------------------------------------
  
--   TC_GEN1 : if TX_TC_DYNAMIC_EN = '1'  generate    
  timedomaincrossing_C :entity work.gbt_tx_timedomaincrossing_FELIX

  generic map
  (
  channel         => channel       
  )
  port map
    (
      
      
      Tx_Align_Signal   => Tx_Align_Signal,
      TX_LATOPT_TC     => TX_LATOPT_TC,
      TX_TC_METHOD  => TX_TC_METHOD,  
      
      TX_TC_DLY_VALUE  => TX_TC_DLY_VALUE,
      
      TX_WORDCLK_I     => TX_WORDCLK_I,
      TX_RESET_I        => TX_RESET_I,
      TX_FRAMECLK_I     => TX_FRAMECLK_I
      
     
   );
   
--   end generate;
  
    
--  TC_GEN2 : if TX_TC_DYNAMIC_EN = '0' and TX_SCRAMBLER_SEL = '1' generate    
--timedomaincrossing_A :entity work.gbt_tx_timedomaincrossing_FELIX_method_A
--  port map
--    (
      
      
--      Tx_Align_Signal   => Tx_Align_Signal,
--      TX_LATOPT_TC     => TX_LATOPT_TC,
        
      
--      TX_WORDCLK_I     => TX_WORDCLK_I,
--      TX_RESET_I        => TX_RESET_I,
--      TX_FRAMECLK_I     => TX_FRAMECLK_I
      
     
--   );
   
--   end generate;
 
--   TC_GEN3 : if TX_TC_DYNAMIC_EN = '0' and TX_SCRAMBLER_SEL = '0' generate 
-- timedomaincrossing_B :entity work.gbt_tx_timedomaincrossing_FELIX_method_B
--   port map
--     (
       
       
--       Tx_Align_Signal   => Tx_Align_Signal,
--       TX_LATOPT_TC     => TX_LATOPT_TC,
         
       
--       TX_WORDCLK_I     => TX_WORDCLK_I,
--       TX_RESET_I        => TX_RESET_I,
--       TX_FRAMECLK_I     => TX_FRAMECLK_I
       
      
--    );
-- end generate; 
  
   
     
  
  process(TX_WORDCLK_I)
  begin
  if TX_WORDCLK_I'event and TX_WORDCLK_I='1' then
  if Scrambler_Enable='1' then
    TX_HEADER_O <= TX_HEADER_I;
    end if;
 end if;
 end process;
   
  --============--
  -- Scramblers --
  --============--
   
  -- 84 bit scrambler (GBT-Frame & Wide-Bus):
  -------------------------------------------
   
  gbtFrameOrWideBus_gen: if (DATA_MODE = GBT_FRAME) or (DATA_MODE = WIDE_BUS) generate 
   
    gbtTxScrambler84bit_gen: for i in 0 to 3 generate
      -- Comment: [83:63] & [62:42] & [41:21] & [20:0]
      
      gbtTxScrambler21bit: entity work.gbt_tx_scrambler_21bit
        port map(
          TX_RESET_I                       	=> TX_RESET_I,
          Scrambler_Enable 			=> Scrambler_Enable,
          RESET_PATTERN_I                  	=> SCRAMBLER_21BIT_RESET_PATTERNS(i),
          ---------------------------------
          TX_FRAMECLK_I                    	=> TX_WORDCLK_I,
          ---------------------------------
          TX_DATA_I                        	=> TX_DATA_I(((21*i)+20) downto (21*i)),
          TX_COMMON_FRAME_O                	=> TX_COMMON_FRAME_O(((21*i)+20) downto (21*i))
          );
      
    end generate;    
  end generate;
   
  -- 32 bit scrambler (Wide-Bus):
  -- Kept for dynamic data type change
  ------------------------------
   
  wideBus_gen: if (DATA_MODE = GBT_FRAME) or (DATA_MODE = WIDE_BUS) generate
   
    gbtTxScrambler32bit_gen: for i in 0 to 1 generate
      ---- Comment: [31:16] & [15:0]
      gbtTxScrambler16bit: entity work.gbt_tx_scrambler_16bit
        port map(
          TX_RESET_I                       => TX_RESET_I,
          Scrambler_Enable 		   => Scrambler_Enable,	--'1',
          RESET_PATTERN_I                  => SCRAMBLER_16BIT_RESET_PATTERNS(i),
          ---------------------------------
          TX_FRAMECLK_I                    => TX_WORDCLK_I,
          ---------------------------------
          TX_EXTRA_DATA_WIDEBUS_I          => TX_EXTRA_DATA_WIDEBUS_I(((16*i)+15) downto (16*i)),
          TX_EXTRA_FRAME_WIDEBUS_O         => TX_EXTRA_FRAME_WIDEBUS_O(((16*i)+15) downto (16*i))
          );

    end generate;
  end generate;
   
  --wideBus_no_gen: if DATA_MODE = GBT_FRAME generate
    
  --  TX_EXTRA_FRAME_WIDEBUS_O                  <= (others => '0');
    
  --end generate;
   
  --===========--
  -- FELIX-8b10b --
  --===========--
  -- WILL BE ADDED. 
   
   --=====================================================================================--
end Behavior;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
