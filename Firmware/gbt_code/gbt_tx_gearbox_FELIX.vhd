-------------------------------------------------------------------------------
---- Big Modification is done, by K. Chen  @ Dec. 2014
---- The timing crossing is deleted. A new robust one is moved before scrambler. 
---- Gearbox signal is latched, compatible for GBT-FRAME/widebus Mode.
-------------------------------------------------------------------------------

--=================================================================================================--
--##################################   Module Information   #######################################--
--=================================================================================================--
--                                                                                         
-- Company:               CERN (PH-ESE-BE)                                                         
-- Engineer:              Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)
--                                                                                                 
-- Project Name:          GBT-FPGA                                                                
-- Module Name:           GBT TX gearbox latency-optimized
--                                                                                                 
-- Language:              VHDL'93                                                              
--                                                                                                   
-- Target Device:         Vendor agnostic                                                
-- Tool version:                                                                        
--                                                                                                   
-- Version:               3.0                                                                      
--
-- Description:            
--
-- Versions history:      DATE         VERSION   AUTHOR                               DESCRIPTION
--    
--                        10/05/2009   0.1       F. Marin (CPPM)                      First .bdf entity definition.           
--                                                                   
--                        08/07/2009   0.2       S. Baron (CERN)                      Translate from .bdf to .vhd.
--
--                        02/11/2010   0.3       S. Muschter (Stockholm University)   Optimization to low latency.
--
--                        26/11/2013   3.0       M. Barros Marin                      - Cosmetic and minor modifications.   
--                                                                                    - Support for 20bit and 40bit words. 
--
-- Additional Comments:  
--
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!                                                                                           !!
-- !! * The different parameters of the GBT Bank are set through:                               !!  
-- !!   (Note!! These parameters are vendor specific)                                           !!                    
-- !!                                                                                           !!
-- !!   - The MGT control ports of the GBT Bank module (these ports are listed in the records   !!
-- !!     of the file "<vendor>_<device>_gbt_bank_package.vhd").                                !! 
-- !!     (e.g. xlx_v6_gbt_bank_package.vhd)                                                    !!
-- !!                                                                                           !!  
-- !!   - By modifying the content of the file "<vendor>_<device>_gbt_bank_user_setup.vhd".     !!
-- !!     (e.g. xlx_v6_gbt_bank_user_setup.vhd)                                                 !! 
-- !!                                                                                           !! 
-- !! * The "<vendor>_<device>_gbt_bank_user_setup.vhd" is the only file of the GBT Bank that   !!
-- !!   may be modified by the user. The rest of the files MUST be used as is.                  !!
-- !!                                                                                           !!  
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--                                                                                                   
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Custom libraries and packages:
use work.FELIX_gbt_package.all;

--=================================================================================================--
--#######################################   Entity   ##############################################--
--=================================================================================================--

entity gbt_tx_gearbox_FELIX is
generic

(
channel             : integer   := 0
);
  port (
  
    --================--
    -- Reset & Clocks --
    --================--    
    Scrambler_Enable_o	: out std_logic;  
    Tx_Align_Signal 	: in std_logic;
    TX_LATOPT_SCR       : in  std_logic;
    
      
    -- Reset:
    ---------
      
    TX_RESET_I                                : in  std_logic;
  
    -- Clocks:
    ----------
      
    TX_WORDCLK_I                              : in  std_logic;
    TX_FRAMECLK_I                             : in  std_logic;
      
    --==============--
    -- Frame & Word --
    --==============--
      
    TX_FRAME_I                                : in  std_logic_vector(119 downto 0);
    TX_WORD_OO                                 : out std_logic_vector(19 downto 0)
   
   );
end gbt_tx_gearbox_FELIX;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture behavioral of gbt_tx_gearbox_FELIX is

  --================================ Signal Declarations ================================--

  signal txFrame_from_frameInverter,tx_buffer            : std_logic_vector (119 downto 0);
  signal gearboxSyncReset                      : std_logic;  
  signal address:std_logic_vector(2 downto 0);
  signal TX_WORD_O_r, TX_WORD_O:std_logic_vector(19 downto 0);
  
  signal Scrambler_Enable_r1,Scrambler_Enable, Scrambler_Enable_r2, Scrambler_Enable_r3:std_logic;
  signal Scrambler_Enable_r4,Scrambler_Enable_r5:std_logic;
  --=====================================================================================--  

