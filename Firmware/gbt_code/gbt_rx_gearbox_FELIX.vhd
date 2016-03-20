----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Kai Chen
-- 
-- Create Date:     12/17/2014 
-- Description: 
--          Use shift register for the Rx GearBox
--          Also generate the Link status signal, the head flag
-- 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.FELIX_gbt_package.all;

entity gbt_rx_gearbox_FELIX is
  port (    
    ---- Ctrl & Status
    OddEven               : in 	std_logic;
    TopBot             : in  std_logic;
    HeaderFlag              : out std_logic; 
    HeaderLocked            : out std_logic;
    Descrambler_enable    : out std_logic;
    Rx_40M_FrameClk_O     : out std_logic;
    Rx_240M_WordClk_I     : in  std_logic;
    RX_ISDATA_FLAG_O     : out std_logic;

    RX_LATOPT_DES : in std_logic;
    Rx_Data_Format : in std_logic_vector(1 downto 0);
      
    ---- Data in & out
    Rx_Word_In             : in  std_logic_vector(19 downto 0);
    Rx_Frame_O            : out std_logic_vector(119 downto 0)
    );
end gbt_rx_gearbox_FELIX;

architecture Behavioral of gbt_rx_gearbox_FELIX is
  
  signal reg_inv, shiftreg, reg_inv_wb, reg_inv_gf	: std_logic_vector (119 downto 0);
  signal RxWordCnt			: std_logic_vector(2 downto 0);
  signal Rx_40M_FrameClk, Data_Header, Descrambler_enable_wb, Descrambler_enable_gf, Rx_40M_FrameClk_gf,Rx_40M_FrameClk_gf1, Rx_40M_FrameClk_wb,Descrambler_enable1,Descrambler_enable_gf1	: std_logic;
  signal errcnt				: std_logic_vector(1 downto 0) := "00";
  signal data_sel : std_logic_vector(1 downto 0):="00";
  signal Descrambler_enable_wb1,Rx_40M_FrameClk_wb1,Descrambler_enable_gf_r,Rx_40M_FrameClk_gf_r:std_logic;
  signal Rx_Word_I,Rx_Word_In_buf,Rx_Word_In_buf2: std_logic_vector (19 downto 0);
