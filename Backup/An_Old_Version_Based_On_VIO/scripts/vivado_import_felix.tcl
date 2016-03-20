#
#	File import script for the FELIX hdl project
#
#	

#Script Configuration

set proj_name top
# Set the supportfiles directory path
set scriptdir [pwd]
set firmware_dir $scriptdir/../
# Vivado project directory:
set project_dir $firmware_dir/Projects/$proj_name

#Close currently open project and create a new one. (OVERWRITES PROJECT!!)
close_project -quiet

create_project -force -part xc7vx690tffg1761-2 $proj_name $firmware_dir/Projects/$proj_name

set_property target_language VHDL [current_project]
set_property default_lib work [current_project]

# ----------------------------------------------------------
# FELIX top module
# ----------------------------------------------------------
read_vhdl -library work $firmware_dir/sources/top.vhd
read_vhdl -library work $firmware_dir/sources/gbt_test_top.vhd

# ----------------------------------------------------------
# packages
# ----------------------------------------------------------
read_vhdl -library work $firmware_dir/sources/packages/pcie_package.vhd
read_vhdl -library work $firmware_dir/sources/packages/FELIX_gbt_package.vhd


import_ip $firmware_dir/sources/GBT/standalone_test/clk_wiz_0.xci
import_ip $firmware_dir/sources/GBT/standalone_test/mmcm_for_GBT_testing.xci
import_ip $firmware_dir/sources/GBT/standalone_test/vio_0.xci


# ----------------------------------------------------------
# dma sources
# ----------------------------------------------------------
read_vhdl -library work $firmware_dir/sources/PCIe/dma_control.vhd
read_vhdl -library work $firmware_dir/sources/PCIe/pcie_clocking.vhd
read_vhdl -library work $firmware_dir/sources/PCIe/pcie_slow_clock.vhd
read_vhdl -library work $firmware_dir/sources/PCIe/dma_read_write.vhd
read_vhdl -library work $firmware_dir/sources/PCIe/intr_ctrl.vhd
read_vhdl -library work $firmware_dir/sources/PCIe/DMA_Core.vhd
read_vhdl -library work $firmware_dir/sources/PCIe/pcie_ep_wrap.vhd
read_vhdl -library work $firmware_dir/sources/PCIe/pcie_dma_wrap.vhd
read_vhdl -library work $firmware_dir/sources/PCIe/pcie_init.vhd
read_vhdl -library work $firmware_dir/sources/PCIe/register_map_sync.vhd

import_ip $firmware_dir/sources/PCIe/pcie_x8_gen3_3_0.xci
import_ip $firmware_dir/sources/PCIe/clk_wiz_40.xci




# ----------------------------------------------------------
# GBT Core
# ----------------------------------------------------------
source $scriptdir/source_import_gbt_core.tcl


# ----------------------------------------------------------
# Update IP to latest Vivado version
# ----------------------------------------------------------

upgrade_ip [get_ips  {pcie_x8_gen3_3_0 clk_wiz_40 vio_0 clk_wiz_0 mmcm_for_GBT_testing}]

# ----------------------------------------------------------
# XDC constraints files
# ----------------------------------------------------------

read_xdc -verbose $firmware_dir/sources/constraints/felix_gbt_cxp_HTG710.xdc
read_xdc -verbose $firmware_dir/sources/constraints/felix_top_HTG710.xdc

#close [ open $firmware_dir/constraints/felix_probes.xdc w ]
#read_xdc -verbose $firmware_dir/constraints/felix_probes.xdc
#import_files -fileset constrs_1 $firmware_dir/constraints/felix_probes.xdc
#set_property target_constrs_file $firmware_dir/constraints/felix_probes.xdc [current_fileset -constrset]

set_property top top [current_fileset]
#set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]

puts "INFO: Done!"







