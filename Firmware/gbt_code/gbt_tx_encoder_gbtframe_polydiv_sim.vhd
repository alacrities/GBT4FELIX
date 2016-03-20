--=================================================================================================--
--##################################   Module Information   #######################################--
--=================================================================================================--
--                                                                                         
-- Company:               CERN (PH-ESE-BE)                                                         
-- Engineer:              Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)
--                                                                                                 
-- Project Name:          GBT-FPGA                                                                
-- Module Name:           GBT TX encoder GBT-Frame poly divider          
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
--                        10/05/2006   0.1       A. Marchioro (CERN)   First .v module definition.           
--                                                                   
--                        03/10/2008   0.2       F. Marin (CPPM)       Translate from .v to .vhd.
--                                                                   
--                        18/11/2013   3.0       M. Barros Marin       - Cosmetic and minor modifications.                                                                   
--                                                                     - "gf16mult" and "gf16add" are functions instead of modules. 
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

entity gbt_tx_encoder_gbtframe_polydiv is
   port (
   
      DIVIDER_I                                 : in   std_logic_vector(59 downto 0);
      DIVISOR_I                                 : in   std_logic_vector(19 downto 0);
      QUOTIENT_O                                : out   std_logic_vector(43 downto 0);
      REMAINDER_O                               : out   std_logic_vector(15 downto 0)
      
   );
end gbt_tx_encoder_gbtframe_polydiv;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture behavioral of gbt_tx_encoder_gbtframe_polydiv is

   --================================ Signal Declarations ================================--
   
   signal divider                               : polyDivider_divider_15x4bit_A;
   signal divisor                               : polyDivider_divisor_5x4bit_A;
   signal quotient                              : polyDivider_quotient_11x4bit_A;
   signal remainder                             : polyDivider_remainder_4x4bit_A;
   signal net                                   : polyDivider_net_89x4bit_A;

   --=====================================================================================--
   
