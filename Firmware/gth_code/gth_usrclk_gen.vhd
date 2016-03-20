--Kai Chen@ Jan. 2015


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

use work.FELIX_gbt_package.all;
--***********************************Entity Declaration*******************************
entity gth_usrclk_gen is
port
(
 
    GTREFCLK_IN                         : in  std_logic;
    L240M_RX                            : in  std_logic;
    L240M_TX                            : in  std_logic;
    GT0_TXUSRCLK_OUT                    : out std_logic;
    GT0_TXOUTCLK_IN                     : in  std_logic;

    GT1_TXUSRCLK_OUT                    : out std_logic;
    GT1_TXOUTCLK_IN                     : in  std_logic;
    
    GT2_TXUSRCLK_OUT                    : out std_logic;
    GT2_TXOUTCLK_IN                     : in  std_logic;
    
    GT3_TXUSRCLK_OUT                    : out std_logic;
    GT3_TXOUTCLK_IN                     : in  std_logic;        
    
    GT0_RXUSRCLK_OUT                    : out std_logic;
    GT0_RXOUTCLK_IN                     : in  std_logic;
 
    GT1_RXUSRCLK_OUT                    : out std_logic;
    GT1_RXOUTCLK_IN                     : in  std_logic;
    
    GT2_RXUSRCLK_OUT                    : out std_logic;
    GT2_RXOUTCLK_IN                     : in  std_logic;
 
    GT3_RXUSRCLK_OUT                    : out std_logic;
    GT3_RXOUTCLK_IN                     : in  std_logic;
    
    clksample                           : out std_logic_vector(3 downto 0)
 
);


end gth_usrclk_gen;

architecture RTL of gth_usrclk_gen is



--*********************************Wire Declarations**********************************

    signal   tied_to_ground_i     :   std_logic;
    signal   tied_to_vcc_i        :   std_logic;
 
    signal   gt0_txoutclk_i :   std_logic;
    signal   gt0_rxoutclk_i :   std_logic;
 
    signal   gt1_txoutclk_i :   std_logic;
    signal   gt1_rxoutclk_i :   std_logic;
 
    signal   gt2_txoutclk_i :   std_logic;
    signal   gt2_rxoutclk_i :   std_logic;
 
    signal   gt3_txoutclk_i :   std_logic;
    signal   gt3_rxoutclk_i :   std_logic;

    
    
    attribute syn_noclockbuf : boolean;
    
    signal   q2_clk0_gtrefclk :   std_logic;
    attribute syn_noclockbuf of q2_clk0_gtrefclk : signal is true;

    signal  gt0_txusrclk_i                  : std_logic;
    signal  gt0_rxusrclk_i                  : std_logic;
    signal  gt1_rxusrclk_i                  : std_logic;
    signal  gt2_rxusrclk_i                  : std_logic;
    signal  gt3_rxusrclk_i                  : std_logic;
    
  

begin

  txclkgen_sys : if TX_CLK_SEL = MASTER_TXOUTCLK generate 
    txoutclk_bufg0_i : BUFG
      port map
      (
        I                               =>      GT0_TXOUTCLK_IN,
        O                               =>      gt0_txusrclk_i
        );
  end generate;

  txclkgen_local : if TX_CLK_SEL = LOCAL_GBTTXCLK generate 
-- txoutclk_bufg0_i : BUFG
-- port map
-- (
--     I                               =>      L240M_TX,
--     O                               =>      gt0_txusrclk_i
-- );
    gt0_txusrclk_i <= L240M_TX;
  end generate;

  clkgen_sys : if RX_CLK_SEL = MASTER_RXOUTCLK generate   
    
    rxoutclk_bufg1_i : BUFG
    port map
    (
      I                               =>      GT0_RXOUTCLK_IN,
      O                               =>      gt0_rxusrclk_i
      );



    bufh3 : BUFH
      port map
      (
        I                               =>      GT3_RXOUTCLK_IN,
        O                               =>      GT3_RXOUTCLK_I
        );
       
       
    bufh2 : BUFH
      port map
      (
        I                               =>      GT2_RXOUTCLK_IN,
        O                               =>      GT2_RXOUTCLK_I
        );
               
    bufh1 : BUFH
      port map
      (
        I                               =>      GT1_RXOUTCLK_IN,
        O                               =>      GT1_RXOUTCLK_I
        );
                    
         
    clksample(0)<='0';

    process(gt0_rxusrclk_i)
    begin
      if gt0_rxusrclk_i'event and gt0_rxusrclk_i='1' then
   
        clksample(1)<=GT1_RXOUTCLK_I;
        clksample(2)<=GT2_RXOUTCLK_I;
        clksample(3)<=GT3_RXOUTCLK_I;

      end if;
    end process;

  end generate;   

  clkgen_local : if RX_CLK_SEL = LOCAL_GBTRXCLK generate   

--       rxoutclk_bufg1_i : BUFR
--      port map
--      (
--         CE => '1',
--         clr => '0',
--          I                               =>      L240M,--GTREFCLK_IN,
--          O                               =>      gt0_rxusrclk_i
--      );


 --     rxoutclk_bufg1_i : BUFG
 --   port map
 --   (
 --       I                               =>       L240M_RX,--GTREFCLK_IN,
 --       O                               =>      gt0_rxusrclk_i
 --   );

    gt0_rxusrclk_i <= L240M_RX;

    bufh3 : BUFH
      port map
      (
        I                               =>      GT3_RXOUTCLK_IN,
        O                               =>      GT3_RXOUTCLK_I
        );
       
       
    bufh2 : BUFH
      port map
      (
        I                               =>      GT2_RXOUTCLK_IN,
        O                               =>      GT2_RXOUTCLK_I
        );
               
    bufh1 : BUFH
      port map
      (
        I                               =>      GT1_RXOUTCLK_IN,
        O                               =>      GT1_RXOUTCLK_I
        );
                    
    bufh0 : BUFH
      port map
      (
        I                               =>      GT0_RXOUTCLK_IN,
        O                               =>      GT0_RXOUTCLK_I
        );     

    process(gt0_rxusrclk_i)
    begin
      if gt0_rxusrclk_i'event and gt0_rxusrclk_i='1' then
        clksample(0)<=GT0_RXOUTCLK_I;
        clksample(1)<=GT1_RXOUTCLK_I;
        clksample(2)<=GT2_RXOUTCLK_I;
        clksample(3)<=GT3_RXOUTCLK_I;
      end if;
    end process;  
  end generate;
 
GT0_TXUSRCLK_OUT                             <= gt0_txusrclk_i;

GT1_TXUSRCLK_OUT                             <= gt0_txusrclk_i;

GT2_TXUSRCLK_OUT                             <= gt0_txusrclk_i;

GT3_TXUSRCLK_OUT                             <= gt0_txusrclk_i;

GT0_RXUSRCLK_OUT                             <= gt0_rxusrclk_i;

GT1_RXUSRCLK_OUT                             <= gt0_rxusrclk_i;

GT2_RXUSRCLK_OUT                             <= gt0_rxusrclk_i;

GT3_RXUSRCLK_OUT                             <= gt0_rxusrclk_i;



end RTL;
 
