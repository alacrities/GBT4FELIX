###############################################################################
# User Configuration
# Link Width   - x8
# Link Speed   - gen3
# Family       - virtex7
# Part         - xc7vx690t
# Package      - ffg1761
# Speed grade  - -2
# PCIe Block   - X0Y1
###############################################################################
#
###############################################################################
# User Constraints
###############################################################################

## CXP Module Reset Pins
#set_property PACKAGE_PIN AN34 [get_ports CXP1_RST_L]
#set_property IOSTANDARD LVCMOS18 [get_ports CXP1_RST_L]
#set_property PACKAGE_PIN AM31 [get_ports CXP2_RST_L]
#set_property IOSTANDARD LVCMOS18 [get_ports CXP2_RST_L]

set_property PACKAGE_PIN AN34 [get_ports opto_inhibit[0]]
set_property IOSTANDARD LVCMOS18 [get_ports opto_inhibit[0]]

set_property PACKAGE_PIN AM31 [get_ports opto_inhibit[1]]
set_property IOSTANDARD LVCMOS18 [get_ports opto_inhibit[1]]

#NET RX_CLK_TP LOC = AM31 | IOSTANDARD = "LVCMOS18";

###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################

####################### GT reference clock constraints #######################

## GT Reference clocks for Q1Q2Q3 and Q7Q8Q9

set_property PACKAGE_PIN AT7 [get_ports Q2_CLK0_GTREFCLK_PAD_N_IN]
set_property PACKAGE_PIN AT8 [get_ports Q2_CLK0_GTREFCLK_PAD_P_IN]
set_property PACKAGE_PIN E9 [get_ports Q8_CLK0_GTREFCLK_PAD_N_IN]
set_property PACKAGE_PIN E10 [get_ports Q8_CLK0_GTREFCLK_PAD_P_IN]

###############################################################################
# GBT CXP Physical Constraints
###############################################################################

### CXP (physical) channels to (GBT) firmware channels mapping
### Note: the below lines in FELIX_Gbt_wrapper.vhd should be consistent with
### the mapping when using the GT Reference clock
### GTH_RefClk(0) <= CXP1_GTH_RefClk;
### GTH_RefClk(1) <= CXP1_GTH_RefClk;
### GTH_RefClk(2) <= CXP1_GTH_RefClk;
### GTH_RefClk(3) <= CXP2_GTH_RefClk;
### GTH_RefClk(4) <= CXP2_GTH_RefClk;
### GTH_RefClk(5) <= CXP2_GTH_RefClk;

### pblocks are used to constraint the TxGearBox, GTH FSMs, and RxGearBox


### CXP1 CH1-CH4  <-->  GBT  CH1-CH4
set_property PACKAGE_PIN AY7 [get_ports {RX_N[0]}]
set_property PACKAGE_PIN BB7 [get_ports {RX_N[1]}]
set_property PACKAGE_PIN AW5 [get_ports {RX_N[2]}]
set_property PACKAGE_PIN BA5 [get_ports {RX_N[3]}]

create_pblock pblock_5
add_cells_to_pblock [get_pblocks pblock_5] [get_cells -quiet [list {g1.u2/gbtRxTx[0].gbtTxRx_inst} {g1.u2/gbtRxTx[1].gbtTxRx_inst}]]
add_cells_to_pblock [get_pblocks pblock_5] [get_cells -quiet [list {g1.u2/gbtRxTx[2].gbtTxRx_inst} {g1.u2/gbtRxTx[3].gbtTxRx_inst}]]
resize_pblock [get_pblocks pblock_5] -add {SLICE_X180Y30:SLICE_X221Y99}

### CXP1 CH5-CH8  <-->  GBT  CH9-CH12
set_property PACKAGE_PIN AU5 [get_ports  {RX_N[8]}]
set_property PACKAGE_PIN AV7 [get_ports  {RX_N[9]}]
set_property PACKAGE_PIN AP7 [get_ports  {RX_N[10]}]
set_property PACKAGE_PIN AR5 [get_ports  {RX_N[11]}]