--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--  
   
   --==================================== User Logic =====================================--
   
   combinatorial: process(DIVIDER_I, DIVISOR_I, divider, divisor, quotient, remainder, net)
   begin      
      
      --=============--
      -- Assignments --
      --=============--
      
      -- Divider:
      -----------
      
      for i in 0 to 14 loop
         divider(i)                             <= DIVIDER_I((4*i)+3 downto 4*i);
      end loop;
      
      -- Divisor:
      -----------
      
      for i in 0 to 4 loop
         divisor(i)                             <= DIVISOR_I((4*i)+3 downto 4*i);
      end loop;
      
      -- Quotient:
      ------------
      
      for i in 0 to 10 loop
         QUOTIENT_O((4*i)+3 downto 4*i)         <= quotient(i);
      end loop;
      
      -- Remainder:
      -------------
      
      for i in 0 to 3 loop
         REMAINDER_O((4*i)+3 downto 4*i)        <= remainder(i);
      end loop;
      
      --========--
      -- Stages --
      --========--
      
      -- Stage 1:
      -----------
      
      quotient(10)                              <= divider(14);
      
      --for i in 0 to 3 loop   
         net(1+(2*0))                           <= gf16mult(divisor(3-0),divider(14));
         net(1+(2*1))                           <= gf16mult(divisor(3-1),divider(14));
         net(1+(2*2))                           <= gf16mult(divisor(3-2),divider(14));
         net(1+(2*3))                           <= gf16mult(divisor(3-3),divider(14));       
      --end loop;
      
      --for i in 0 to 3 loop   
         net(2+(2*0))                           <= gf16add(net(1+(2*0)),divider(13-0));
         net(2+(2*1))                           <= gf16add(net(1+(2*1)),divider(13-1));
         net(2+(2*2))                           <= gf16add(net(1+(2*2)),divider(13-2));
         net(2+(2*3))                           <= gf16add(net(1+(2*3)),divider(13-3));        
      --end loop;
   
      -- Stage 2:
      -----------
      
      quotient(9)                               <= net(2);
      
      --for i in 0 to 3 loop   
         net(9+(2*0))                           <= gf16mult(divisor(3-0),net(2));
         net(9+(2*1))                           <= gf16mult(divisor(3-1),net(2));
         net(9+(2*2))                           <= gf16mult(divisor(3-2),net(2));
         net(9+(2*3))                           <= gf16mult(divisor(3-3),net(2));        
      --end loop;
   
      --for i in 0 to 2 loop   
         net(10+(2*0))                          <= gf16add(net(9+(2*0)),net(4+(2*0)));
         net(10+(2*1))                          <= gf16add(net(9+(2*1)),net(4+(2*1)));
         net(10+(2*2))                          <= gf16add(net(9+(2*2)),net(4+(2*2)));      
      --end loop;
   
      net(16)                                   <= gf16add(net(15),divider(9));      
      
      -- Stage 3:      
      -----------
      
      quotient(8)                               <= net(10);
      
      --for i in 0 to 3 loop   
         net(17+(2*0))                          <= gf16mult(divisor(3-0),net(10));
         net(17+(2*1))                          <= gf16mult(divisor(3-1),net(10));
         net(17+(2*2))                          <= gf16mult(divisor(3-2),net(10));
         net(17+(2*3))                          <= gf16mult(divisor(3-3),net(10));             
      --end loop;
      
      --for i in 0 to 2 loop   
         net(18+(2*0))                          <= gf16add(net(17+(2*0)),net(12+(2*0)));
         net(18+(2*1))                          <= gf16add(net(17+(2*1)),net(12+(2*1)));
         net(18+(2*2))                          <= gf16add(net(17+(2*2)),net(12+(2*2)));      
      --end loop;
      
      net(24)                                   <= gf16add(net(23),divider(8));
      
      -- Stage 4:
      -----------
      
      quotient(7)                               <= net(18);
      
      --for i in 0 to 3 loop   
         net(25+(2*0))                          <= gf16mult(divisor(3-0),net(18));
         net(25+(2*1))                          <= gf16mult(divisor(3-1),net(18));
         net(25+(2*2))                          <= gf16mult(divisor(3-2),net(18));
         net(25+(2*3))                          <= gf16mult(divisor(3-3),net(18));      
      --end loop;
      
      --for i in 0 to 2 loop   
         net(26+(2*0))                          <= gf16add(net(25+(2*0)),net(20+(2*0)));
         net(26+(2*1))                          <= gf16add(net(25+(2*1)),net(20+(2*1)));
         net(26+(2*2))                          <= gf16add(net(25+(2*2)),net(20+(2*2)));        
      --end loop;
      
      net(32)                                   <= gf16add(net(31),divider(7));
   
      -- Stage 5:
      -----------
      
      quotient(6)                               <= net(26);
      
      --for i in 0 to 3 loop   
         net(33+(2*0))                          <= gf16mult(divisor(3-0),net(26));
         net(33+(2*1))                          <= gf16mult(divisor(3-1),net(26));
         net(33+(2*2))                          <= gf16mult(divisor(3-2),net(26));
         net(33+(2*3))                          <= gf16mult(divisor(3-3),net(26));                  
      --end loop;
      
      --for i in 0 to 2 loop   
         net(34+(2*0))                          <= gf16add(net(33+(2*0)),net(28+(2*0)));
         net(34+(2*1))                          <= gf16add(net(33+(2*1)),net(28+(2*1)));
         net(34+(2*2))                          <= gf16add(net(33+(2*2)),net(28+(2*2)));
      
      --end loop;
      
      net(40)                                   <= gf16add(net(39),divider(6));        
   
      -- Stage 6:
      -----------
      
      quotient(5)                               <= net(34);
      
      --for i in 0 to 3 loop   
         net(41+(2*0))                          <= gf16mult(divisor(3-0),net(34));
         net(41+(2*1))                          <= gf16mult(divisor(3-1),net(34));
         net(41+(2*2))                          <= gf16mult(divisor(3-2),net(34));
         net(41+(2*3))                          <= gf16mult(divisor(3-3),net(34));         
      --end loop;
      
      --for i in 0 to 2 loop   
         net(42+(2*0))                          <= gf16add(net(41+(2*0)),net(36+(2*0)));
         net(42+(2*1))                          <= gf16add(net(41+(2*1)),net(36+(2*1)));
         net(42+(2*2))                          <= gf16add(net(41+(2*2)),net(36+(2*2)));         
      --end loop;
      
      net(48)                                   <= gf16add(net(47),divider(5));
        
      -- Stage 7:
      -----------
      
      quotient(4)                               <= net(42);
      
      --for i in 0 to 3 loop   
         net(49+(2*0))                          <= gf16mult(divisor(3-0),net(42));
         net(49+(2*1))                          <= gf16mult(divisor(3-1),net(42));
         net(49+(2*2))                          <= gf16mult(divisor(3-2),net(42));
         net(49+(2*3))                          <= gf16mult(divisor(3-3),net(42));         
      --end loop;
      
      --for i in 0 to 2 loop   
         net(50+(2*0))                          <= gf16add(net(49+(2*0)),net(44+(2*0)));
         net(50+(2*1))                          <= gf16add(net(49+(2*1)),net(44+(2*1)));
         net(50+(2*2))                          <= gf16add(net(49+(2*2)),net(44+(2*2)));        
      --end loop;
      
      net(56)                                   <= gf16add(net(55),divider(4));
         
      -- Stage 8:
      -----------
      
      quotient(3)                               <= net(50);
      
      --for i in 0 to 3 loop   
         net(57+(2*0))                          <= gf16mult(divisor(3-0),net(50));
         net(57+(2*1))                          <= gf16mult(divisor(3-1),net(50));
         net(57+(2*2))                          <= gf16mult(divisor(3-2),net(50));
         net(57+(2*3))                          <= gf16mult(divisor(3-3),net(50));         
      --end loop;
      
      --for i in 0 to 2 loop   
         net(58+(2*0))                          <= gf16add(net(57+(2*0)),net(52+(2*0)));
         net(58+(2*1))                          <= gf16add(net(57+(2*1)),net(52+(2*1)));
         net(58+(2*2))                          <= gf16add(net(57+(2*2)),net(52+(2*2)));        
      --end loop;
      
      net(64)                                   <= gf16add(net(63),divider(3));         
      
      -- Stage 9:
      -----------
      
      quotient(2)                               <= net(58);
      
      --for i in 0 to 3 loop   
         net(65+(2*0))                          <= gf16mult(divisor(3-0),net(58));
         net(65+(2*1))                          <= gf16mult(divisor(3-1),net(58));
         net(65+(2*2))                          <= gf16mult(divisor(3-2),net(58));
         net(65+(2*3))                          <= gf16mult(divisor(3-3),net(58));        
      --end loop;
      
      --for i in 0 to 2 loop   
         net(66+(2*0))                          <= gf16add(net(65+(2*0)),net(60+(2*0)));
         net(66+(2*1))                          <= gf16add(net(65+(2*1)),net(60+(2*1)));
         net(66+(2*2))                          <= gf16add(net(65+(2*2)),net(60+(2*2)));         
      --end loop;
      
      net(72)                                   <= gf16add(net(71),divider(2));
         
      -- Stage 10:
      ------------
      
      quotient(1)                               <= net(66);
      
      for i in 0 to 3 loop   
         net(73+(2*0))                          <= gf16mult(divisor(3-0),net(66));
         net(73+(2*1))                          <= gf16mult(divisor(3-1),net(66));
         net(73+(2*2))                          <= gf16mult(divisor(3-2),net(66));
         net(73+(2*3))                          <= gf16mult(divisor(3-3),net(66));        
      end loop;
      
      for i in 0 to 2 loop   
         net(74+(2*0))                          <= gf16add(net(73+(2*0)),net(68+(2*0)));
         net(74+(2*1))                          <= gf16add(net(73+(2*1)),net(68+(2*1)));
         net(74+(2*2))                          <= gf16add(net(73+(2*2)),net(68+(2*2)));         
      end loop;
      
      net(80)                                   <= gf16add(net(79),divider(1));
      
      -- Stage 11:
      ------------
      
      quotient(0)                               <= net(74);
      
      for i in 0 to 3 loop   
         net(81+(2*0))                          <= gf16mult(divisor(3-0),net(74));
         net(81+(2*1))                          <= gf16mult(divisor(3-1),net(74));
         net(81+(2*2))                          <= gf16mult(divisor(3-2),net(74));
         net(81+(2*3))                          <= gf16mult(divisor(3-3),net(74));
      end loop;
      
      for i in 0 to 2 loop   
         net(82+(2*0))                          <= gf16add(net(81+(2*0)),net(76+(2*0)));
         net(82+(2*1))                          <= gf16add(net(81+(2*1)),net(76+(2*1)));
         net(82+(2*2))                          <= gf16add(net(81+(2*2)),net(76+(2*2)));         
      end loop;
      
      net(88)                                   <= gf16add(net(87),divider(0));         
      
      for i in 0 to 3 loop
         remainder(i)                           <= net(88-(2*i));
      end loop;
   
   end process;   
   
   --=====================================================================================--     
end behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