--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--  
      

   process(TX_WORDCLK_I)
      begin
      if TX_WORDCLK_I'event and TX_WORDCLK_I='1' then
            Scrambler_Enable_r1 <= Scrambler_Enable;
            Scrambler_Enable_r2 <= Scrambler_Enable_r1;
            Scrambler_Enable_r3 <= Scrambler_Enable_r2;
            Scrambler_Enable_r4 <= Scrambler_Enable_r3;
            Scrambler_Enable_r5 <= Scrambler_Enable_r4;
            Scrambler_Enable_o <= Scrambler_Enable_r5;
   end if;
   end process;
   
   
   
   
   nophaseadj_with_latch: if phase_adjust = '0' and TX_GEARBOX_LATCH_EN='1' generate
   process(TX_WORDCLK_I)
      begin
      if TX_WORDCLK_I'event and TX_WORDCLK_I='1' then
    TX_WORD_OO <= TX_WORD_O;
    end if;
    end process;
    end generate;
    
    nophaseadj_no_latch: if phase_adjust = '0' and TX_GEARBOX_LATCH_EN='0' generate
      
        TX_WORD_OO <= TX_WORD_O;
       
    end generate;
    
   phaseadj: if phase_adjust = '1' generate
   process(TX_WORDCLK_I)
   begin
   if TX_WORDCLK_I'event and TX_WORDCLK_I='1' then
    TX_WORD_O_r <= TX_WORD_O;
    
    case channel is
    when 0 =>
        TX_WORD_OO <= TX_WORD_O;
    when 1 =>
        TX_WORD_OO <= TX_WORD_O(18 downto 0) & TX_WORD_O_r(19) ;
    when 2 =>
        TX_WORD_OO <= TX_WORD_O(17 downto 0) & TX_WORD_O_r(19 downto 18) ;
    when 3 =>
        TX_WORD_OO <= TX_WORD_O(16 downto 0) & TX_WORD_O_r(19 downto 17) ;
    when 4 =>
        TX_WORD_OO <= TX_WORD_O(15 downto 0) & TX_WORD_O_r(19 downto 16) ;
    when 5 =>
        TX_WORD_OO <= TX_WORD_O(14 downto 0) & TX_WORD_O_r(19 downto 15) ;
    when 6 =>
          TX_WORD_OO <= TX_WORD_O(13 downto 0) & TX_WORD_O_r(19 downto 14) ;
    when 7 =>
        TX_WORD_OO <= TX_WORD_O(12 downto 0) & TX_WORD_O_r(19 downto 13) ;
    when 8 =>
        TX_WORD_OO <= TX_WORD_O(11 downto 0) & TX_WORD_O_r(19 downto 12) ;
    when 9 =>
        TX_WORD_OO <= TX_WORD_O(10 downto 0) & TX_WORD_O_r(19 downto 11) ;
    when 10 =>
        TX_WORD_OO <= TX_WORD_O(9 downto 0) & TX_WORD_O_r(19 downto 10) ;
    when 11 =>
        TX_WORD_OO <= TX_WORD_O(8 downto 0) & TX_WORD_O_r(19 downto 9) ;
    when 12 =>
        TX_WORD_OO <= TX_WORD_O(7 downto 0) & TX_WORD_O_r(19 downto 8) ;
    when 13 =>
        TX_WORD_OO <= TX_WORD_O(6 downto 0) & TX_WORD_O_r(19 downto 7) ;                      
    when 14 =>
        TX_WORD_OO <= TX_WORD_O(5 downto 0) & TX_WORD_O_r(19 downto 6) ;
    when 15 =>
        TX_WORD_OO <= TX_WORD_O(4 downto 0) & TX_WORD_O_r(19 downto 5) ;
    when 16 =>
        TX_WORD_OO <= TX_WORD_O(3 downto 0) & TX_WORD_O_r(19 downto 4) ;
    when 17 =>
        TX_WORD_OO <= TX_WORD_O(2 downto 0) & TX_WORD_O_r(19 downto 3) ;
    when 18 =>
        TX_WORD_OO <= TX_WORD_O(1 downto 0) & TX_WORD_O_r(19 downto 2) ;
    when 19 =>
        TX_WORD_OO <= TX_WORD_O(0 downto 0) & TX_WORD_O_r(19 downto 1) ;
    when 20 =>
        TX_WORD_OO <= TX_WORD_O;
    when 21 =>
        TX_WORD_OO <= TX_WORD_O(18 downto 0) & TX_WORD_O_r(19) ;
    when 22 =>
        TX_WORD_OO <= TX_WORD_O(17 downto 0) & TX_WORD_O_r(19 downto 18) ;
    when 23 =>
        TX_WORD_OO <= TX_WORD_O(16 downto 0) & TX_WORD_O_r(19 downto 17) ;                      
    when others => TX_WORD_OO <= TX_WORD_O;
                                  end case;               
   end if;
   end process;
   end generate;
   
   
   --==================================== User Logic =====================================--   
   
   --==============--
   -- Common logic --
   --==============--
   
   -- Comment: Bits are inverted to transmit the MSB first on the MGT.
   
  frameInverter: for i in 119 downto 0 generate
    txFrame_from_frameInverter(i)             <= TX_FRAME_I(119-i);
  end generate;

  -----------------------------------------------------------------------------
  -- Modified by Kai Chen, Dec. 2014
  -- For GBT-FRAME
  -----------------------------------------------------------------------------
  non_dynamic: if DYNAMIC_LATENCY_OPT = '0' generate
    gbtFrame_gen: if DATA_MODE = GBT_FRAME or  DATA_MODE = WIDE_BUS generate
      big_lat: if TX_LATOPT_SCRAMBLER = '0' generate
       
        process(TX_WORDCLK_I)
        begin
          if TX_WORDCLK_I'event and TX_WORDCLK_I='1' then
            if Tx_Align_Signal = '1' then
              address <=	"001";
            elsif address = "101" then
              address <= 	"000";
            else
              address <= 	address + '1';
            end if;
            case address is
              when "000" =>
                TX_WORD_O                     	<= tx_buffer(119 downto 100);
                Scrambler_Enable 				<= '0';
              when "001" => 
                TX_WORD_O                     	<= txFrame_from_frameInverter( 19 downto   0);
                Scrambler_Enable 				<= '0';
              when "010" =>                 
                TX_WORD_O                     	<= txFrame_from_frameInverter( 39 downto  20);
                Scrambler_Enable 				<= '0';
              when "011" =>                 
                TX_WORD_O                     	<= txFrame_from_frameInverter( 59 downto  40);
                Scrambler_Enable 				<= '0';
              when "100" =>                 
                TX_WORD_O                     	<= txFrame_from_frameInverter(79 downto  60);-- & not tx_buffer(60);
                tx_buffer 			<= txFrame_from_frameInverter(119 downto 0);
                Scrambler_Enable 				<= '1';
              when "101" =>                 
                TX_WORD_O                     	<= tx_buffer( 99 downto  80);
                Scrambler_Enable 				<= '0';
              when others =>
                null;
            end case;
          end if;
        end process;
      end generate big_lat;

      low_lat: if TX_LATOPT_SCRAMBLER = '1' generate
        
        process(TX_WORDCLK_I)
        begin
          if TX_WORDCLK_I'event and TX_WORDCLK_I='1' then
            if Tx_Align_Signal = '1' then
              address <=	"010";
            elsif address = "101" then
              address <= 	"000";
            else
              address <= 	address + '1';
            end if;
            case address is
              when "000" =>
                TX_WORD_O                     	<= tx_buffer(119 downto 100);
                Scrambler_Enable 				<= '0';
              when "001" => 
                TX_WORD_O                     	<= txFrame_from_frameInverter( 19 downto   0);
                Scrambler_Enable 				<= '0';
              when "010" =>                 
                TX_WORD_O                     	<= txFrame_from_frameInverter( 39 downto  20);
                Scrambler_Enable 				<= '0';
              when "011" =>                 
                TX_WORD_O                     	<= txFrame_from_frameInverter( 59 downto  40);
                Scrambler_Enable 				<= '0';
              when "100" =>                 
                TX_WORD_O                     	<= txFrame_from_frameInverter(79 downto  60);-- & not tx_buffer(60);
                tx_buffer 			<= txFrame_from_frameInverter(119 downto 0);
                Scrambler_Enable 				<= '0';
              when "101" =>                 
                TX_WORD_O                     	<= tx_buffer( 99 downto  80);
                Scrambler_Enable 				<= '1';
              when others =>
                null;
            end case;
          end if;
        end process;
      end generate low_lat;
    end generate gbtFrame_gen;
  end generate non_dynamic;

  
  dynamic: if DYNAMIC_LATENCY_OPT = '1' generate
    gbtFrame_gen: if DATA_MODE = GBT_FRAME or  DATA_MODE = WIDE_BUS generate
     
      process(TX_WORDCLK_I)
      begin
        if TX_WORDCLK_I'event and TX_WORDCLK_I='1' then
          if Tx_Align_Signal = '1' then
            if TX_LATOPT_SCR='0' then
              address <=	"001";
            else
              address <=      "010";
            end if;
          elsif address = "101" then
            address <= 	"000";
          else
            address <= 	address + '1';
          end if;
          case address is
            when "000" =>
              TX_WORD_O                     	<= tx_buffer(119 downto 100);
              Scrambler_Enable 				<= '0';
            when "001" => 
              TX_WORD_O                     	<= txFrame_from_frameInverter( 19 downto   0);
              Scrambler_Enable 				<= '0';
            when "010" =>                 
              TX_WORD_O                     	<= txFrame_from_frameInverter( 39 downto  20);
              Scrambler_Enable 				<= '0';
            when "011" =>                 
              TX_WORD_O                     	<= txFrame_from_frameInverter( 59 downto  40);
              Scrambler_Enable 				<= '0';
            when "100" =>                 
              TX_WORD_O                     	<= txFrame_from_frameInverter(79 downto  60);-- & not tx_buffer(60);
              tx_buffer 			<= txFrame_from_frameInverter(119 downto 0);
              if TX_LATOPT_SCR='0' then
                Scrambler_Enable 				<= '1';
              else
                Scrambler_Enable                              <= '0';
              end if;
            when "101" =>                 
              TX_WORD_O                     	<= tx_buffer( 99 downto  80);
              if TX_LATOPT_SCR='0' then
                Scrambler_Enable 				<= '0';
              else
                Scrambler_Enable                              <= '1';
              end if;
            when others =>
              null;
          end case;
        end if;
      end process;
    end generate gbtFrame_gen;
  end generate dynamic;



   --=====================================================================================--
end behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
