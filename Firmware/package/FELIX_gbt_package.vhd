-------------------------------------------
-- Kai Chen @ BNL
-- Dec. 2014
-- package file for FELIX GBT
-- the definition for encoder, decoder, scrambler is copied from CERN GBT-FPGA project
-------------------------------------------

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.numeric_std.all;

package FELIX_gbt_package is  
  

-- Line rate: 4.8G/9.6G
  -- '0': 4.8G, '1': 9.6G.
  constant TX_LINERATE                                  : std_logic_vector(23 downto 0) := x"000000";
  constant RX_LINERATE                                  : std_logic_vector(23 downto 0) := x"000000";
  constant FEC_LAT                                      : integer :=3;   --3 or 4
  constant TX_GEARBOX_LATCH_EN                          : std_logic:='0';--'1';
-- For 4.8G, 240M: 4.8G/240M=20
  constant WORD_WIDTH                                   : integer := 20; 
  type word_data_type                                   is array (natural range <>) of std_logic_vector(WORD_WIDTH-1 downto 0);
  type txrx20b_type 				        is array (natural range <>) of std_logic_vector(19 downto 0);
  type txrx40b_type 				        is array (natural range <>) of std_logic_vector(39 downto 0);
  type txrx116b_type 				        is array (natural range <>) of std_logic_vector(115 downto 0);
  type txrx120b_type 					is array (natural range <>) of std_logic_vector(119 downto 0);
  type txrx116b_24ch_type 				is array (23 downto 0) of std_logic_vector(115 downto 0);
  type txrx116b_12ch_type 				is array (11 downto 0) of std_logic_vector(115 downto 0);
  
-- Encoding/Decoding mode
-- GBT_FRAME: is also called FEC mode
  
  constant GBT_FRAME                                    : std_logic_vector(1 downto 0) := "00";
  constant WIDE_BUS                                     : std_logic_vector(1 downto 0) := "01";
  constant FELIX_8B10B                                  : std_logic_vector(1 downto 0) := "10";
  constant DATA_MODE                                    : std_logic_vector(1 downto 0) := GBT_FRAME;

-- GTH PLL selection
  -- When using GREFCLK, QPLL should be used
  constant CPLL                                         : std_logic := '0';
  constant QPLL                                         : std_logic := '1';
  constant PLL_SEL                                      : std_logic := QPLL;

---- The 40MHz source (generated from 240MHz) for the debugging
--  constant GTH_REFCLK                                  : std_logic := '0';
--  constant TX_OUT_CLK                                  : std_logic := '1';
--  constant TX_TEST_CLK                                 : std_logic := GTH_REFCLK;

-------------------------------------------------------------------------------
-- GTH RefClk source: GREFCLK only works for QPLL
-------------------------------------------------------------------------------

  constant GREFCLK                                      : std_logic := '1';
  constant MGTREFCLK                                    : std_logic := '0';
  constant GTHREFCLK_SEL                                : std_logic := GREFCLK;
  
-------------------------------------------------------------------------------
-- The RxUsrClk/TxUsrClk 240MHz source 
-------------------------------------------------------------------------------  

  constant MASTER_RXOUTCLK                              : std_logic := '0';
  constant LOCAL_GBTRXCLK                               : std_logic := '1';
  constant RX_CLK_SEL                                   : std_logic := LOCAL_GBTRXCLK;
    
  constant MASTER_TXOUTCLK                              : std_logic := '0';
  constant LOCAL_GBTTXCLK                               : std_logic := '1';
  constant TX_CLK_SEL                                   : std_logic := MASTER_TXOUTCLK;--LOCAL_GBTTXCLK;--MASTER_TXOUTCLK;

-------------------------------------------------------------------------------
-- GBT Decoder mode
-------------------------------------------------------------------------------  

  constant COMB                                         : std_logic := '0';
  constant SYNC                                         : std_logic := '1';
  constant DECODER_MODE                                 : std_logic := COMB;
  -- SYNC mode is not finished yet
  