begin                

  Rx_40M_FrameClk_O <= Rx_40M_FrameClk;
    
  -- Inverter: copied from GBT-FPGA Core
  Frame_Data_Inverter: for i in 119 downto 0 generate
    Rx_Frame_O(i) <= reg_inv(119-i);
  end generate;
  
          
  -- DYNAMIC_DATA_MODE = '0'
  
  -- New RxGearBox designed for FELIX : Generate flags, control soignal, also do the alignment
     -- RxGearBox20b4p8G_GBT_FRAME : if DATA_MODE = GBT_FRAME  generate
        process(Rx_240M_WordClk_I)
        begin        
          if Rx_240M_WordClk_I'event and Rx_240M_WordClk_I = '1' then
            Rx_Word_In_buf <= Rx_Word_In;
            Rx_Word_In_buf2 <= Rx_Word_In_buf;
        
            
            
            case data_sel is
            when "00" =>
             Rx_Word_I <= Rx_Word_In_buf;
            when "01" =>
              Rx_Word_I <= Rx_Word_In_buf(18 downto 0) & Rx_Word_In_buf2(19);
            when "10" =>
               Rx_Word_I <= Rx_Word_In_buf(9 downto 0) & Rx_Word_In_buf2(19 downto 10);
            when others =>
               Rx_Word_I <= Rx_Word_In_buf(8 downto 0) & Rx_Word_In_buf2(19 downto 9);
            end case;
         
            case RxWordCnt(2 downto 0) is
              when "000" => 
             
                 
                Descrambler_enable_gf             <=    '1';
                             
                             Rx_40M_FrameClk_gf                      <=    '0';
                      
              when "001" => 
                
                
                Descrambler_enable_gf             <=    '0';
                                Rx_40M_FrameClk_gf                      <=    '0';
                      
              when "010" => 
                
               Descrambler_enable_gf             <=    '0';
                  
                                if RX_LATOPT_DESCRAMBLER = '1' and DYNAMIC_LATENCY_OPT = '0' then
                                                                  Rx_40M_FrameClk_gf                      <=    '1';
                                                                elsif RX_LATOPT_DES = '1' and DYNAMIC_LATENCY_OPT = '1' then
                                                                  Rx_40M_FrameClk_gf                          <=      '1';
                                                                else
                                                                  Rx_40M_FrameClk_gf                          <=      '0';
                                                                end if;
                  
              when "011" => 
               Descrambler_enable_gf             <=    '0';
                              Rx_40M_FrameClk_gf                     <=    '1';
              
                
  
               
                      
              when "100" =>  
                
                Descrambler_enable_gf             <=    '0';
                                Rx_40M_FrameClk_gf                     <=    '1';
                                
                 case data_sel is
                           when "00" =>
                            
                            reg_inv             <= Rx_Word_In_buf & Rx_Word_I & shiftreg(119 downto 40);
                           when "01" =>
                             reg_inv <= Rx_Word_In_buf(18 downto 0) & Rx_Word_In_buf2(19) & Rx_Word_I & shiftreg(119 downto 40);
                           when "10" =>
                              reg_inv <= Rx_Word_In_buf(9 downto 0) & Rx_Word_In_buf2(19 downto 10) & Rx_Word_I & shiftreg(119 downto 40);
                           when others =>
                              reg_inv <= Rx_Word_In_buf(8 downto 0) & Rx_Word_In_buf2(19 downto 9) & Rx_Word_I & shiftreg(119 downto 40);
                           end case;   
               
              when "101" => 
                --reg_inv             <= Rx_Word_I & shiftreg(119 downto 20);  
                      
                
                
                Descrambler_enable_gf             <=    '0';
                                
                                if RX_LATOPT_DESCRAMBLER = '1' and DYNAMIC_LATENCY_OPT = '0' then
                                                                  Rx_40M_FrameClk_gf                      <=    '0';
                                                                elsif RX_LATOPT_DES = '1' and DYNAMIC_LATENCY_OPT = '1' then
                                                                  Rx_40M_FrameClk_gf                          <=      '0';
                                                                else
                                                                  Rx_40M_FrameClk_gf                          <=      '1';
                                                                end if;    
               
              
              when others => 
               null;
            end case;
          end if;
        end process;     
     -- end generate;
      data_sel <= topbot & OddEven;
    
      -- New RxGearBox designed for FELIX : Generate flags, control soignal, also do the alignment
        --  RxGearBox20b4p8G_WIDE_BUS : if DATA_MODE = WIDE_BUS  generate
            process(Rx_240M_WordClk_I)
            begin        
              if Rx_240M_WordClk_I'event and Rx_240M_WordClk_I = '1' then
                shiftreg <= Rx_Word_I & shiftreg(119 downto 20);
                case RxWordCnt(2 downto 0) is
                  when "000" => 
                  
                           
                    if Rx_Word_I(3 downto 0)= DATA_HEADER_PATTERN_REVERSED-- or Rx_Word_I(2 downto 0) & shiftreg(119) = DATA_HEADER_PATTERN_REVERSED  
                  --    or shiftreg(113 downto 110) = DATA_HEADER_PATTERN_REVERSED then--or shiftreg(112 downto 109) = DATA_HEADER_PATTERN_REVERSED then
                     or  Rx_Word_I(3 downto 0)= IDLE_HEADER_PATTERN_REVERSED then
                    --  then
                    
                      Data_Header <='1';
                      RxWordCnt     <=     "001";
                      HeaderLocked     <=    '1';
                      errcnt         <=    "00";
               
                    elsif errcnt(1) = '0' then
                      errcnt         <=    errcnt + '1';
                      RxWordCnt     <=     "001";
                      HeaderLocked     <=    '1';
                    else        
                      RxWordCnt     <=     "000";
                      HeaderLocked     <=    '0';
                    end if;
                          
                    HeaderFlag             <=    '0';
                    
                     Descrambler_enable_wb     <=    '0';
                                     
                                     
                                       if RX_LATOPT_DESCRAMBLER = '1' and DYNAMIC_LATENCY_OPT = '0' then
                                                             Rx_40M_FrameClk_wb                      <=    '1';
                                                           elsif RX_LATOPT_DES = '1' and DYNAMIC_LATENCY_OPT = '1' then
                                                             Rx_40M_FrameClk_wb                          <=      '1';
                                                           else
                                                             Rx_40M_FrameClk_wb                          <=      '0';
                                                           end if;
                   
                    --Rx_40M_FrameClk     <=    '0';    
                          
                  when "001" => 
                  Descrambler_enable_wb     <=    '0';
                                      Rx_40M_FrameClk_wb      <=    '1';
                  
                   
                                        
                    
                    RxWordCnt             <=     "010";
                    HeaderFlag             <=    '0';
                          
                  when "010" => 
                  Descrambler_enable_wb     <=    '0';
                                      Rx_40M_FrameClk_wb      <=    '1';
                  
                    
                    RxWordCnt             <=     "011";
                    HeaderFlag             <=    '0';
                      
                  when "011" => 
                  Descrambler_enable_wb     <=    '0';
                                      if RX_LATOPT_DESCRAMBLER = '1' and DYNAMIC_LATENCY_OPT = '0' then
                                                            Rx_40M_FrameClk_wb                      <=    '0';
                                                          elsif RX_LATOPT_DES = '1' and DYNAMIC_LATENCY_OPT = '1' then
                                                            Rx_40M_FrameClk_wb                          <=      '0';
                                                          else
                                                            Rx_40M_FrameClk_wb                          <=      '1';
                                                          end if;
                  
                    
                    --Rx_40M_FrameClk     <=    '1';    
                    RxWordCnt             <=     "100";
                    HeaderFlag             <=    '0';
                          
                  when "100" =>  
                    
                        
                    RxWordCnt             <=     "101";
                    HeaderFlag             <=    '0';
                    
                    Descrambler_enable_wb     <=    '1';
                                        Rx_40M_FrameClk_wb      <=    '0';   
                      
                  when "101" => 
                  
                    RX_ISDATA_FLAG_O  <= Data_Header; 
                    
                    
                    HeaderFlag             <=    '1';
                    RxWordCnt             <=     "000";
                    
                     Descrambler_enable_wb    <=    '0';
                         
                                       Rx_40M_FrameClk_wb      <=    '0';
                  
                  when others => 
                    RxWordCnt             <=     "000";
                    HeaderFlag             <=    '0';
                end case;
              end if;
            end process;  
          --  reg_inv_wb     <= Rx_Word_I & shiftreg(119 downto 20) when OddEven = '0'
          --         else  Rx_Word_I(18 downto 0) & shiftreg(119 downto 19);  
                   
                   
        --  end generate;
    --      process(Rx_240M_WordClk_I)
    
     Lat3 : if FEC_LAT = 3 and SAME_LAT_FOR_WB_FEC='0' generate   
        Descrambler_enable <= Descrambler_enable_wb when Rx_Data_Format="01"  else
                   Descrambler_enable_gf;
        Rx_40M_FrameClk <= Rx_40M_FrameClk_wb when Rx_Data_Format="01" else
                                    Rx_40M_FrameClk_gf;
    
        end generate;
    
    Lat4 : if FEC_LAT = 4 and SAME_LAT_FOR_WB_FEC='0' generate
        Descrambler_enable <= Descrambler_enable_wb when Rx_Data_Format="01"  else
               Descrambler_enable_gf1;
        Rx_40M_FrameClk <= Rx_40M_FrameClk_wb when Rx_Data_Format="01" else
                                Rx_40M_FrameClk_gf1;
     end generate;   
     
     
     SAME_LAT3 : if SAME_LAT_FOR_WB_FEC='1' and FEC_LAT = 3 generate
       Descrambler_enable <=  Descrambler_enable_gf;
             Rx_40M_FrameClk <=   Rx_40M_FrameClk_gf;
     
     end generate;
     
     SAME_LAT4 : if SAME_LAT_FOR_WB_FEC='1' and FEC_LAT = 4 generate
            Descrambler_enable <=  Descrambler_enable_gf1;
                  Rx_40M_FrameClk <=   Rx_40M_FrameClk_gf1;
          
          end generate;
                             
--        process(Rx_240M_WordClk_I)
--              begin        
--                if Rx_240M_WordClk_I'event and Rx_240M_WordClk_I = '0' then
                
--                Descrambler_enable <= Descrambler_enable1;
                
--      end if;
--      end process;  
      
      process(Rx_240M_WordClk_I)
        begin        
          if Rx_240M_WordClk_I'event and Rx_240M_WordClk_I = '1' then
          Descrambler_enable_wb1 <= Descrambler_enable_wb;
          Rx_40M_FrameClk_wb1 <= Rx_40M_FrameClk_wb;
          
          Descrambler_enable_gf1 <= Descrambler_enable_gf;
          Rx_40M_FrameClk_gf1 <= Rx_40M_FrameClk_gf;

                      
            end if;
            end process; 
                           
    
                
end Behavioral;
