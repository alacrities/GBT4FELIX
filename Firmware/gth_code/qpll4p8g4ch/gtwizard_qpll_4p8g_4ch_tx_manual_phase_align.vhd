--//////////////////////////////////////////////////////////////////////////////
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 3.4
--  \   \         Application : 7 Series FPGAs Transceivers Wizard 
--  /   /         Filename : gtwizard_qpll_4p8g_4ch_tx_manual_phase_align.vhd
-- /___/   /\     
-- \   \  /  \ 
--  \___\/\___\ 
--
--
--  Description :     This module performs TX Buffer Phase Alignment in Manual Mode.
--                     
--
--
-- Module gtwizard_qpll_4p8g_4ch_tx_manual_phase_align
-- Generated by Xilinx 7 Series FPGAs Transceivers Wizard
-- 
-- 
-- (c) Copyright 2010-2012 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES. 


--*****************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gtwizard_qpll_4p8g_4ch_TX_MANUAL_PHASE_ALIGN is
  Generic( NUMBER_OF_LANES          : integer range 1 to 32:= 4;  -- Number of lanes that are controlled using this FSM.
           MASTER_LANE_ID           : integer range 0 to 31:= 0   -- Number of the lane which is considered the master in manual phase-alignment
         );     

    Port ( STABLE_CLOCK             : in  STD_LOGIC;              --Stable Clock, either a stable clock from the PCB
                                                                  --or reference-clock present at startup.
           RESET_PHALIGNMENT        : in  STD_LOGIC;
           RUN_PHALIGNMENT          : in  STD_LOGIC;
           PHASE_ALIGNMENT_DONE     : out STD_LOGIC := '0';       -- Manual phase-alignment performed sucessfully  
           TXDLYSRESET              : out STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0) := (others=> '0');
           TXDLYSRESETDONE          : in  STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0);
           TXPHINIT                 : out STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0) := (others=> '0');
           TXPHINITDONE             : in  STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0);
           TXPHALIGN                : out STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0) := (others=> '0');
           TXPHALIGNDONE            : in  STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0);
           TXDLYEN                  : out STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0) := (others=> '0')
           );
end gtwizard_qpll_4p8g_4ch_TX_MANUAL_PHASE_ALIGN;

architecture RTL of gtwizard_qpll_4p8g_4ch_TX_MANUAL_PHASE_ALIGN is

  component gtwizard_qpll_4p8g_4ch_sync_block
   generic (
     INITIALISE : bit_vector(5 downto 0) := "000000"
   );
   port  (
             clk           : in  std_logic;
             data_in       : in  std_logic;
             data_out      : out std_logic
          );
   end component;

  component  gtwizard_qpll_4p8g_4ch_sync_pulse      
  generic( 
           C_NUM_SRETCH_REGS                  : integer  := 3;
           C_NUM_SYNC_REGS                    : integer  := 3
         );     

    port ( 
           CLK          : in  STD_LOGIC;             
           USER_DONE    : out STD_LOGIC := '0';     
           GT_DONE      : in  STD_LOGIC              
           
           );
  end component;

  constant VCC_VEC  : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '1');
  constant GND_VEC  : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');

  signal txphaligndone_prev       : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');
  signal txphaligndone_ris_edge   : std_logic_vector(NUMBER_OF_LANES-1 downto 0);
  signal txphinitdone_prev        : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');
  signal txphinitdone_ris_edge    : std_logic_vector(NUMBER_OF_LANES-1 downto 0);
  signal txphinitdone_store_edge  : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');
  signal txphinitdone_clear_slave : std_logic:='0';
  signal txdlysresetdone_store    : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');
  signal txphaligndone_store      : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');
  signal txdone_clear             : std_logic:='0';
  
  signal txphaligndone_sync      : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');
  signal txphinitdone_sync       : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');
  signal txdlysresetdone_sync    : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');

  type tx_phase_align_manual_fsm is(
    INIT, WAIT_PHRST_DONE, M_PHINIT, M_PHALIGN, M_DLYEN,
    S_PHINIT, S_PHALIGN, M_DLYEN2, PHALIGN_DONE
    );
  signal tx_phalign_manual_state : tx_phase_align_manual_fsm := INIT;