create_pblock pblock_3
add_cells_to_pblock [get_pblocks pblock_3] [get_cells -quiet [list {g1.u2/gbtRxTx[8].gbtTxRx_inst} {g1.u2/gbtRxTx[9].gbtTxRx_inst}]]
add_cells_to_pblock [get_pblocks pblock_3] [get_cells -quiet [list {g1.u2/gbtRxTx[10].gbtTxRx_inst} {g1.u2/gbtRxTx[11].gbtTxRx_inst}]]
resize_pblock [get_pblocks pblock_3] -add {SLICE_X170Y100:SLICE_X221Y149}


### CXP1 CH9-CH12  <-->  GBT  CH17-CH20
set_property PACKAGE_PIN AN5 [get_ports  {RX_N[16]}]
set_property PACKAGE_PIN AL5 [get_ports  {RX_N[17]}]
set_property PACKAGE_PIN AM7 [get_ports {RX_N[18]}]
set_property PACKAGE_PIN AJ5 [get_ports {RX_N[19]}]

create_pblock pblock_1
add_cells_to_pblock [get_pblocks pblock_1] [get_cells -quiet [list  {g1.u2/gbtRxTx[16].gbtTxRx_inst} {g1.u2/gbtRxTx[17].gbtTxRx_inst}]]
add_cells_to_pblock [get_pblocks pblock_1] [get_cells -quiet [list  {g1.u2/gbtRxTx[18].gbtTxRx_inst} {g1.u2/gbtRxTx[19].gbtTxRx_inst}]]
resize_pblock [get_pblocks pblock_1] -add {SLICE_X170Y150:SLICE_X221Y199}

### CXP2 CH1-CH4  <-->  GBT  CH5-CH8
set_property PACKAGE_PIN L5  [get_ports {RX_N[4]}]
set_property PACKAGE_PIN P7  [get_ports {RX_N[5]}]
set_property PACKAGE_PIN J5  [get_ports {RX_N[6]}]
set_property PACKAGE_PIN N5  [get_ports {RX_N[7]}]

create_pblock pblock_6
add_cells_to_pblock [get_pblocks pblock_6] [get_cells -quiet [list {g1.u2/gbtRxTx[4].gbtTxRx_inst} {g1.u2/gbtRxTx[5].gbtTxRx_inst}]]
add_cells_to_pblock [get_pblocks pblock_6] [get_cells -quiet [list {g1.u2/gbtRxTx[6].gbtTxRx_inst} {g1.u2/gbtRxTx[7].gbtTxRx_inst}]]
resize_pblock [get_pblocks pblock_6] -add {SLICE_X170Y350:SLICE_X221Y399}


### CXP2 CH5-CH8  <-->  GBT  CH13-CH16
set_property PACKAGE_PIN G5  [get_ports {RX_N[12]}]
set_property PACKAGE_PIN H7  [get_ports {RX_N[13]}]
set_property PACKAGE_PIN E5  [get_ports {RX_N[14]}]
set_property PACKAGE_PIN F7  [get_ports {RX_N[15]}]

create_pblock pblock_2
add_cells_to_pblock [get_pblocks pblock_2] [get_cells -quiet [list {g1.u2/gbtRxTx[12].gbtTxRx_inst} {g1.u2/gbtRxTx[13].gbtTxRx_inst}]]
add_cells_to_pblock [get_pblocks pblock_2] [get_cells -quiet [list {g1.u2/gbtRxTx[14].gbtTxRx_inst} {g1.u2/gbtRxTx[15].gbtTxRx_inst}]]
resize_pblock [get_pblocks pblock_2] -add {SLICE_X170Y400:SLICE_X221Y449}

### CXP2 CH9-CH12  <-->  GBT  CH21-CH24
set_property PACKAGE_PIN D7  [get_ports {RX_N[20]}]
set_property PACKAGE_PIN B7  [get_ports {RX_N[21]}]
set_property PACKAGE_PIN C5  [get_ports {RX_N[22]}]
set_property PACKAGE_PIN A5  [get_ports {RX_N[23]}]

create_pblock pblock_4
add_cells_to_pblock [get_pblocks pblock_4] [get_cells -quiet [list {g1.u2/gbtRxTx[20].gbtTxRx_inst} {g1.u2/gbtRxTx[21].gbtTxRx_inst}]]
add_cells_to_pblock [get_pblocks pblock_4] [get_cells -quiet [list {g1.u2/gbtRxTx[22].gbtTxRx_inst} {g1.u2/gbtRxTx[23].gbtTxRx_inst}]]
resize_pblock [get_pblocks pblock_4] -add {SLICE_X170Y450:SLICE_X221Y499}

