#
#   File import script for the FELIX HDL project
#   imports files for the GBT core
#

puts "INFO: Reading and importing GBT Core sources..."
# Set the support files directory path
set scriptdir [pwd]
# firmware directory:
set proj_dir $scriptdir/../../

# --------------------------------------------------------------------------
#                  GBT Core
# --------------------------------------------------------------------------




read_vhdl -library work $proj_dir/sources/GBT/gth_code/cpll4p8g1ch_KCU/GTH_CPLL_Wrapper.vhd




read_vhdl -library work $proj_dir/sources/GBT/gbt_code/FELIX_gbt_wrapper_KCU.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/FELIX_GBT_RXSLIDE_FSM.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/FELIX_GBT_RX_AUTO_RST.vhd
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
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_gearbox_FELIX_KCU.vhd
#read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_gearbox_FELIX_method_B.vhd
#read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_rx_gearbox_FELIX_dynamic_same_latency.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_encoder_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_encoder_gbtframe_polydiv.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_encoder_gbtframe_intlver.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_encoder_gbtframe_rsencode.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_gearbox_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_scrambler_16bit.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_scrambler_21bit.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_scrambler_FELIX.vhd
#read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_timedomaincrossing_FELIX_method_B.vhd
#read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_timedomaincrossing_FELIX_method_A.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbt_tx_timedomaincrossing_FELIX_KCU.vhd

read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbtRx_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbtTx_FELIX.vhd
read_vhdl -library work $proj_dir/sources/GBT/gbt_code/gbtTxRx_FELIX.vhd


import_files $proj_dir/sources/ip_cores/kintexUltrascale/gtwizard_ultrascale_single_channel_cpll.xci
upgrade_ip [get_ips  {gtwizard_ultrascale_single_channel_cpll}]

puts "INFO: Done importing GBT Core"
