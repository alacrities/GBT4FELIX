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

entity FELIX_GBT_RXSLIDE_FSM is
  Port (
    alignment_chk_rst : out std_logic;
    ext_trig_realign : in std_logic;
    FSM_RST :in std_logic;
    FSM_CLK :in std_logic;
    GBT_LOCK :in std_logic;
    RxSlide :out std_logic
   );
end FELIX_GBT_RXSLIDE_FSM;

architecture Behavioral of FELIX_GBT_RXSLIDE_FSM is

signal alignment_chk_trig,alignwait_done_p,alignwait_done,RxSlide_trig,RxSlide_trig_2,RxSlide_done,waitcnt:std_logic:='0';
signal alignwaitcnt:std_logic_vector(6 downto 0):="0000000";
signal phase:std_logic_vector(10 downto 0):="00000000000";
signal step:std_logic_vector(1 downto 0):="00";
signal phase_data:std_logic_vector(9 downto 0):="0000000000";
signal rstcnt:std_logic_vector(9 downto 0):="0000000000";
signal cnt:integer:=0;
type fsmtype is (IDLE,ALIGN_DONE);
	signal RA_STATE : fsmtype;
signal slide_vec:std_logic_vector(19 downto 0):=x"00000";
begin

alignment_chk_rst <=alignment_chk_trig;

process(FSM_CLK)
begin
if FSM_CLK'event and FSM_CLK='1' then
    if alignment_chk_trig='1' then
        alignwaitcnt <="0000000";
    elsif alignwaitcnt(6)='1' then
        alignwaitcnt <= alignwaitcnt;
    else
        alignwaitcnt <= alignwaitcnt+'1';
    end if;
    alignwait_done_p <= alignwaitcnt(6);
    alignwait_done <= alignwaitcnt(6) and (not alignwait_done_p);
end if;
end process;

process(FSM_CLK)
begin
if FSM_CLK'event and FSM_CLK='1' then
    if  RxSlide_trig='1' then
        slide_vec <=x"00001";
    else
        slide_vec <=slide_vec(18 downto 0) & '0';
    end if;
 
    RxSlide <=RxSlide_trig;-- or RxSlide_trig_2 ;
    RxSlide_trig_2 <= slide_vec(9);
    RxSlide_done <= slide_vec(19);
end if;
end process;

process(FSM_CLK, FSM_RST)-- ext_trig_realign)
begin
if FSM_RST='1' then--or ext_trig_realign='1' then
   RA_STATE <= IDLE;
   step<="00";
elsif FSM_CLK'event and FSM_CLK='1' then
   case RA_STATE is
   when IDLE =>
        
            case step is
            when "00" =>
                alignment_chk_trig <='1';
                step <="01";
                RA_STATE <= IDLE;
            when "01" =>
                alignment_chk_trig <='0';
                if alignwait_done = '1' then
                    --GBT_IS_LOCKED <= GBT_LOCK;
                    if GBT_LOCK = '1' then
                        RA_STATE <= ALIGN_DONE;  
                        cnt<=0;  
                        step <="00";          
                    else
                        step <="11";
                        RxSlide_trig <='1'; 
                        RA_STATE <= IDLE;
                    end if;  
                else
                    step <= "01";
                    RA_STATE <= IDLE;
                end if;   
            when "11" =>  
                RxSlide_trig <='0';
                RA_STATE <= IDLE;
                if RxSlide_done='1' then
                     step <="00";
                end if;
            when others =>
                RA_STATE <= IDLE;
                step<="00";
            end case;         
           
     
 
   
   when ALIGN_DONE => 
          alignment_chk_trig <='0';
          step<="00";
        --  if ext_trig_realign='1' or GBT_LOCK='0' then
          if GBT_LOCK = '0' then
              RA_STATE <= IDLE;
          else
              RA_STATE <= ALIGN_DONE;
          end if;
          
     

  
  when others =>
       
        RA_STATE <= IDLE;
        step<="00";
  end case;
  
  end if;
  end process;

end Behavioral;