###############################################################################
# Physical Constraints
###############################################################################

## MultiCycle paths for the GBT decoding

#set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*gbtRxDescrambler21bit/RX_DATA_I_reg[*]/D" } ] 4
#set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*gbtRxDescrambler21bit/RX_DATA_I_reg[*]/D" } ] 3

#set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*FelixDescrambler/RX_HEADER_O_reg[*]/D" } ] 4
#set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*FelixDescrambler/RX_HEADER_O_reg[*]/D" } ] 3

#set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*gbtRxDescrambler21bit/feedbackRegister_reg[*]/D" } ] 4
#set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*gbtRxDescrambler21bit/feedbackRegister_reg[*]/D" } ] 3

#set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*error_buf_reg/D" } ] 4
#set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*error_buf_reg/D" } ] 3


set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*gbtRxDescrambler21bit/RX_DATA_I_reg[*]/D" } ] 3
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*gbtRxDescrambler21bit/RX_DATA_I_reg[*]/D" } ] 2

set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*FelixDescrambler/RX_HEADER_O_reg[*]/D" } ] 3
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*FelixDescrambler/RX_HEADER_O_reg[*]/D" } ] 2

set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*gbtRxDescrambler21bit/feedbackRegister_reg[*]/D" } ] 3
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*gbtRxDescrambler21bit/feedbackRegister_reg[*]/D" } ] 2

set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*error_buf_reg/D" } ] 3
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*FelixRxGearbox/reg_inv_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*error_buf_reg/D" } ] 2

set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler84bit_gen[0].gbtTxScrambler21bit/feedbackRegister_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*TX_WORD_O_reg[*]/D" } ] 2
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler84bit_gen[0].gbtTxScrambler21bit/feedbackRegister_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*TX_WORD_O_reg[*]/D" } ] 1
set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler84bit_gen[1].gbtTxScrambler21bit/feedbackRegister_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*TX_WORD_O_reg[*]/D" } ] 2
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler84bit_gen[1].gbtTxScrambler21bit/feedbackRegister_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*TX_WORD_O_reg[*]/D" } ] 1
set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler84bit_gen[2].gbtTxScrambler21bit/feedbackRegister_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*TX_WORD_O_reg[*]/D" } ] 2
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler84bit_gen[2].gbtTxScrambler21bit/feedbackRegister_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*TX_WORD_O_reg[*]/D" } ] 1

set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler32bit_gen[0].gbtTxScrambler16bit/feedbackRegister_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*TX_WORD_O_reg[*]/D" } ] 3
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler32bit_gen[0].gbtTxScrambler16bit/feedbackRegister_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*TX_WORD_O_reg[*]/D" } ] 2
set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler32bit_gen[1].gbtTxScrambler16bit/feedbackRegister_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*TX_WORD_O_reg[*]/D" } ] 3
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler32bit_gen[1].gbtTxScrambler16bit/feedbackRegister_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*TX_WORD_O_reg[*]/D" } ] 2

set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler21bit/feedbackRegister_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*tx_buffer_reg[*]/D" } ] 2
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler21bit/feedbackRegister_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*tx_buffer_reg[*]/D" } ] 1

set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler16bit/feedbackRegister_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*tx_buffer_reg[*]/D" } ] 2
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*gbtTxScrambler16bit/feedbackRegister_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*tx_buffer_reg[*]/D" } ] 1

set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*gbtRxDescrambler21bit/RX_DATA_I_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*s_rx_120b_out_f00_reg[*]/D" } ] 1
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*gbtRxDescrambler21bit/RX_DATA_I_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*s_rx_120b_out_f00_reg[*]/D" } ] 0
set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*gbtRxDescrambler16bit/RX_EXTRA_DATA_WIDEBUS_I_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*s_rx_120b_out_f00_reg[*]/D" } ] 1
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*gbtRxDescrambler16bit/RX_EXTRA_DATA_WIDEBUS_I_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*s_rx_120b_out_f00_reg[*]/D" } ] 0
set_multicycle_path  -setup -start -from [get_pins -hierarchical -filter { NAME =~  "*FelixDescrambler/RX_HEADER_O_reg[*]/C" } ] -to [get_pins -hierarchical -filter { NAME =~ "*s_rx_120b_out_f00_reg[*]/D" } ] 1
set_multicycle_path  -hold  -end -from [get_pins -hierarchical -filter { NAME =~  "*FelixDescrambler/RX_HEADER_O_reg[*]/C" } ]   -to [get_pins -hierarchical -filter { NAME =~ "*s_rx_120b_out_f00_reg[*]/D" } ] 0



