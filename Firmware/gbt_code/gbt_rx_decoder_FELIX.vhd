
--=================================================================================================--
--##################################   Module Information   #######################################--
--=================================================================================================--
--                                                                                         
-- Company:               CERN (PH-ESE-BE)                                                         
-- Engineer:              Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)
--                                                                                                 
-- Project Name:          GBT-FPGA                                                                
-- Module Name:           GBT RX decoder
--                                                                                                 
-- Language:              VHDL'93                                                              
--                                                                                                   
-- Target Device:         Vendor agnostic                                                
-- Tool version:                                                                        
--                                                                                                   
-- Version:               3.2                                                                      
--
-- Description:            
--
-- Versions history:      DATE         VERSION   AUTHOR                               DESCRIPTION
--    
--                        10/05/2009   0.1       S. Muschter (Stockholm University)   First .bdf entity definition.           
--                                                                   
--                        08/07/2009   0.2       S. Baron (CERN)                      Translate from .bdf to .vhd.
--
--                        04/07/2013   3.0       M. Barros Marin                      - Cosmetic and minor modifications.   
--                                                                                    - Add Wide-Bus encoding. 
--
--                        01/09/2014   3.2       M. Barros Marin                      Fixed generic issue (TX_ENCODING -> RX_ENCODING).  
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

-- Custom libraries and packages:
use work.FELIX_gbt_package.all;


--=================================================================================================--
--#######################################   Entity   ##############################################--
--=================================================================================================--

entity gbt_rx_decoder_FELIX is
  port (
    ---- Input
    RX_FRAME_I                                : in  std_logic_vector(119 downto 0);
    DATA_MODE_CFG                               : in std_logic_vector(1 downto 0);
    RX_HEADER                                 : out std_logic_vector(3 downto 0);
    error : out std_logic;	
    Rx_240M_WordClk_I  : in std_logic;
    ---- Output
   -- RX_ISDATA_FLAG_O                          : out std_logic; 
   -- RX_HEADER_LOCKED_FLAG                     : out std_logic; 
    RX_COMMON_FRAME_O                         : out std_logic_vector(83 downto 0);
    RX_EXTRA_FRAME_WIDEBUS_O                  : out std_logic_vector(31 downto 0)
    );
end gbt_rx_decoder_FELIX;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture structural of gbt_rx_decoder_FELIX is 

  --================================ Signal Declarations ================================--

  signal rxFrame_from_deinterleaver            : std_logic_vector(119 downto 0);
  signal rxCommonFrame_from_reedSolomonDecoder : std_logic_vector( 87 downto 0); 
  signal error1,error2:std_logic:='0';

  --=====================================================================================--

--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--  

  --==================================== User Logic =====================================--   
  error <= (error1 or error2) when DATA_MODE_CFG = GBT_FRAME else
          '0';
  --==============--
  -- Frame header --
  --==============--
  -- Modified 12/05/2014, K. Chen
  --RX_ISDATA_FLAG_O  <= '1' when (RX_FRAME_I(119 downto 116) = DATA_HEADER_PATTERN) else '0';
  --RX_HEADER_LOCKED_FLAG  <= '1' when (RX_FRAME_I(119 downto 116) = DATA_HEADER_PATTERN or RX_FRAME_I(119 downto 116) = IDLE_HEADER_PATTERN) 
 --				else '0';

  --=========--
  -- Decoder --
--  --=========--   
--  non_dynamic_data_change: if DYNAMIC_DATA_MODE = "000" generate
--    -- GBT-Frame:
--    -------------  
   
--    gbtFrame_gen: if DATA_MODE = GBT_FRAME generate 
--      deinterleaver: entity work.gbt_rx_decoder_gbtframe_deintlver
--        port map (        
--          RX_FRAME_I                          => RX_FRAME_I,
--          RX_FRAME_O                          => rxFrame_from_deinterleaver
--          );   
    
    
--    sync1_gen: if DECODER_MODE = SYNC generate 
--      reedSolomonDecoder60to119: entity work.gbt_rx_decoder_gbtframe_rsdec_sync
--        port map (
--          Rx_240M_WordClk_I  => Rx_240M_WordClk_I,
--          RX_COMMON_FRAME_ENCODED_I           => rxFrame_from_deinterleaver(119 downto 60),
--          RX_COMMON_FRAME_O                   => rxCommonFrame_from_reedSolomonDecoder(87 downto 44),
--          ERROR_DETECT_O                      => open   -- Comment: Port added for debugging.
--          );   

--      reedSolomonDecoder0to50: entity work.gbt_rx_decoder_gbtframe_rsdec_sync
--        port map(
--          Rx_240M_WordClk_I  => Rx_240M_WordClk_I,
--          RX_COMMON_FRAME_ENCODED_I           => rxFrame_from_deinterleaver(59 downto 0),
--          RX_COMMON_FRAME_O                   => rxCommonFrame_from_reedSolomonDecoder(43 downto 0),
--          ERROR_DETECT_O                      => open   -- Comment: Port added for debugging.
--          );    
--      end generate;
      
