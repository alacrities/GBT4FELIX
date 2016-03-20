-------------------------------------------------------------------------------
-- Modified by K. Chen  @ Dec. 2014, Clock changed, control signal added.
-- Dynamic data mode change is added.
-------------------------------------------------------------------------------

--=================================================================================================--
--##################################   Module Information   #######################################--
--=================================================================================================--
--                                                                                         
-- Company:               CERN (PH-ESE-BE)                                                         
-- Engineer:              Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)
--                                                                                                 
-- Project Name:          GBT-FPGA                                                                
-- Module Name:           GBT RX descrambler                                        
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
-- Versions history:      DATE         VERSION   AUTHOR            DESCRIPTION
--                
--                        10/05/2009   0.1       F. Marin (CPPM)   First .bdf entity definition.           
--                
--                        08/07/2009   0.2       S. Baron (CERN)   Translate from .bdf to .vhd.
--
--                        13/06/2013   3.0       M.Barros Marin    - Cosmetic and minor modifications.
--                                                                 - Add Wide-Bus scrambling.
--
--                        01/09/2014   3.2       M. Barros Marin   Fixed generic issue (TX_ENCODING -> RX_ENCODING).  
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

entity gbt_rx_descrambler_FELIX is             
  port (   
      	    
    RX_RESET_I                                : in  std_logic;
    descrambler_enable                          : in std_logic;
    DATA_MODE_CFG                               : in std_logic_vector(1 downto 0);

    -- Clock:
    ---------
    RX_WORDCLK_I                           	: IN STD_LOGIC;
    RX_FRAMECLK_I                             : in  std_logic;
      
     
    --==============--           
    -- Frame & Data --           
    --==============-- 
      
    RX_HEADER_I : in std_logic_vector(3 downto 0);
    RX_HEADER_O : out std_logic_vector(3 downto 0);  
      
    -- Common:
    ----------
      
    RX_COMMON_FRAME_I                         : in  std_logic_vector(83 downto 0);
    RX_DATA_O                                 : out std_logic_vector(83 downto 0);
      
    -- Wide-Bus:
    ------------
      
    RX_EXTRA_FRAME_WIDEBUS_I                  : in  std_logic_vector(31 downto 0);
    RX_EXTRA_DATA_WIDEBUS_O                   : out std_logic_vector(31 downto 0)
      
   );
end gbt_rx_descrambler_FELIX;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture structural of gbt_rx_descrambler_FELIX is 

  signal RX_EXTRA_DATA_WIDEBUS_O_DES : std_logic_vector(31 downto 0);
--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--
  
   --==================================== User Logic =====================================--
   
  
   
  --============--
  -- Scramblers --
  --============--
 
   
  -- 84 bit scrambler (GBT-Frame & Wide-Bus):
  -------------------------------------------
   
  gbtFrameOrWideBus_gen: if (DATA_MODE = GBT_FRAME) or (DATA_MODE = WIDE_BUS) generate 
    
    gbtRxDescrambler84bit_gen: for i in 0 to 3 generate
      -- Comment: [83:63] & [62:42] & [41:21] & [20:0]
      
      gbtRxDescrambler21bit: entity work.gbt_rx_descrambler_21bit
        port map(
          RX_RESET_I                       => RX_RESET_I,
          RX_FRAMECLK_I                    => RX_WORDCLK_I,
          Descrambler_enable 				 => Descrambler_enable,
          RX_COMMON_FRAME_I                => RX_COMMON_FRAME_I(((21*i)+20) downto (21*i)), 
          RX_DATA_O                        => RX_DATA_O(((21*i)+20) downto (21*i))
          );
            
    end generate;
      
  end generate;
   
  -- 32 bit scrambler (Wide-Bus), for dynamic change, support GBT-FRAME too.
  ------------------------------
  wideBus_gen: if (DATA_MODE = GBT_FRAME) or (DATA_MODE = WIDE_BUS) generate
    gbtRxDescrambler32bit_gen: for i in 0 to 1 generate
      -- Comment: [31:16] & [15:0]
      gbtRxDescrambler16bit: entity work.gbt_rx_descrambler_16bit
        port map(
          RX_RESET_I                       	=> RX_RESET_I,
          RX_FRAMECLK_I                    	=> RX_WORDCLK_I,
          Descrambler_enable 					=> Descrambler_enable,
          RX_EXTRA_FRAME_WIDEBUS_I         	=> RX_EXTRA_FRAME_WIDEBUS_I(((16*i)+15) downto (16*i)),
          RX_EXTRA_DATA_WIDEBUS_O          	=> RX_EXTRA_DATA_WIDEBUS_O_DES(((16*i)+15) downto (16*i))
          );
         
    end generate; 
     
  end generate;

--  non_dynamic_sel: if DYNAMIC_DATA_MODE = "000" generate
    
--    process(RX_WORDCLK_I)
--    begin
--    if RX_WORDCLK_I'event and RX_WORDCLK_I='1' then
   
--    RX_HEADER_O <= RX_HEADER_I;
    
--    end if;
--    end process; 
--    RX_EXTRA_DATA_WIDEBUS_O <=  (others => '0') when DATA_MODE = GBT_FRAME
--                                else RX_EXTRA_DATA_WIDEBUS_O_DES;
                                
                           
--  end generate non_dynamic_sel;

  --dynamic_sel: if DYNAMIC_DATA_MODE /= "000" generate
    process(RX_WORDCLK_I)
      begin
        if RX_WORDCLK_I'event and RX_WORDCLK_I='1' then
          if descrambler_enable='1' then
             RX_HEADER_O <= RX_HEADER_I;
          end if;    
        end if;
    end process; 
    
    
    RX_EXTRA_DATA_WIDEBUS_O <=  (others => '0') when DATA_MODE_CFG = GBT_FRAME
                                else RX_EXTRA_DATA_WIDEBUS_O_DES;
                               
  --end generate dynamic_sel;
   
  --wideBus_no_gen: if DATA_MODE = GBT_FRAME generate
   
  --  RX_EXTRA_DATA_WIDEBUS_O                   <= (others => '0');
    
  --end generate;
   
  --===========--
  -- FELIX-8b10b --
  --===========--
  
  --  	Will be added. 
   
   --=====================================================================================--
end structural;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