###############################################################################
# Timing Constraints
###############################################################################

create_clock -name g1.u2/GT_TX_WORD_CLK[0] -period 4.167 [get_pins g1.u2/usrclk_inst[0].gthusrclk_gen/txclkgen_sys.txoutclk_bufg0_i/O]
create_clock -name g1.u2/GT_TX_WORD_CLK[4] -period 4.167 [get_pins g1.u2/usrclk_inst[1].gthusrclk_gen/txclkgen_sys.txoutclk_bufg0_i/O]
create_clock -name g1.u2/GT_TX_WORD_CLK[8] -period 4.167 [get_pins g1.u2/usrclk_inst[2].gthusrclk_gen/txclkgen_sys.txoutclk_bufg0_i/O]
create_clock -name g1.u2/GT_TX_WORD_CLK[12] -period 4.167 [get_pins g1.u2/usrclk_inst[3].gthusrclk_gen/txclkgen_sys.txoutclk_bufg0_i/O]
create_clock -name g1.u2/GT_TX_WORD_CLK[16] -period 4.167 [get_pins g1.u2/usrclk_inst[4].gthusrclk_gen/txclkgen_sys.txoutclk_bufg0_i/O]
create_clock -name g1.u2/GT_TX_WORD_CLK[20] -period 4.167 [get_pins g1.u2/usrclk_inst[5].gthusrclk_gen/txclkgen_sys.txoutclk_bufg0_i/O]

create_clock -name g1.u2/GT_RX_WORD_CLK[0] -period 4.167 [get_pins g1.u2/usrclk_inst[0].gthusrclk_gen/clkgen_sys.rxoutclk_bufg1_i/O]
create_clock -name g1.u2/GT_RX_WORD_CLK[4] -period 4.167 [get_pins g1.u2/usrclk_inst[1].gthusrclk_gen/clkgen_sys.rxoutclk_bufg1_i/O]
create_clock -name g1.u2/GT_RX_WORD_CLK[8] -period 4.167 [get_pins g1.u2/usrclk_inst[2].gthusrclk_gen/clkgen_sys.rxoutclk_bufg1_i/O]
create_clock -name g1.u2/GT_RX_WORD_CLK[12] -period 4.167 [get_pins g1.u2/usrclk_inst[3].gthusrclk_gen/clkgen_sys.rxoutclk_bufg1_i/O]
create_clock -name g1.u2/GT_RX_WORD_CLK[16] -period 4.167 [get_pins g1.u2/usrclk_inst[4].gthusrclk_gen/clkgen_sys.rxoutclk_bufg1_i/O]
create_clock -name g1.u2/GT_RX_WORD_CLK[20] -period 4.167 [get_pins g1.u2/usrclk_inst[5].gthusrclk_gen/clkgen_sys.rxoutclk_bufg1_i/O]

create_clock -period 6.250 -name ts_clk_adn_160 [get_nets clk_adn_160]

set_false_path -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[0]]
set_false_path -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[0]]
#set_multicycle_path 3 -setup -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[0]]
#set_multicycle_path 2 -hold -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[0]]
#set_multicycle_path 3 -setup -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[0]]
#set_multicycle_path 2 -hold -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[0]]
set_false_path -from [get_clocks ts_clk_adn_160] -to [get_clocks g1.u2/GT_TX_WORD_CLK[0]]

set_false_path -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[4]]
set_false_path -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[4]]
#set_multicycle_path 3 -setup -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[4]]
#set_multicycle_path 2 -hold -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[4]]
#set_multicycle_path 3 -setup -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[4]]
#set_multicycle_path 2 -hold -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[4]]
set_false_path -from [get_clocks ts_clk_adn_160] -to [get_clocks g1.u2/GT_TX_WORD_CLK[4]]