begin

 cdc: for i in 0 to NUMBER_OF_LANES-1 generate
 sync_TXPHALIGNDONE : gtwizard_qpll_4p8g_4ch_sync_block
  port map
         (
            clk             =>  STABLE_CLOCK,
            data_in         =>  TXPHALIGNDONE(i),
            data_out        =>  txphaligndone_sync(i) 
         );

  sync_TXDLYSRESETDONE : gtwizard_qpll_4p8g_4ch_sync_block
  port map
         (
            clk             =>  STABLE_CLOCK,
            data_in         =>  TXDLYSRESETDONE(i),
            data_out        =>  txdlysresetdone_sync(i) 
         );

 sync_TXPHINITDONE : gtwizard_qpll_4p8g_4ch_sync_pulse
  port map
         (
            CLK             =>  STABLE_CLOCK,
            GT_DONE         =>  TXPHINITDONE(i),
            USER_DONE       =>  txphinitdone_sync(i) 
         );
  end generate;

  process(STABLE_CLOCK)
  begin
    if rising_edge(STABLE_CLOCK) then
      txphaligndone_prev  <= txphaligndone_sync;    
      txphinitdone_prev   <= txphinitdone_sync;
    end if;
  end process;
  
  
  rising_edge_detect: for i in 0 to NUMBER_OF_LANES-1 generate
    txphaligndone_ris_edge(i) <= '1' when (txphaligndone_prev(i) = '0') and (txphaligndone_sync(i) = '1') else '0';
    txphinitdone_ris_edge(i)  <= '1' when (txphinitdone_prev(i) = '0') and (txphinitdone_sync(i) = '1') else '0';
  end generate;

  process(STABLE_CLOCK)
  begin
    if rising_edge(STABLE_CLOCK) then
      if txdone_clear = '1' then
        txdlysresetdone_store <= (others=>'0');
        txphaligndone_store   <= (others=>'0');
      else
        for i in 0 to NUMBER_OF_LANES-1 loop
          if txdlysresetdone_sync(i) = '1' then
            txdlysresetdone_store(i) <= '1';
          end if;
          if txphaligndone_ris_edge(i) = '1' then
             txphaligndone_store(i)  <= '1';
          end if;
        end loop;
      end if;
    end if;
  end process;



  process(STABLE_CLOCK)
  begin
    if rising_edge(STABLE_CLOCK) then
      if txphinitdone_clear_slave = '1' then
        --Only clear the TXPHINITDONE-storage from the slaves.
        txphinitdone_store_edge                 <= (others=>'0');
        --The information stored on the MASTER_LANE_ID is used differently. The way txphinitdone_store_edge
        --is coded, it will be optimised away afterwards. It is only for simplicity of the code on the checks
        --that the master-lane is "recorded" too.
        txphinitdone_store_edge(MASTER_LANE_ID) <= '1';
      else
        for i in 0 to NUMBER_OF_LANES-1 loop
          if txphinitdone_ris_edge(i) = '1' then
            txphinitdone_store_edge(i) <= '1';
          end if;
        end loop;
      end if;
    end if;
  end process;


  
  
  process(STABLE_CLOCK)
  begin
    if rising_edge(STABLE_CLOCK) then
      if RESET_PHALIGNMENT = '1' then
        PHASE_ALIGNMENT_DONE      <= '0';
        TXDLYSRESET               <= (others=> '0');
        TXPHINIT                  <= (others=> '0');
        TXPHALIGN                 <= (others=> '0');
        TXDLYEN                   <= (others=> '0');
        tx_phalign_manual_state   <= INIT;
        txphinitdone_clear_slave  <= '1';
        txdone_clear              <= '1';
      else
        case tx_phalign_manual_state is
          when INIT => 
            PHASE_ALIGNMENT_DONE      <= '0';
            txphinitdone_clear_slave  <= '1';
            txdone_clear              <= '1';
            if RUN_PHALIGNMENT = '1' then
              --TXDLYSRESET is toggled to '1'
              TXDLYSRESET               <= (others=> '1');
              txphinitdone_clear_slave  <= '0';
              txdone_clear              <= '0';
              tx_phalign_manual_state   <= WAIT_PHRST_DONE;
            end if;       
            
          when WAIT_PHRST_DONE => 
            --Assert TXDLYSRESET for all lanes, hold high until 
            --TXDLYSRESETDONE of the respective lane is asserted.
            for i in 0 to NUMBER_OF_LANES - 1 loop
              if txdlysresetdone_store(i) = '1' then
                --Deassert TXDLYSRESET for the lane in which 
                --the TXDLYSRESETDONE is asserted:
                TXDLYSRESET(i) <= '0';
              end if;
            end loop;
            if txdlysresetdone_store = VCC_VEC then
              --When all TXDLYSRESETDONE-signals are asserted, move 
              --to the next state.
              tx_phalign_manual_state   <= M_PHINIT;
            end if;
            
          when M_PHINIT => 
            --Assert TXPHINIT on the master and hold high until a
            --rising edge on TXPHINITDONE is detected:
            TXPHINIT(MASTER_LANE_ID) <= '1';
            if txphinitdone_ris_edge(MASTER_LANE_ID) = '1' then
              --Then deassert TXPHINIT and move to the next state.
              TXPHINIT(MASTER_LANE_ID)  <= '0';
              tx_phalign_manual_state   <= M_PHALIGN;
            end if;
            
          when M_PHALIGN => 
            --Assert TXPHALIGN on the master and hold high until a 
            --rising edge on TXPHALIGNDONE is detected:
            TXPHALIGN(MASTER_LANE_ID) <= '1';
            if txphaligndone_ris_edge(MASTER_LANE_ID) = '1' then
              --Then dassert TXPHALIGN and move to the next state.
              TXPHALIGN(MASTER_LANE_ID) <= '0';
              tx_phalign_manual_state   <= M_DLYEN;
            end if;
            
          when M_DLYEN => 
            --Assert TXDLYEN on the master and hold high until a
            --rising edge on TXPHALIGNDONE is detected.
            TXDLYEN(MASTER_LANE_ID) <= '1';
            if txphaligndone_ris_edge(MASTER_LANE_ID) = '1' then
              --Then deassert TXDLYEN and move to the next state.
              if(NUMBER_OF_LANES > 1) then
                TXDLYEN(MASTER_LANE_ID)   <= '0';
                tx_phalign_manual_state   <= S_PHINIT;
              else
                tx_phalign_manual_state   <= PHALIGN_DONE;
              end if;
            end if;
          when S_PHINIT => 
            --Assert TXPHINIT for all slave lane(s). Hold this 
            --signal High until TXPHINITDONE of the respective 
            --slave lane is asserted.
            TXPHINIT                 <= (others=>'1');--\Assert only the PHINIT-signal of
            TXPHINIT(MASTER_LANE_ID) <= '0';          --/the slaves.

            for i in 0 to NUMBER_OF_LANES - 1 loop
              if txphinitdone_store_edge(i) = '1' then
                --Deassert TXPHINIT for the slave lane in which 
                --the TXPHINITDONE is asserted.
                TXPHINIT(i) <= '0';
              end if;
            end loop;
            --if txphinitdone_store_edge = VCC_VEC and txphinitdone_ris_edge /= GND_VEC then
            if txphinitdone_store_edge = VCC_VEC then
              --When all TXPHINITDONE-signals are high and at least one rising edge
              --has been detected, move to the next state.
              --The reason for checking of the occurance of at least one rising edge
              --is to avoid the potential direct move where TXPHINITDONE might not 
              --be going low fast enough. 
              tx_phalign_manual_state   <= S_PHALIGN;
            end if;
             
          when S_PHALIGN =>
            --Assert TXPHALIGN for all slave lane(s). Hold this signal High 
            --until TXPHALIGNDONE of the respective slave lane is asserted.
            TXPHALIGN                 <= (others=>'1');--again only assertion for slave
            TXPHALIGN(MASTER_LANE_ID) <= '0';          --but not for master

            for i in 0 to NUMBER_OF_LANES - 1 loop
              --if txphaligndone_ris_edge(i) = '1' then
              if txphaligndone_store(i) = '1' then
                --Deassert TXPHALIGN for the slave lane in which the 
                --TXPHALIGNDONE is asserted.
                TXPHALIGN(i) <= '0';
              end if;
            end loop;
            --if txphaligndone_store = VCC_VEC and txphaligndone_ris_edge /= GND_VEC then
            if txphaligndone_store = VCC_VEC  then
              --When all TXPHALIGNDONE-signals are asserted high, move to the next
              --state.
              tx_phalign_manual_state   <= M_DLYEN2;
            end if;
            
          when M_DLYEN2 => 
            --Assert TXDLYEN for the master lane. This causes TXPHALIGNDONE of 
            --the master lane to be deasserted.
            TXDLYEN(MASTER_LANE_ID) <= '1';
            if txphaligndone_ris_edge(MASTER_LANE_ID) = '1' then
              --Wait until TXPHALIGNDONE of the master lane reasserts. Phase 
              --and delay alignment for the multilane interface is complete. 
              tx_phalign_manual_state   <= PHALIGN_DONE;
            end if;
            
          when PHALIGN_DONE => 
            --Continue to hold TXDLYEN for the master lane High to adjust 
            --TXUSRCLK to compensate for temperature and voltage variations.
            TXDLYEN(MASTER_LANE_ID) <= '1';
            PHASE_ALIGNMENT_DONE    <= '1';

          when OTHERS =>
            tx_phalign_manual_state   <= INIT;

        end case;      
      end if;
    end if;
  end process;


end RTL;