-------------------------------------------------------------------------------
-- Latency optimization
------------------------------------------------------------------------------- 
  constant DYNAMIC_LATENCY_OPT          : std_logic := '1';
  -- '1': support dynamic latency optimization configuration

  -- When don't support dynamic latency optimization configuration
  constant TX_LATOPT_SCRAMBLER          : std_logic := '1';  -- '1': samller latency
  constant TX_LATOPT_TIMECROSSING       : std_logic := '1';  -- '1': smaller latency
  constant RX_LATOPT_DESCRAMBLER        : std_logic := '1';  -- '1': smaller latency


  -- backup
  constant GF_DELAY3                    : std_logic := '1';
  -- '1': 12 ns for GBT-FRAME decoder, else: 16 ns.

-------------------------------------------------------------------------------
-- GBT mode selection
------------------------------------------------------------------------------- 
  constant DYNAMIC_DATA_MODE_EN         : std_logic :='1';
  -- '1' support dynamic mode change

  -- When don't support dynamic mode change, set the default value below
  constant GBT_DATA_TXFORMAT_PACKAGE    : std_logic_vector(47 downto 0) := x"555555555555";
  constant GBT_DATA_RXFORMAT_PACKAGE    : std_logic_vector(47 downto 0) := x"555555555555";

-------------------------------------------------------------------------------
-- RXGEARBOX method selection
-- TX Scrambler time domain crossing from 40 to 240 method selection
-------------------------------------------------------------------------------  
  constant RXGEARBOX_MODE               : std_logic:='0';
  constant TX_TC_DYNAMIC_EN             : std_logic:='1';
  constant TX_SCRAMBLER_SEL             : std_logic := '0';
  constant TXUSRCLK_PHASE_180           : std_logic_vector(23 downto 0) := x"000000";
  
  
  constant TX_DLY_SW_CTRL				: std_logic :='1';
  constant TX_TC_DLY_VALUE_package      : std_logic_vector(2 downto 0) :="000";
  constant RX_DESCR_MUX_EN              : std_logic := '0';
  constant SAME_LAT_FOR_WB_FEC          : std_logic := '0';
  
-------------------------------------------------------------------------------
-- TX side Phase adjust for the debugging, for the test purpose
-------------------------------------------------------------------------------  
  constant phase_adjust                 : std_logic:='0';

-------------------------------------------------------------------------------
-- Register type definition
-------------------------------------------------------------------------------  

   type GTH_CTRL_REG_T                                  is array (0 to 7) of std_logic_vector(63 downto 0);
   type GTH_STATUS_REG_T                                is array (0 to 7) of std_logic_vector(63 downto 0);
   type GENERAL_CTRL_REG_T                              is array (0 to 7) of std_logic_vector(63 downto 0);
   type GENERAL_STATUS_REG_T                            is array (0 to 7) of std_logic_vector(63 downto 0);
   type GBT_CTRL_REG_T                                  is array (0 to 15) of std_logic_vector(63 downto 0);
   type GBT_STATUS_REG_T                                is array (0 to 15) of std_logic_vector(63 downto 0);
   
-------------------------------------------------------------------------------
-- GBT & GTH version
-------------------------------------------------------------------------------
  -- bit 0 PLL_SEL
  -- bit 1 RX_CLK_SEL
  -- bit 2 GTHREFCLK_SEL
  -- bit 15-3 : reserved
  -- bit 31-16 : GTH IP version
  -- bit 47-32: GBT Version
  --  bit 63-48: Data
  --chnum : std_logic_vector(4 downto 0): conv_std_logic_vector(CH_NUM, 5);
  constant GBT_VERSION                                  : std_logic_vector(63 downto 0) := "00" & "01111" & "0101" & "01100" & x"0101" & x"0304" & "0000000000000" & GTHREFCLK_SEL & RX_CLK_SEL & PLL_SEL;

