-------------------------------------------------------------------------------
-- Based on GBT-FPGA project v3
-- Modified by K. Chen  @ Dec. 2014, Clock changed, in/out control signal added.
-- Crossing time domain logic is included, time margin is added, it can be
-- dynamic adjusted, or adjusted through the package file.

-- Low-level 16/21 bit scrambler is almost same with GBT-FPGA project, one
-- enable signal is added.
-------------------------------------------------------------------------------



library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;
 
use work.FELIX_gbt_package.all;

entity gbt_tx_timedomaincrossing_FELIX is
  generic

(
channel             : integer   := 0
);
  port
    (
      
     -- Scrambler_Enable	: in  std_logic;
      Tx_Align_Signal   : out std_logic;
      TX_TC_METHOD : in std_logic;
      TX_LATOPT_TC     : in  std_logic;
      
	  TX_TC_DLY_VALUE  : in std_logic_vector(2 downto 0);  
      
      TX_WORDCLK_I      : in  std_logic;
      TX_RESET_I        : in  std_logic;
      TX_FRAMECLK_I     : in  std_logic
      
      --TX_ISDATA_SEL_I   : in  std_logic;
    
      
   );
end gbt_tx_timedomaincrossing_FELIX;


architecture Behavior of gbt_tx_timedomaincrossing_FELIX is   

  --signal tx_frameclk_i_shifted, tx_frameclk_i_shifted_p : std_logic;
  signal fsm_rst                                : std_logic := '0';
  signal frame_clk_stop, frame_clk_stop_p,frame_clk_stop_e_ma,frame_clk_stop_f_ma       : std_logic := '1';
  signal cnt, TX_TC_DLY_VALUE_i                                    : std_logic_vector(2 downto 0) :="000";
  signal frame_clk_stop_a, frame_clk_stop_b,frame_clk_stop_c,frame_clk_stop_d,frame_clk_stop_e,frame_clk_stop_a2,frame_clk_stop_f     : std_logic := '1';
  
   signal frame_clk_stop_ma, frame_clk_stop_p_ma,frame_clk_stop_r_ma,frame_clk_stop_a4,frame_clk_stop_a3       : std_logic := '1';
   signal frame_clk_stop_a_ma, frame_clk_stop_b_ma,frame_clk_stop_c_ma,frame_clk_stop_d_ma,frame_clk_stop_a1,frame_clk_stop_a5     : std_logic := '1';

begin                
--=================================================================================================--

   --==================================== User Logic =====================================--

   --==============--
   -- Frame header --
   --==============--
   
--  headerSel: process(TX_RESET_I, TX_FRAMECLK_I)
--  begin
--    if TX_RESET_I = '1' then
--      TX_HEADER_O                            	<= (others => '0');
--    elsif rising_edge(TX_FRAMECLK_I) then      
--      if TX_ISDATA_SEL_I = '1' then
--        TX_HEADER_O                         <= DATA_HEADER_PATTERN;
--      else           
--        TX_HEADER_O                         <= IDLE_HEADER_PATTERN;      
--      end if; 
--    end if;
--  end process;
 
 ------------------------------------------------------------------------------
 ---- Addde by K. Chen
 ---- Dec. 2014
 ---- For time domain crossing, >1 or >0.5 WordClk Margin is added.
 ------------------------------------------------------------------------------
 
 
    frame_clk_stop_p_ma <= TX_FRAMECLK_I;
 
 
    dynamic_ma: if DYNAMIC_LATENCY_OPT = '1' generate
        delay_half_cycle : FD
        generic map (
         INIT => '0'
         )
        port map (
         C    => not TX_WORDCLK_I,
         D    => frame_clk_stop_p_ma,
         Q    => frame_clk_stop_c_ma
         );
     
          process(TX_WORDCLK_I)
              begin
              if TX_WORDCLK_I'event and TX_WORDCLK_I='0' then
                frame_clk_stop_a_ma <=frame_clk_stop_c_ma;  
                frame_clk_stop_e_ma <=frame_clk_stop_a_ma;
                
               
                end if;
                end process;    
         
