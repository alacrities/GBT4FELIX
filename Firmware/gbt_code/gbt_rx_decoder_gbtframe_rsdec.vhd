--=================================================================================================--
--##################################   Module Information   #######################################--
--=================================================================================================--
--                                                                                         
-- Company:               CERN (PH-ESE-BE)                                                         
-- Engineer:              Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)
--                                                                                                 
-- Project Name:          GBT-FPGA                                                                
-- Module Name:           GBT RX decoder GBT-Frame Reed-Solomon decoder
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
-- Versions history:      DATE         VERSION   AUTHOR                DESCRIPTION
--
--                        12/10/2006   0.1       A. Marchioro (CERN)   First .v module definition.   
--    
--                        07/10/2008   0.2       F. Marin (CPPM)       Translate from .v to .vhd.           
--                                                                   
--                        08/07/2009   0.3       S. Baron (CERN)       Cosmetic and minor modifications.
--
--                        04/07/2013   3.0       M. Barros Marin       Cosmetic and minor modifications.   
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

entity gbt_rx_decoder_gbtframe_rsdec is
   port (
   
      --========--
      -- Inputs --
      --========--
   
      RX_COMMON_FRAME_ENCODED_I                 : in  std_logic_vector(59 downto 0);
      RX_COMMON_FRAME_O                         : out std_logic_vector(43 downto 0);
   
      --========--
      -- Output --
      --========--

      ERROR_DETECT_O                            : out std_logic
      
   );
end gbt_rx_decoder_gbtframe_rsdec;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture structural of gbt_rx_decoder_gbtframe_rsdec is

   --================================ Signal Declarations ================================--
   
   signal s1_from_syndromes                     : std_logic_vector( 3 downto 0);
   signal s2_from_syndromes                     : std_logic_vector( 3 downto 0);
   signal s3_from_syndromes                     : std_logic_vector( 3 downto 0);
   signal s4_from_syndromes                     : std_logic_vector( 3 downto 0);

   signal detIsZero_from_lambdaDeterminant      : std_logic;

   signal error1loc_from_errorLocPolynomial     : std_logic_vector( 3 downto 0);
   signal error2loc_from_errorLocPolynomial     : std_logic_vector( 3 downto 0);
   
   signal xx0_from_chienSearch                  : std_logic_vector( 3 downto 0);
   signal xx1_from_chienSearch                  : std_logic_vector( 3 downto 0);
   
   signal corCoeffs_from_rsTwoErrorsCorrect     : std_logic_vector(59 downto 0);

   --=====================================================================================--
   
--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--  
  
   --==================================== User Logic =====================================--   
  
   syndromes: entity work.gbt_rx_decoder_gbtframe_syndrom
      port map ( 
         POLY_COEFFS_I                          => RX_COMMON_FRAME_ENCODED_I,
         S1_O                                   => s1_from_syndromes,
         S2_O                                   => s2_from_syndromes,
         S3_O                                   => s3_from_syndromes,
         S4_O                                   => s4_from_syndromes
      );

   lambdaDeterminant: entity work.gbt_rx_decoder_gbtframe_lmbddet
      port map (
         S1_I                                   => s1_from_syndromes,
         S2_I                                   => s2_from_syndromes,
         S3_I                                   => s3_from_syndromes,
         DET_IS_ZERO_O                          => detIsZero_from_lambdaDeterminant
      );

   errorLocPolynomial: entity work.gbt_rx_decoder_gbtframe_errlcpoly
      port map (
         S1_I                                   => s1_from_syndromes,
         S2_I                                   => s2_from_syndromes,
         S3_I                                   => s3_from_syndromes,
         S4_I                                   => s4_from_syndromes,
         DET_IS_ZERO_I                          => detIsZero_from_lambdaDeterminant,
         ERROR_1_LOC_O                          => error1loc_from_errorLocPolynomial,
         ERROR_2_LOC_O                          => error2loc_from_errorLocPolynomial
      );

   chienSearch: entity work.gbt_rx_decoder_gbtframe_chnsrch
      port map (
         ERROR_1_LOC_I                          => error1loc_from_errorLocPolynomial,
         ERROR_2_LOC_I                          => error2loc_from_errorLocPolynomial,
         DET_IS_ZERO_I                          => detIsZero_from_lambdaDeterminant,
         XX0_O                                  => xx0_from_chienSearch,
         XX1_O                                  => xx1_from_chienSearch
      );

   rsTwoErrorsCorrect: entity work.gbt_rx_decoder_gbtframe_rs2errcor
      port map(
         Rx_240M_WordClk_I                              =>'0',
         S1_I                                   => s1_from_syndromes,
         S2_I                                   => s2_from_syndromes,
         XX0_I                                  => xx0_from_chienSearch,
         XX1_I                                  => xx1_from_chienSearch,
         REC_COEFFS_I                           => RX_COMMON_FRAME_ENCODED_I,
         DET_IS_ZERO_I                          => detIsZero_from_lambdaDeterminant,
         COR_COEFFS_O                           => corCoeffs_from_rsTwoErrorsCorrect
      );

   RX_COMMON_FRAME_O <= RX_COMMON_FRAME_ENCODED_I(59 downto 16) when    (s1_from_syndromes = x"0"
                                                                     and s2_from_syndromes = x"0"
                                                                     and s3_from_syndromes = x"0"
                                                                     and s4_from_syndromes = x"0") else
                        -------------------------------------------------------------------------------                                             
                        corCoeffs_from_rsTwoErrorsCorrect(59 downto 16);
                       
   ERROR_DETECT_O    <= '0' when     (s1_from_syndromes = X"0"
                                  and s2_from_syndromes = X"0"
                                  and s3_from_syndromes = X"0"
                                  and s4_from_syndromes = X"0") else
                        --------------------------------------------  
                        '1';
                        
   --=====================================================================================--  
end structural;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--