-------------------------------------------------------------------------------
-- The below definition is copied from CERNGBT-FPGA project
-- for the decoder/encoder/scrambler
-------------------------------------------------------------------------------
   -- Scrambler:
   -------------
   
   type scramblerResetPatterns_21bit_A          is array (natural range <>) of std_logic_vector(20 downto 0);
   type scramblerResetPatterns_16bit_A          is array (natural range <>) of std_logic_vector(15 downto 0);
   
   -- GBT-Frame encoder:
   ---------------------

   type polyDivider_divider_15x4bit_A           is array(0 to 14) of std_logic_vector(3 downto 0);
   type polyDivider_divisor_5x4bit_A            is array(0 to  4) of std_logic_vector(3 downto 0);
   type polyDivider_quotient_11x4bit_A          is array(0 to 10) of std_logic_vector(3 downto 0);
   type polyDivider_remainder_4x4bit_A          is array(0 to  3) of std_logic_vector(3 downto 0);
   type polyDivider_net_89x4bit_A               is array(0 to 88) of std_logic_vector(3 downto 0);
   
   -- GBT-Frame decoder:
   ---------------------
   
   type syndromes_alphaPower_4x60bit_A          is array(1 to  4         ) of std_logic_vector(59 downto 0); 
   type syndromes_net1_4x15x4bit_A              is array(1 to  4, 0 to 14) of std_logic_vector( 3 downto 0);
   type syndromes_net2_4x7x4bit_A               is array(1 to  4, 0 to  6) of std_logic_vector( 3 downto 0);
   type syndromes_net3_4x4x4bit_A               is array(1 to  4, 0 to  3) of std_logic_vector( 3 downto 0);
   type syndromes_net4_4x2x4bit_A               is array(1 to  4, 0 to  1) of std_logic_vector( 3 downto 0);
   type syndromes_syndrome_4x4bit_A             is array(1 to  4         ) of std_logic_vector( 3 downto 0);
   ---------------------------------------------
   type errlcpoly_invertedS_3x4bit_A            is array(1 to  3) of std_logic_vector( 3 downto 0);
   type errlcpoly_net_18x4bit_A                 is array(1 to 18) of std_logic_vector( 3 downto 0);
   ---------------------------------------------
   type rs2errcor_net_11x4bit_A                 is array(1 to 11) of std_logic_vector( 3 downto 0);
   type rs2errcor_temp_6x60bit_A                is array(1 to  6) of std_logic_vector(59 downto 0);
   ---------------------------------------------
   type gf16shift_g_4x15bit_A                   is array(0 to  3) of bit_vector(14 downto 0);  
   
   --=====================================================================================--   
   
  
   --=====================================================================================--
   
   --=============================== Constant Declarations ===============================--
   
   --========--
   -- Common --
   --========--
   
   -- GBT-Frame header:
   --------------------
   
   constant DATA_HEADER_PATTERN                 : std_logic_vector(3 downto 0) := "0101";                   
   constant DATA_HEADER_PATTERN_REVERSED        : std_logic_vector(3 downto 0) := DATA_HEADER_PATTERN(0) &
                                                                                  DATA_HEADER_PATTERN(1) &
                                                                                  DATA_HEADER_PATTERN(2) &
                                                                                  DATA_HEADER_PATTERN(3);   
   
   constant IDLE_HEADER_PATTERN                 : std_logic_vector(3 downto 0) := "0110";                   
   constant IDLE_HEADER_PATTERN_REVERSED        : std_logic_vector(3 downto 0) := IDLE_HEADER_PATTERN(0) &
                                                                                  IDLE_HEADER_PATTERN(1) &
                                                                                  IDLE_HEADER_PATTERN(2) &
                                                                                  IDLE_HEADER_PATTERN(3);   

 
 
   
   --=================--
   -- GBT Transmitter -- 
   --=================--
   
   -- 84bit scrambler (GBT-Frame & Wide-Bus):
   ------------------------------------------
   
   -- Comment: Value of SCRAMBLER_21BIT_RESET_PATTERNS[1:4] chosen arbitrarily except the
   --          last byte (=0 because it is OR-ed with i during multiple instantiations).
   
   constant SCRAMBLER_21BIT_RESET_PATTERNS      : scramblerResetPatterns_21bit_A := ('1' & x"A23E0",
                                                                                     '0' & x"F4350",
                                                                                     '1' & x"3EDC0",
                                                                                     '0' & x"78E20"); 

   -- 32bit scrambler (Wide-Bus):
   ------------------------------
   
   -- Comment: Value of SCRAMBLER_16BIT_RESET_PATTERNS[1:2] chosen arbitrarily except the 
   --          last byte (=0 because it is OR-ed with i during multiple instantiations).
   
   constant SCRAMBLER_16BIT_RESET_PATTERNS      : scramblerResetPatterns_16bit_A := (x"23E0",
                                                                                     x"4350");                                                                                
   
   --==============--
   -- GBT Receiver -- 
   --==============--
   
   -- GBT-Frame decoder syndromes:
   -------------------------------
   
   constant ALPHAPOWER_S                        : syndromes_alphaPower_4x60bit_A := (x"9DFE7A5BC638421",
                                                                                     x"DEAB6829F75C341",
                                                                                     x"FAC81FAC81FAC81",
                                                                                     x"EB897C4DA62F531");
   -- GBT-Frame decider chien search:
   ----------------------------------
   
   constant ALPHAS                              : std_logic_vector(59 downto 0)  :=  x"fedcba987654321";
   
   
   --=====================================================================================--  

   --======================== Function and Procedure Declarations ========================--
   
   --========--
   -- Common --
   --========--
   
   -- GBT-Frame encoding:
   ----------------------
   
   function gf16add  (signal   input1, input2   : in std_logic_vector( 3 downto 0)) return std_logic_vector;                                 
   ---------------------------------------------------------------------------------------------------------
   function gf16mult (signal   input1           : in std_logic_vector( 3 downto 0);
                      constant input2           : in std_logic_vector( 3 downto 0)) return std_logic_vector;
   ---------------------------------------------------------------------------------------------------------
   function gf16invr (signal   input            : in std_logic_vector( 3 downto 0)) return std_logic_vector;
   ---------------------------------------------------------------------------------------------------------
   function gf16loga (signal   input            : in std_logic_vector( 3 downto 0)) return std_logic_vector;
   ---------------------------------------------------------------------------------------------------------
   function gf16shift(signal   input            : in std_logic_vector(59 downto 0);
                      signal   shift            : in std_logic_vector( 3 downto 0)) return std_logic_vector;
   
   --=====================================================================================--   