--     delay_onehalf_cycle : FD
--         generic map (
--           INIT => '0'
--           )
--         port map (
--           C    =>  TX_WORDCLK_I,
--           D    => frame_clk_stop_c_ma,
--           Q    => frame_clk_stop_a_ma
--           );  
--     delay_twohalf_cycle : FD
--        generic map (
--          INIT => '0'
--          )
--        port map (
--          C    =>  TX_WORDCLK_I,
--          D    => frame_clk_stop_a_ma,
--          Q    => frame_clk_stop_e_ma
--          );     
--     process(TX_WORDCLK_I)
--     begin
--     if TX_WORDCLK_I'event and TX_WORDCLK_I='1' then
--       frame_clk_stop_a1 <=frame_clk_stop_a_ma;  
--       frame_clk_stop_a2 <=frame_clk_stop_a1;
--       frame_clk_stop_a3 <=frame_clk_stop_a2;
--       frame_clk_stop_a4 <=frame_clk_stop_a3;
--       frame_clk_stop_a5 <=frame_clk_stop_a4;
--       end if;
--       end process;          
                   
     delay_one_cycle : FD
       generic map (
         INIT => '0'
         )
       port map (
         C    => TX_WORDCLK_I,
         D    => frame_clk_stop_p_ma,
         Q    => frame_clk_stop_d_ma
         );
      
      
         process(TX_WORDCLK_I)
    begin
    if TX_WORDCLK_I'event and TX_WORDCLK_I='1' then
      frame_clk_stop_b_ma <=frame_clk_stop_d_ma;  
      frame_clk_stop_f_ma <=frame_clk_stop_b_ma;
      
      end if;
      end process; 
         
--     delay_one_cycle2 : FD
--     generic map (
--       INIT => '0'
--       )
--     port map (
--       C    => TX_WORDCLK_I,
--       D    => frame_clk_stop_d_ma,
--       Q    => frame_clk_stop_b_ma
--       );
--    delay_one_cycle3 : FD
--       generic map (
--         INIT => '0'
--         )
--       port map (
--         C    => TX_WORDCLK_I,
--         D    => frame_clk_stop_b_ma,
--         Q    => frame_clk_stop_f_ma
--         );

  phase180_gen :if TXUSRCLK_PHASE_180(channel)='1' generate

    
      
   frame_clk_stop_ma <=  frame_clk_stop_b_ma when TX_LATOPT_TC='0'
                         else frame_clk_stop_d_ma;

  end generate;
      phase0_gen :if TXUSRCLK_PHASE_180(channel)='0' generate
     frame_clk_stop_ma <= frame_clk_stop_a_ma when TX_LATOPT_TC = '1'
                       else frame_clk_stop_e_ma;
      end generate;
   end generate dynamic_ma;

 -----------------------------------------------------------------------------
 -- NO_DYNAMIC ADJUSTMENT
 -----------------------------------------------------------------------------
 
 no_dynamic_ma: if DYNAMIC_LATENCY_OPT = '0' generate
   ---- For time domain crossing, > 0.5 WordClk Margin is added.
   bbbb: if TX_LATOPT_TIMECROSSING = '0' generate
     delay_half_cycle : FD
       generic map (
         INIT => '0'
         )
       port map (
         C    => not TX_WORDCLK_I,
         D    => frame_clk_stop_p_ma,
         Q    => frame_clk_stop_c_ma 
        );
        
        delay_onehalf_cycle : FD
                generic map (
                  INIT => '0'
                  )
                port map (
                  C    => not TX_WORDCLK_I,
                  D    => frame_clk_stop_c_ma,
                  Q    => frame_clk_stop_ma 
                 );
   end generate bbbb;
   

   cccc: if TX_LATOPT_TIMECROSSING = '1' generate
     delay_one_cycle : FD
       generic map (
         INIT => '0'
         )
       port map (
         C    => TX_WORDCLK_I,
         D    => frame_clk_stop_p_ma,
         Q    => frame_clk_stop_ma
         );
   end generate cccc;
   
 end generate no_dynamic_ma;
 
 
 
 
 
 
 
 
 
 
 
 -------------------------
 
 
  process(TX_RESET_I,fsm_rst, TX_FRAMECLK_I)
  begin
    if TX_RESET_I='1' or fsm_rst='1' then
      frame_clk_stop_p <= '1';
    elsif TX_FRAMECLK_I'event and TX_FRAMECLK_I='1' then
      frame_clk_stop_p <= '0';
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Dynamic adjustment
  -----------------------------------------------------------------------------
