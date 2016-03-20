----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2015 05:01:18 AM
-- Design Name: 
-- Module Name: FELIX_GBT_RX_ALIGN_FSM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FELIX_GBT_RX_AUTO_RST is
  Port (
   ext_trig_realign : out std_logic;
   FSM_CLK : in std_logic;
   GBT_LOCK : in std_logic;
   pulse_lg : in std_logic;
   GTHRXRESET_DONE : in std_logic;
   AUTO_GTH_RXRST : out std_logic;
   alignment_chk_rst : out std_logic;
   AUTO_GBT_RXRST : out std_logic
   );
end FELIX_GBT_RX_AUTO_RST;

architecture Behavioral of FELIX_GBT_RX_AUTO_RST is


signal AUTO_GBT_RXRST_p,GTHRXRESET_DONE_2r,GTHRXRESET_DONE_r, ext_trig_realign_p,ext_trig_realign_p_r, long_counter16_2r,long_counter16_r : std_logic:='0';
signal AUTO_GBT_RXRST_p_r, AUTO_GTH_RXRST_p_r, AUTO_GTH_RXRST_p, alignment_chk_rst_p, alignment_chk_rst_p_r, wpulse :std_logic:='0';
signal long_counter:std_logic_vector(26 downto 0):="000" & x"000000";

signal AUTO_GBT_RXRST_p_vec:std_logic_vector(99 downto 0):=x"0000000000000000000000000";

type fsmtype is (IDLE, GTHRST,GBTRST,ALIGNRST);
	signal statusA : fsmtype:=IDLE;

begin



process(FSM_CLK)
begin
if FSM_CLK'event and FSM_CLK='1' then
--    if GBT_LOCK = '1' or GTHRXRESET_DONE = '0' then
--       long_counter <= (others =>'0');
--    else
--        long_counter <= long_counter + '1';
--    end if;
    
 --   RST_TRIGGER <=long_counter(16);
 
   AUTO_GTH_RXRST_p_r <= AUTO_GTH_RXRST_p;
   AUTO_GTH_RXRST <= AUTO_GTH_RXRST_p;-- and (not AUTO_GTH_RXRST_p_r);
   
   ext_trig_realign_p_r <= ext_trig_realign_p;
   ext_trig_realign <= ext_trig_realign_p;-- and (not ext_trig_realign_p_r);
 
   AUTO_GBT_RXRST_p_r <= AUTO_GBT_RXRST_p;
   AUTO_GBT_RXRST <= AUTO_GBT_RXRST_p;-- and (not AUTO_GBT_RXRST_p_r);
   
   alignment_chk_rst_p_r <= alignment_chk_rst_p;
   alignment_chk_rst <= alignment_chk_rst_p;-- and (not alignment_chk_rst_p_r);
 
    long_counter16_2r <= long_counter16_r;
    long_counter16_r <= pulse_lg;
    wpulse <= long_counter16_r and (not long_counter16_2r);
    
    
    case statusA is
    when IDLE =>
        if wpulse='1' and GBT_LOCK='0' then
            AUTO_GTH_RXRST_p <='1';
            statusA <= GTHRST;
        else
            AUTO_GTH_RXRST_p <='0';
            statusA <= IDLE;
        end if;
        alignment_chk_rst_p <='0';
        AUTO_GBT_RXRST_p <='0';
        ext_trig_realign_p <='0';
    when GTHRST =>
        if wpulse='1' and GTHRXRESET_DONE='1' then
            AUTO_GBT_RXRST_p <= '1';
            statusA <= GBTRST;
        else
            AUTO_GBT_RXRST_p <='0';
            statusA <= GTHRST;
        end if;
        alignment_chk_rst_p <='0'; 
        AUTO_GTH_RXRST_p <='0';
        ext_trig_realign_p <='0';
    when GBTRST =>
        if wpulse = '1' then
            statusA <= ALIGNRST;
            ext_trig_realign_p <='1';
         else
            statusA <= GBTRST;
            ext_trig_realign_p <='0';
         end if;
         AUTO_GTH_RXRST_p <='0';
         AUTO_GBT_RXRST_p <='0';    
         alignment_chk_rst_p <='0';
    when ALIGNRST =>
        if wpulse = '1' then
            statusA <= IDLE;
            alignment_chk_rst_p <='1';
         else
            statusA <= ALIGNRST;
            alignment_chk_rst_p <='0';
         end if;
         AUTO_GTH_RXRST_p <='0';
         AUTO_GBT_RXRST_p <='0';
         ext_trig_realign_p <='0';
     when others =>
         statusA <= IDLE;
     end case;
 end if;
 
 end process;       
          
        


end Behavioral;