end FELIX_gbt_package;

--=================================================================================================--
--#####################################   Package Body   ##########################################--
--=================================================================================================--

package body FELIX_gbt_package is

   --=========================== Function and Procedure Bodies ===========================--

   --========--
   -- Common --
   --========--
   
   -- GBT-Frame encoding:
   ----------------------
   
   function gf16add(signal input1, input2 : in std_logic_vector(3 downto 0)) return std_logic_vector is
      variable output                           : std_logic_vector(3 downto 0);
   begin
      output(0)                                 := input1(0) xor input2(0);
      output(1)                                 := input1(1) xor input2(1);
      output(2)                                 := input1(2) xor input2(2);
      output(3)                                 := input1(3) xor input2(3);
      return output;
   end function;

   function gf16mult(signal   input1 : in std_logic_vector(3 downto 0);
                     constant input2 : in std_logic_vector(3 downto 0)) return std_logic_vector is       
      variable output                           : std_logic_vector(3 downto 0);
   begin
      output(0) := (input1(0) and input2(0)) xor (input1(3) and input2(1)) xor (input1(2) and input2(2)) xor (input1(1) and input2(3));
      output(1) := (input1(1) and input2(0)) xor (input1(0) and input2(1)) xor (input1(3) and input2(1)) xor (input1(2) and input2(2)) xor (input1(3) and input2(2)) xor (input1(1) and input2(3)) xor (input1(2) and input2(3));
      output(2) := (input1(2) and input2(0)) xor (input1(1) and input2(1)) xor (input1(0) and input2(2)) xor (input1(3) and input2(2)) xor (input1(2) and input2(3)) xor (input1(3) and input2(3));
      output(3) := (input1(3) and input2(0)) xor (input1(2) and input2(1)) xor (input1(1) and input2(2)) xor (input1(0) and input2(3)) xor (input1(3) and input2(3));
      return output;
   end function;  

   function gf16invr(signal input : in std_logic_vector(3 downto 0)) return std_logic_vector is
      variable output                           : std_logic_vector(3 downto 0);
   begin
      case input is
         when "0000" => output := "0000";   
         when "0001" => output := "0001";   
         when "0010" => output := "1001";   
         when "0011" => output := "1110";   
         when "0100" => output := "1101";   
         when "0101" => output := "1011";   
         when "0110" => output := "0111";   
         when "0111" => output := "0110";   
         when "1000" => output := "1111";   
         when "1001" => output := "0010";   
         when "1010" => output := "1100";   
         when "1011" => output := "0101";   
         when "1100" => output := "1010";   
         when "1101" => output := "0100";   
         when "1110" => output := "0011";   
         when "1111" => output := "1000";   
         when others => output := "0000";   -- Comment: Value selected randomly.   
      end case;      
      return output;
   end function;

   function gf16loga(signal input : in std_logic_vector(3 downto 0)) return std_logic_vector is    
      variable output                           : std_logic_vector(3 downto 0);
   begin
      case input is
         when "0000" => output := "0000";   
         when "0001" => output := "0000";   
         when "0010" => output := "0001";   
         when "0011" => output := "0100";   
         when "0100" => output := "0010";   
         when "0101" => output := "1000";   
         when "0110" => output := "0101";   
         when "0111" => output := "1010";   
         when "1000" => output := "0011";   
         when "1001" => output := "1110";   
         when "1010" => output := "1001";   
         when "1011" => output := "0111";   
         when "1100" => output := "0110";   
         when "1101" => output := "1101";   
         when "1110" => output := "1011";   
         when "1111" => output := "1100";   
         when others => output := "0000";   -- Comment: Value selected randomly. 
      end case;
      return output;
   end function; 
   
   function gf16shift(signal input : in std_logic_vector(59 downto 0); 
                      signal shift : in std_logic_vector( 3 downto 0)) return std_logic_vector is    
      variable ing                              : gf16shift_g_4x15bit_A;
      variable outg                             : gf16shift_g_4x15bit_A;                      
      variable output                           : std_logic_vector(59 downto 0);
   begin
      ing_loop1: for i in 0 to 3 loop
         ing_loop2: for j in 0 to 14 loop
            ing(i)(j)                           := to_bitvector(input)(i + j*4);
         end loop;
      end loop;
      ------------------------------------------
      outg_loop: for i in 0 to 3 loop
         outg(i)                                := ing(i) sll to_integer(unsigned(shift));   -- Comment: The operator "sll" shall be used with the type "bit_vector".
      end loop;
      ------------------------------------------
      output_loop: for i in 0 to 14 loop
         output((i*4)+3 downto i*4)             := to_stdlogicvector(outg(3)(i) & outg(2)(i) & outg(1)(i) & outg(0)(i));
      end loop;
      ------------------------------------------
      return output;
   end function;  
   
   --=====================================================================================--   
end FELIX_gbt_package;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
