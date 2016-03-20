
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

entity gbt_rx_decoder_gbtframe_rsdec_sync is
   port (
   
      --========--
      -- Inputs --
      --========--
      Rx_240M_WordClk_I  : in std_logic;
      RX_COMMON_FRAME_ENCODED_I                 : in  std_logic_vector(59 downto 0);
      RX_COMMON_FRAME_O                         : out std_logic_vector(43 downto 0);
   
      --========--
      -- Output --
      --========--

      ERROR_DETECT_O                            : out std_logic
      
   );
end gbt_rx_decoder_gbtframe_rsdec_sync;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture structural of gbt_rx_decoder_gbtframe_rsdec_sync is

   --================================ Signal Declarations ================================--
   
   signal s1_from_syndromes   ,s1_from_syndromes_buf, s1_from_syndromes_r                  : std_logic_vector( 3 downto 0);
   signal s2_from_syndromes   ,s2_from_syndromes_buf, s2_from_syndromes_r                  : std_logic_vector( 3 downto 0);
   signal s3_from_syndromes   ,s3_from_syndromes_buf ,s3_from_syndromes_r                 : std_logic_vector( 3 downto 0);
   signal s4_from_syndromes  ,s4_from_syndromes_buf ,s4_from_syndromes_r                  : std_logic_vector( 3 downto 0);

   signal detIsZero_from_lambdaDeterminant  ,detIsZero_from_lambdaDeterminant_buf    : std_logic;

   signal error1loc_from_errorLocPolynomial ,error1loc_from_errorLocPolynomial_buf   : std_logic_vector( 3 downto 0);
   signal error2loc_from_errorLocPolynomial  ,error2loc_from_errorLocPolynomial_buf   : std_logic_vector( 3 downto 0);
   
   signal xx0_from_chienSearch  ,xx0_from_chienSearch_buf                : std_logic_vector( 3 downto 0);
   signal xx1_from_chienSearch   ,xx1_from_chienSearch_buf               : std_logic_vector( 3 downto 0);
   
   signal corCoeffs_from_rsTwoErrorsCorrect  ,corCoeffs_from_rsTwoErrorsCorrect_buf   : std_logic_vector(59 downto 0);

   --=====================================================================================--
   
--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--  
  
   --==================================== User Logic =====================================--   
  
   
   
   -- cycle 1
   syndromes: entity work.gbt_rx_decoder_gbtframe_syndrom
      port map ( 
         POLY_COEFFS_I                          => RX_COMMON_FRAME_ENCODED_I,
         S1_O                                   => s1_from_syndromes_buf,
         S2_O                                   => s2_from_syndromes_buf,
         S3_O                                   => s3_from_syndromes_buf,
         S4_O                                   => s4_from_syndromes_buf
      );
 
   lambdaDeterminant: entity work.gbt_rx_decoder_gbtframe_lmbddet
      port map (
         S1_I                                   => s1_from_syndromes_buf,
         S2_I                                   => s2_from_syndromes_buf,
         S3_I                                   => s3_from_syndromes_buf,
         DET_IS_ZERO_O                          => detIsZero_from_lambdaDeterminant_buf
      );
    
    
    process(Rx_240M_WordClk_I)
    begin
    if Rx_240M_WordClk_I'event and Rx_240M_WordClk_I='1' then
      detIsZero_from_lambdaDeterminant <= detIsZero_from_lambdaDeterminant_buf;
      s1_from_syndromes <= s1_from_syndromes_buf;
      s2_from_syndromes <= s2_from_syndromes_buf;
      s1_from_syndromes_r <= s1_from_syndromes;
      s2_from_syndromes_r <= s2_from_syndromes;
      s3_from_syndromes_r <= s3_from_syndromes;
      s4_from_syndromes_r <= s4_from_syndromes;
      s3_from_syndromes <= s3_from_syndromes_buf;
      s4_from_syndromes <= s4_from_syndromes_buf;
    
    end if;
    end process;
    --cycle 2
   errorLocPolynomial: entity work.gbt_rx_decoder_gbtframe_errlcpoly
      port map (
         S1_I                                   => s1_from_syndromes,
         S2_I                                   => s2_from_syndromes,
         S3_I                                   => s3_from_syndromes,
         S4_I                                   => s4_from_syndromes,
         DET_IS_ZERO_I                          => detIsZero_from_lambdaDeterminant,
         ERROR_1_LOC_O                          => error1loc_from_errorLocPolynomial_buf,
         ERROR_2_LOC_O                          => error2loc_from_errorLocPolynomial_buf
      );
  --cycle 3
   chienSearch: entity work.gbt_rx_decoder_gbtframe_chnsrch
      port map (
         ERROR_1_LOC_I                          => error1loc_from_errorLocPolynomial,
         ERROR_2_LOC_I                          => error2loc_from_errorLocPolynomial,
         DET_IS_ZERO_I                          => detIsZero_from_lambdaDeterminant,
         XX0_O                                  => xx0_from_chienSearch_buf,
         XX1_O                                  => xx1_from_chienSearch_Buf
      );


     process(Rx_240M_WordClk_I)
    begin
    if Rx_240M_WordClk_I'event and Rx_240M_WordClk_I='1' then
      xx0_from_chienSearch <= xx0_from_chienSearch_buf;
      xx1_from_chienSearch <= xx1_from_chienSearch_Buf;
      error1loc_from_errorLocPolynomial <= error1loc_from_errorLocPolynomial_buf;
      error2loc_from_errorLocPolynomial <= error2loc_from_errorLocPolynomial_buf;
      
    
    end if;
    end process;

corCoeffs_from_rsTwoErrorsCorrect  <= corCoeffs_from_rsTwoErrorsCorrect_buf;
   rsTwoErrorsCorrect: entity work.gbt_rx_decoder_gbtframe_rs2errcor
      port map(
         Rx_240M_WordClk_I  => Rx_240M_WordClk_I,
         S1_I                                   => s1_from_syndromes_r,
         S2_I                                   => s2_from_syndromes_r,
         XX0_I                                  => xx0_from_chienSearch_buf,
         XX1_I                                  => xx1_from_chienSearch_buf,
         REC_COEFFS_I                           => RX_COMMON_FRAME_ENCODED_I,
         DET_IS_ZERO_I                          => detIsZero_from_lambdaDeterminant,
         COR_COEFFS_O                           => corCoeffs_from_rsTwoErrorsCorrect_buf
      );

   RX_COMMON_FRAME_O <= RX_COMMON_FRAME_ENCODED_I(59 downto 16) when    (s1_from_syndromes_r = x"0"
                                                                     and s2_from_syndromes_r = x"0"
                                                                     and s3_from_syndromes_r = x"0"
                                                                     and s4_from_syndromes_r = x"0") else
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