--      comb1_gen: if DECODER_MODE = COMB generate 
--            reedSolomonDecoder60to119: entity work.gbt_rx_decoder_gbtframe_rsdec
--              port map (
--              --  Rx_240M_WordClk_I  => Rx_240M_WordClk_I,
--                RX_COMMON_FRAME_ENCODED_I           => rxFrame_from_deinterleaver(119 downto 60),
--                RX_COMMON_FRAME_O                   => rxCommonFrame_from_reedSolomonDecoder(87 downto 44),
--                ERROR_DETECT_O                      => open   -- Comment: Port added for debugging.
--                );   
      
--            reedSolomonDecoder0to50: entity work.gbt_rx_decoder_gbtframe_rsdec
--              port map(
--             --   Rx_240M_WordClk_I  => Rx_240M_WordClk_I,
--                RX_COMMON_FRAME_ENCODED_I           => rxFrame_from_deinterleaver(59 downto 0),
--                RX_COMMON_FRAME_O                   => rxCommonFrame_from_reedSolomonDecoder(43 downto 0),
--                ERROR_DETECT_O                      => open   -- Comment: Port added for debugging.
--                );    
--            end generate;
      
--      RX_COMMON_FRAME_O                         <= 	rxCommonFrame_from_reedSolomonDecoder(83 downto 0);
--      RX_EXTRA_FRAME_WIDEBUS_O                  <= 	(others => '0');
--      RX_HEADER <= rxCommonFrame_from_reedSolomonDecoder(87 downto 84);
--    end generate;
   
--    -- Wide-Bus: 
--    ------------
   
--    wideBus_gen: if DATA_MODE = WIDE_BUS generate      
--      RX_COMMON_FRAME_O                         <= RX_FRAME_I(115 downto 32);
--      RX_EXTRA_FRAME_WIDEBUS_O                  <= RX_FRAME_I( 31 downto  0);     
--      RX_HEADER <= RX_FRAME_I(119 downto 116);
    
--    end generate;
--  end generate;

 -- dynamic_data_change: if DYNAMIC_DATA_MODE /= "000" generate
    -- GBT-Frame:
    -------------  
   
    
    deinterleaver: entity work.gbt_rx_decoder_gbtframe_deintlver
      port map (        
        RX_FRAME_I                          => RX_FRAME_I,
        RX_FRAME_O                          => rxFrame_from_deinterleaver
        );   
        
    sync2_gen: if DECODER_MODE = SYNC generate 
    reedSolomonDecoder60to119: entity work.gbt_rx_decoder_gbtframe_rsdec_sync
      port map (
        Rx_240M_WordClk_I  => Rx_240M_WordClk_I,
        RX_COMMON_FRAME_ENCODED_I           => rxFrame_from_deinterleaver(119 downto 60),
        RX_COMMON_FRAME_O                   => rxCommonFrame_from_reedSolomonDecoder(87 downto 44),
        ERROR_DETECT_O                      => error1   -- Comment: Port added for debugging.
        );   

    reedSolomonDecoder0to50: entity work.gbt_rx_decoder_gbtframe_rsdec_sync
      port map(
        Rx_240M_WordClk_I  => Rx_240M_WordClk_I,
        RX_COMMON_FRAME_ENCODED_I           => rxFrame_from_deinterleaver(59 downto 0),
        RX_COMMON_FRAME_O                   => rxCommonFrame_from_reedSolomonDecoder(43 downto 0),
        ERROR_DETECT_O                      => error2   -- Comment: Port added for debugging.
        );    
    end generate;
  comb2_gen: if DECODER_MODE = COMB generate 
        reedSolomonDecoder60to119: entity work.gbt_rx_decoder_gbtframe_rsdec
          port map (
           -- Rx_240M_WordClk_I  => Rx_240M_WordClk_I,
            RX_COMMON_FRAME_ENCODED_I           => rxFrame_from_deinterleaver(119 downto 60),
            RX_COMMON_FRAME_O                   => rxCommonFrame_from_reedSolomonDecoder(87 downto 44),
            ERROR_DETECT_O                      => error1   -- Comment: Port added for debugging.
            );   
    
        reedSolomonDecoder0to50: entity work.gbt_rx_decoder_gbtframe_rsdec
          port map(
           -- Rx_240M_WordClk_I  => Rx_240M_WordClk_I,
            RX_COMMON_FRAME_ENCODED_I           => rxFrame_from_deinterleaver(59 downto 0),
            RX_COMMON_FRAME_O                   => rxCommonFrame_from_reedSolomonDecoder(43 downto 0),
            ERROR_DETECT_O                      => error2   -- Comment: Port added for debugging.
            );    
        end generate; 
   
    -- Wide-Bus: 
    ------------
   
  
    RX_COMMON_FRAME_O                         <= RX_FRAME_I(115 downto 32) when DATA_MODE_CFG = WIDE_BUS
                                                 else rxCommonFrame_from_reedSolomonDecoder(83 downto 0);
    RX_EXTRA_FRAME_WIDEBUS_O                  <= RX_FRAME_I( 31 downto  0) when DATA_MODE_CFG = WIDE_BUS
                                                 else (others => '0');
                                                 
                                                 
                                                 
    RX_HEADER <= RX_FRAME_I(119 downto 116) when DATA_MODE_CFG = WIDE_BUS else rxCommonFrame_from_reedSolomonDecoder(87 downto 84);

    

 -- end generate;
	
  -- FELIX 8b10b:
  -------------
  
  -- Will be added
   
 
   
         

   --=====================================================================================--
end structural;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
