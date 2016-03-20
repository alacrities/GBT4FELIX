#
#   File import script for the FELIX HDL project
#   imports files for the GBT core
#

puts "INFO: Reading and importing GBT Core sources..."
# Set the support files directory path
set scriptdir [pwd]
# firmware directory:
set proj_dir $scriptdir/../

# --------------------------------------------------------------------------
#                  GBT Core
# --------------------------------------------------------------------------

read_vhdl -library work $proj_dir/sources/GBT/gth_code/gth_top.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/gth_usrclk_gen.vhd

read_vhdl -library work $proj_dir/sources/GBT/gth_code/cpll4p8g4ch/gth_quad_4p8g_cpll_exdes.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/cpll4p8g4ch/gth_quad_4p8g_cpll_manual_gt.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/cpll4p8g4ch/gth_quad_4p8g_cpll_manual_init.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/cpll4p8g4ch/gth_quad_4p8g_cpll_manual_multi_gt.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/cpll4p8g4ch/gth_quad_4p8g_cpll_manual_rx_manual_phase_align.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/cpll4p8g4ch/gth_quad_4p8g_cpll_manual_rx_startup_fsm.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/cpll4p8g4ch/gth_quad_4p8g_cpll_manual_sync_block.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/cpll4p8g4ch/gth_quad_4p8g_cpll_manual_sync_pulse.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/cpll4p8g4ch/gth_quad_4p8g_cpll_manual_tx_manual_phase_align.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/cpll4p8g4ch/gth_quad_4p8g_cpll_manual_tx_startup_fsm.vhd

read_vhdl -library work $proj_dir/sources/GBT/gth_code/qpll4p8g4ch/gtwizard_qpll_4p8g_4ch.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/qpll4p8g4ch/gtwizard_qpll_4p8g_4ch_gt.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/qpll4p8g4ch/gtwizard_qpll_4p8g_4ch_gtrxreset_seq.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/qpll4p8g4ch/gtwizard_qpll_4p8g_4ch_init.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/qpll4p8g4ch/gtwizard_qpll_4p8g_4ch_multi_gt.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/qpll4p8g4ch/gtwizard_qpll_4p8g_4ch_rx_manual_phase_align.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/qpll4p8g4ch/gtwizard_qpll_4p8g_4ch_rx_startup_fsm.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/qpll4p8g4ch/gtwizard_qpll_4p8g_4ch_sync_block.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/qpll4p8g4ch/gtwizard_qpll_4p8g_4ch_sync_pulse.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/qpll4p8g4ch/gtwizard_qpll_4p8g_4ch_tx_manual_phase_align.vhd
read_vhdl -library work $proj_dir/sources/GBT/gth_code/qpll4p8g4ch/gtwizard_qpll_4p8g_4ch_tx_startup_fsm.vhd



read_vhdl -library work $proj_dir/sources/GBT/gbt_code/FELIX_gbt_wrapper.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/FELIX_GBT_RX_ALIGN_FSM.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_decoder_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_decoder_gbtframe_chnsrch.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_decoder_gbtframe_deintlver.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_decoder_gbtframe_elpeval.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_decoder_gbtframe_errlcpoly.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_decoder_gbtframe_lmbddet.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_decoder_gbtframe_rs2errcor.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_decoder_gbtframe_rsdec.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_decoder_gbtframe_rsdec_sync.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_decoder_gbtframe_syndrom.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_descrambler_16bit.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_descrambler_21bit.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_descrambler_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_gearbox_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_encoder_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_encoder_gbtframe_polydiv.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_encoder_gbtframe_intlver.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_encoder_gbtframe_rsencode.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_gearbox_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_scrambler_16bit.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_scrambler_21bit.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_scrambler_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_timedomaincrossing_FELIX.vhd

read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbtRx_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbtTx_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbtTxRx_FELIX.vhd

puts "INFO: Done importing GBT Core"
