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

entity FELIX_GBT_RX_ALIGN_FSM is
  Port (
    TB_SEL : in std_logic;
    ext_trig_realign : in std_logic;
    TB_SW : in std_logic;
    alignment_chk_rst : out std_logic;
    FSM_RST :in std_logic;
    FSM_CLK :in std_logic;
    OddEven :out std_logic;
    TopBot :out std_logic;
    GBT_LOCK :in std_logic;
    RxSlide :out std_logic;
    clk_sampled : in std_logic;
    RX_ALIGN_SW :in std_logic
   );
end FELIX_GBT_RX_ALIGN_FSM;

architecture Behavioral of FELIX_GBT_RX_ALIGN_FSM is

signal alignment_chk_trig,alignwait_done_p,alignwait_done,RxSlide_trig,RxSlide_trig_2,RxSlide_done,waitcnt:std_logic:='0';
signal alignwaitcnt:std_logic_vector(6 downto 0):="0000000";
signal phase:std_logic_vector(10 downto 0):="00000000000";
signal step:std_logic_vector(1 downto 0):="00";
signal phase_data:std_logic_vector(9 downto 0):="0000000000";
signal rstcnt:std_logic_vector(9 downto 0):="0000000000";
signal cnt:integer:=0;
type fsmtype is (IDLE, GRP00,GRP11,GRP10,GRP01,PHASE_SAMPLE,SF5,Judge,ALIGN_CHK_RST,ALIGN_DONE);
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
 
    RxSlide <=RxSlide_trig or RxSlide_trig_2 ;
    RxSlide_trig_2 <= slide_vec(9);
    RxSlide_done <= slide_vec(19);
end if;
end process;

process(FSM_CLK, FSM_RST, ext_trig_realign)
begin
if FSM_RST='1' or ext_trig_realign = '1' then
   RA_STATE <= IDLE;