--  dynamic: if DYNAMIC_LATENCY_OPT = '1' generate
----    delay_half_cycle : FD
----      generic map (
----        INIT => '0'
----        )
----      port map (
----        C    => not TX_WORDCLK_I,
----        D    => frame_clk_stop_p,
----        Q    => frame_clk_stop_a
----        );
--    delay_one_cycle : FD
--      generic map (
--        INIT => '0'
--        )
--      port map (
--        C    => TX_WORDCLK_I,
--        D    => frame_clk_stop_p,
--        Q    => frame_clk_stop_b
--        );

--    frame_clk_stop <=  frame_clk_stop_b;
    
--  end generate dynamic;
  
  dynamic: if DYNAMIC_LATENCY_OPT = '1' generate
      delay_half_cycle : FD
        generic map (
          INIT => '0'
          )
        port map (
          C    => not TX_WORDCLK_I,
          D    => frame_clk_stop_p,
          Q    => frame_clk_stop_c--frame_clk_stop_a
          );
          
      delay_onehalf_cycle : FD
                  generic map (
                    INIT => '0'
                    )
                  port map (
                    C    => not TX_WORDCLK_I,
                    D    => frame_clk_stop_c,
                    Q    => frame_clk_stop_a
                    );   
                    
       delay_2half_cycle : FD
                                     generic map (
                                       INIT => '0'
                                       )
                                     port map (
                                       C    => not TX_WORDCLK_I,
                                       D    => frame_clk_stop_a,
                                       Q    => frame_clk_stop_e
                                       );                 
      delay_one_cycle : FD
        generic map (
          INIT => '0'
          )
        port map (
          C    => TX_WORDCLK_I,
          D    => frame_clk_stop_p,
          Q    => frame_clk_stop_d
          );
                delay_2_cycle : FD
            generic map (
              INIT => '0'
              )
            port map (
              C    => TX_WORDCLK_I,
              D    => frame_clk_stop_d,
              Q    => frame_clk_stop_b
              );
   delay_3_cycle : FD
            generic map (
              INIT => '0'
              )
            port map (
              C    => TX_WORDCLK_I,
              D    => frame_clk_stop_b,
              Q    => frame_clk_stop_f
              );
  --frame_clk_stop <=  frame_clk_stop_b;
  phase180_gen :if TXUSRCLK_PHASE_180(channel)='1' generate
      frame_clk_stop <= frame_clk_stop_b when TX_LATOPT_TC = '1'
                        else frame_clk_stop_e;
  end generate;
    phase0_gen :if TXUSRCLK_PHASE_180(channel)='0' generate
      frame_clk_stop <= frame_clk_stop_e when TX_LATOPT_TC = '1'
                              else frame_clk_stop_f;
    end generate;
    end generate dynamic;

  -----------------------------------------------------------------------------
  -- NO_DYNAMIC ADJUSTMENT
  -----------------------------------------------------------------------------
  
  no_dynamic: if DYNAMIC_LATENCY_OPT = '0' generate
    ---- For time domain crossing, > 0.5 WordClk Margin is added.
    bbbb: if TX_LATOPT_TIMECROSSING = '0' generate
      delay_half_cycle : FD
        generic map (
          INIT => '0'
          )
        port map (
          C    => not TX_WORDCLK_I,
          D    => frame_clk_stop_p,
          Q    => frame_clk_stop_c 
         );
         
         delay_onehalf_cycle : FD
                 generic map (
                   INIT => '0'
                   )
                 port map (
                   C    => not TX_WORDCLK_I,
                   D    => frame_clk_stop_c,
                   Q    => frame_clk_stop_a 
                  );
                  
       delay_twohalf_cycle : FD
                                   generic map (
                                     INIT => '0'
                                     )
                                   port map (
                                     C    => not TX_WORDCLK_I,
                                     D    => frame_clk_stop_a,
                                     Q    => frame_clk_stop 
                                    );           
    end generate bbbb;
    

    cccc: if TX_LATOPT_TIMECROSSING = '1' generate
      delay_one_cycle : FD
        generic map (
          INIT => '0'
          )
        port map (
          C    => TX_WORDCLK_I,
          D    => frame_clk_stop_p,
          Q    => frame_clk_stop_d
          );
         delay_two_cycle : FD
                  generic map (
                    INIT => '0'
                    )
                  port map (
                    C    => TX_WORDCLK_I,
                    D    => frame_clk_stop_d,
                    Q    => frame_clk_stop
                    ); 
    end generate cccc;
    
  end generate no_dynamic;

  -----------------------------------------------------------------------------
  -- Alignment signal for TX GearBox
    -----------------------------------------------------------------------------
    process(TX_WORDCLK_I)
    begin
      if TX_WORDCLK_I'event and TX_WORDCLK_I='1' then
        if TX_DLY_SW_CTRL='1' then
          TX_TC_DLY_VALUE_i <= TX_TC_DLY_VALUE;
        else
          TX_TC_DLY_VALUE_i <= TX_TC_DLY_VALUE_package;
        end if;       
      end if;
    end process;
    
    process(frame_clk_stop,frame_clk_stop_ma,TX_TC_METHOD, TX_WORDCLK_I)
    begin
      if frame_clk_stop='1' then
        Tx_Align_Signal <='0';
        --tx_frameclk_i_shifted <='0';  -- Use it if shifted 40M is used clock
        --cnt <="000";
		cnt <= TX_TC_DLY_VALUE_i;
        fsm_rst <='0';
      elsif TX_WORDCLK_I'event and TX_WORDCLK_I='1' then
        
       frame_clk_stop_r_ma <= frame_clk_stop_ma;
       if TX_TC_METHOD='1' and (frame_clk_stop_ma='1' and frame_clk_stop_r_ma='0') then
           -- cnt <="000";
           cnt <= TX_TC_DLY_VALUE_i;
       else 
      
        case cnt is
          when "000" =>
            cnt <="001";
            fsm_rst <='0';
            Tx_Align_Signal <='0';
          -- tx_frameclk_i_shifted <='1';
          when "001" =>
            cnt <="010";
            fsm_rst <='0';
            Tx_Align_Signal <='0';
          -- tx_frameclk_i_shifted <='1';
          when "010" =>
            cnt <="011";
            fsm_rst <='0';
            Tx_Align_Signal <='0';
          -- tx_frameclk_i_shifted <='0';
          when "011" =>
            cnt <="100";
            fsm_rst <='0';
            Tx_Align_Signal <='0';
          -- tx_frameclk_i_shifted <='0';
          when "100" =>
            cnt <="101";
            fsm_rst <='0';
            Tx_Align_Signal <='1';
          -- tx_frameclk_i_shifted <='0';
          when "101" =>
            cnt <="000";
            fsm_rst <='0';
            Tx_Align_Signal <='0';
          -- tx_frameclk_i_shifted <='1';
          when others =>
            cnt <="101";
            fsm_rst <='1';
            Tx_Align_Signal <='0';
        end case;
       end if; 
      end if;
    end process;
    
  

  --============--
  -- Scramblers --
  --============--
   
  -- 84 bit scrambler (GBT-Frame & Wide-Bus):
  -------------------------------------------
   

   --=====================================================================================--
end Behavior;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