set_false_path -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[20]]
set_false_path -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[20]]
#set_multicycle_path 3 -setup -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[20]]
#set_multicycle_path 2 -hold -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[20]]
#set_multicycle_path 3 -setup -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[20]]
#set_multicycle_path 2 -hold -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[20]]
set_false_path -from [get_clocks ts_clk_adn_160] -to [get_clocks g1.u2/GT_TX_WORD_CLK[20]]

set_false_path -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[16]]
set_false_path -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[16]]
#set_multicycle_path 3 -setup -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[16]]
#set_multicycle_path 2 -hold -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[16]]
#set_multicycle_path 3 -setup -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[16]]
#set_multicycle_path 2 -hold -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[16]]
set_false_path -from [get_clocks ts_clk_adn_160] -to [get_clocks g1.u2/GT_TX_WORD_CLK[16]]

set_false_path -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[12]]
set_false_path -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[12]]
#set_multicycle_path 3 -setup -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[12]]
#set_multicycle_path 2 -hold -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[12]]
#set_multicycle_path 3 -setup -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[12]]
#set_multicycle_path 2 -hold -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[12]]
set_false_path -from [get_clocks ts_clk_adn_160] -to [get_clocks g1.u2/GT_TX_WORD_CLK[12]]

set_false_path -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[8]]
set_false_path -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[8]]
#set_multicycle_path 3 -setup -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[8]]
#set_multicycle_path 2 -hold -from [get_clocks clk40_clk_wiz_40_0] -to [get_clocks g1.u2/GT_TX_WORD_CLK[8]]
#set_multicycle_path 3 -setup -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[8]]
#set_multicycle_path 2 -hold -from [get_clocks clk_out40_clk_wiz_40] -to [get_clocks g1.u2/GT_TX_WORD_CLK[8]]
set_false_path -from [get_clocks ts_clk_adn_160] -to [get_clocks g1.u2/GT_TX_WORD_CLK[8]]

set_false_path -from [get_clocks g1.u2/GT_TX_WORD_CLK[0]] -to [get_clocks clk40_clk_wiz_40_0]
set_false_path -from [get_clocks g1.u2/GT_TX_WORD_CLK[4]] -to [get_clocks clk40_clk_wiz_40_0]
set_false_path -from [get_clocks g1.u2/GT_TX_WORD_CLK[8]] -to [get_clocks clk40_clk_wiz_40_0]
set_false_path -from [get_clocks g1.u2/GT_TX_WORD_CLK[12]] -to [get_clocks clk40_clk_wiz_40_0]
set_false_path -from [get_clocks g1.u2/GT_TX_WORD_CLK[16]] -to [get_clocks clk40_clk_wiz_40_0]
set_false_path -from [get_clocks g1.u2/GT_TX_WORD_CLK[20]] -to [get_clocks clk40_clk_wiz_40_0]

set_false_path -from [get_clocks {g1.u2/GT_TX_WORD_CLK[0]}] -to [get_clocks clk_out40_clk_wiz_40]
set_false_path -from [get_clocks {g1.u2/GT_TX_WORD_CLK[4]}] -to [get_clocks clk_out40_clk_wiz_40]
set_false_path -from [get_clocks {g1.u2/GT_TX_WORD_CLK[8]}] -to [get_clocks clk_out40_clk_wiz_40]
set_false_path -from [get_clocks {g1.u2/GT_TX_WORD_CLK[12]}] -to [get_clocks clk_out40_clk_wiz_40]
set_false_path -from [get_clocks {g1.u2/GT_TX_WORD_CLK[16]}] -to [get_clocks clk_out40_clk_wiz_40]
set_false_path -from [get_clocks {g1.u2/GT_TX_WORD_CLK[20]}] -to [get_clocks clk_out40_clk_wiz_40]

###############################################################################
# Others
###############################################################################

# force Vivado to ignore usage of GTGREFCLK
set_property SEVERITY {Warning} [get_drc_checks REQP-44]
set_property SEVERITY {Warning} [get_drc_checks REQP-46]
# force vivado to ignore unplaced pins
#set_property SEVERITY {Warning} [get_drc_checks IOSTDTYPE-1]

###############################################################################
# End
###############################################################################