elsif FSM_CLK'event and FSM_CLK='1' then
   case RA_STATE is
   when IDLE =>
        OddEven <='0';
        TopBot <= '0';
        phase <="00000000001";
        RA_STATE <= GRP00;
        step<="00";
   
    when GRP00 =>
        if phase(10) = '1' then
            step <="00";
            OddEven <='1';
            TopBot <= '0';
            RA_STATE <= GRP01;
            phase <="00000000001";
        else
            case step is
            when "00" =>
                alignment_chk_trig <='1';
                step <="01";
                RA_STATE <= GRP00;
            when "01" =>
                alignment_chk_trig <='0';
                if alignwait_done = '1' then
                    --GBT_IS_LOCKED <= GBT_LOCK;
                    if GBT_LOCK = '1' then
                        RA_STATE <= PHASE_SAMPLE;  
                        cnt<=0;  
                        step <="00";          
                    else
                        step <="11";
                        RxSlide_trig <='1'; 
                        RA_STATE <= GRP00;
                    end if;  
                else
                    step <= "01";
                    RA_STATE <= GRP00;
                end if;   
            when "11" =>  
                RxSlide_trig <='0';
                RA_STATE <= GRP00;
                if RxSlide_done='1' then
                     phase <= phase(9 downto 0) & '0';
                     step <="00";
                end if;
            when others =>
                RA_STATE <= IDLE;
            end case;         
           
        end if;
    when GRP01 =>
        if phase(10) = '1' then
            step <="00";
            OddEven <='1';
            TopBot <= '1';
            RA_STATE <= GRP11;
            phase <="00000000001";
        else
            case step is
            when "00" =>
                alignment_chk_trig <='1';
                step <="01";
                RA_STATE <= GRP01;
            when "01" =>
                alignment_chk_trig <='0';
                if alignwait_done = '1' then
           --    GBT_IS_LOCKED <= GBT_LOCK;
                    if GBT_LOCK = '1' then
                        RA_STATE <= PHASE_SAMPLE;  
                        cnt<=0;  
                        step <="00";          
                    else
                        step <="11";
                        RxSlide_trig <='1'; 
                        RA_STATE <= GRP01;
                    end if;  
                else
                    step <= "01";
                    RA_STATE <= GRP01;
                end if;
            when "11" =>  
                RxSlide_trig <='0';
                RA_STATE <= GRP01;
                if RxSlide_done='1' then
                    phase <= phase(9 downto 0) & '0';
                    step <="00";
                end if;
              
            when others =>
                RA_STATE <= IDLE;
            end case;         
             
       end if;
    when GRP11 =>
        if phase(10) = '1' then
            step <="00";
            OddEven <='0';
            TopBot <= '1';
            RA_STATE <= GRP10;
            phase <="00000000001";
         else
            case step is
            when "00" =>
               alignment_chk_trig <='1';
               step <="01";
               RA_STATE <= GRP11;
            when "01" =>
               
               if alignwait_done = '1' then
               --  GBT_IS_LOCKED <= GBT_LOCK;
                    if GBT_LOCK = '1' then
                        RA_STATE <= ALIGN_DONE;
                        alignment_chk_trig <= '0';             
                    else
                        step <="11";
                        alignment_chk_trig <='0';
                        RxSlide_trig <='1'; 
                        RA_STATE <= GRP11;
                    end if;  
               else
                    step <= "01";
                    alignment_chk_trig <='0';
                    RA_STATE <= GRP11;
               end if;
            when "11" =>  
                RxSlide_trig <='0';
                RA_STATE <= GRP11;
                if RxSlide_done='1' then
                    phase <= phase(9 downto 0) & '0';
                    step <="00";
                end if;
                
            when others =>
                RA_STATE <= IDLE;
            end case;         
               
     end if;
    when GRP10 =>
    if phase(10) = '1' then
        step <="00";
        OddEven <='0';
        TopBot <= '0';
        RA_STATE <= IDLE;
        phase <="00000000001";
     else
        case step is
        when "00" =>
           alignment_chk_trig <='1';
           step <="01";
           RA_STATE <= GRP10;
        when "01" =>
           
           if alignwait_done = '1' then
              --   GBT_IS_LOCKED <= GBT_LOCK;
                if GBT_LOCK = '1' then
                    RA_STATE <= ALIGN_DONE;  
                    alignment_chk_trig <='0';            
                else
                    step <="11";
                    alignment_chk_trig <='0';
                    RxSlide_trig <='1'; 
                    RA_STATE <= GRP10;
                end if;  
           else
                step <= "01";
                alignment_chk_trig <='0';
                RA_STATE <= GRP10;
           end if;
        when "11" =>  
            RxSlide_trig <='0';
            RA_STATE <= GRP10;
            if RxSlide_done='1' then
                phase <= phase(9 downto 0) & '0';
                step <="00";
            end if;
        when others =>
            RA_STATE <= IDLE;
        end case;         
               
     end if;
    when PHASE_SAMPLE =>
        if cnt=10 then
            RA_STATE <=Judge;
        else
     
        case step is
            when "00" =>
                RA_STATE <= PHASE_SAMPLE;
                phase_data(cnt)<=clk_sampled;
                step <="01";
            when "01" =>
                RA_STATE <= PHASE_SAMPLE;
                RxSlide_trig <='1';
                step <="11";
                   -- slide_cnt <="00000";
            when "11"=>
                RxSlide_trig<='0';
                RA_STATE <= PHASE_SAMPLE;
                if RxSlide_done='1' then
                    step<="00";
                    cnt<=cnt+1;
                    
                 end if;
                     
                     
                     
             when others =>
                 RA_STATE <= PHASE_SAMPLE;
                 cnt <=0;
         end case; 
        
        end if;  
        
    when Judge =>
        if TB_SEL='1' then
            TopBot <= TB_SW;
            if TB_SW='1' then
                RA_STATE <= SF5;              
                phase<="00000000001"; 
                step<="00";
            else
                RA_STATE <= ALIGN_CHK_RST;  
                waitcnt<='0';
                alignment_chk_trig <='1';
            end if;
        elsif phase_data(1)='1' then
            if phase_data(0)='0' then
                TopBot <= '1';
                RA_STATE <= SF5;              
                phase<="00000000001"; 
                step<="00";           
            else
                TopBot <= '0';
                RA_STATE <= ALIGN_CHK_RST;  
                waitcnt<='0';
                alignment_chk_trig <='1';            
                     
            end if;
        elsif phase_data(5)='0' then
            TopBot <= '0';
            RA_STATE <= ALIGN_CHK_RST;  
            waitcnt<='0';
            alignment_chk_trig <='1';            
                    
        else
            TopBot <= '1';
            RA_STATE <= SF5; 
            phase<="00000000001";
            step<="00";
        end if; 
    
    when SF5 =>
        if phase(5)='1' then
            RA_STATE <= ALIGN_CHK_RST; 
            waitcnt<='0';
            alignment_chk_trig <='1';
        else
            case step(0) is
            when '0' =>
                RA_STATE <= SF5;
                RxSlide_trig <='1';
                step <="01";
            when others=>
                RxSlide_trig<='0';
                RA_STATE <= SF5;
                if RxSlide_done='1' then
                    step<="00";
                    phase <=phase(9 downto 0) & '0';
                end if;
            end case;  
        end if;       

    when ALIGN_CHK_RST =>
        
        if waitcnt='0' then
            waitcnt<='1';
            alignment_chk_trig <='0';
        else
  
  
            RA_STATE <= ALIGN_DONE;
            alignment_chk_trig <= '0';
        end if;
 
   when ALIGN_DONE => 
          alignment_chk_trig <='0';
        --  if ext_trig_realign='1' or GBT_LOCK='0' then
          if GBT_LOCK = '0' then
              RA_STATE <= IDLE;
          else
              RA_STATE <= ALIGN_DONE;
          end if;
          
     
--  when ALIGN_DONE => 
--        alignment_chk_trig <='1';
--        if rstcnt(9) = '1' then
--            RA_STATE <= ALIGN_DONE_new;
--            rstcnt <= "0000000000";
--        else
--            RA_STATE <= ALIGN_DONE;
--            rstcnt <= rstcnt + '1';
--        end if;
        
--  when ALIGN_DONE_new => 
--        alignment_chk_trig <='0';
--        if GBT_LOCK = '0' then
--            RA_STATE <= IDLE;
--        else
--            RA_STATE <= ALIGN_DONE_new;
--        end if;
        
    
  
  when others =>
        OddEven <='0';
        TopBot <= '0';
    
        RA_STATE <= IDLE;
  end case;
  
  end if;
  end process;

end Behavioral;
