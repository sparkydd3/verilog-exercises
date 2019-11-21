# TCL File Generated by Component Editor 13.0sp1
# Tue Oct 29 22:09:23 EDT 2019
# DO NOT MODIFY


# 
# avalon_vga_1_bit_color "avalon_vga_1_bit_color" v1.0
#  2019.10.29.22:09:23
# 
# 

# 
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1


# 
# module avalon_vga_1_bit_color
# 
set_module_property DESCRIPTION ""
set_module_property NAME avalon_vga_1_bit_color
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME avalon_vga_1_bit_color
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL avalon_vga_1_bit_color
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file avalon_vga_1_bit_color.v VERILOG PATH ../hw/avalon_vga_1_bit_color.v TOP_LEVEL_FILE
add_fileset_file fifo_async.v VERILOG PATH ../hw/fifo_async.v
add_fileset_file palette_1_bit_color.v VERILOG PATH ../hw/palette_1_bit_color.v
add_fileset_file vga_clk_sync.v VERILOG PATH ../hw/vga_clk_sync.v
add_fileset_file vram_1_bit_color_ctrl.v VERILOG PATH ../hw/vram_1_bit_color_ctrl.v


# 
# parameters
# 


# 
# display items
# 


# 
# connection point cpu_ctrl
# 
add_interface cpu_ctrl avalon end
set_interface_property cpu_ctrl addressUnits WORDS
set_interface_property cpu_ctrl associatedClock cpu_clk
set_interface_property cpu_ctrl associatedReset cpu_reset
set_interface_property cpu_ctrl bitsPerSymbol 8
set_interface_property cpu_ctrl burstOnBurstBoundariesOnly false
set_interface_property cpu_ctrl burstcountUnits WORDS
set_interface_property cpu_ctrl explicitAddressSpan 0
set_interface_property cpu_ctrl holdTime 0
set_interface_property cpu_ctrl linewrapBursts false
set_interface_property cpu_ctrl maximumPendingReadTransactions 1
set_interface_property cpu_ctrl readLatency 0
set_interface_property cpu_ctrl readWaitTime 1
set_interface_property cpu_ctrl setupTime 0
set_interface_property cpu_ctrl timingUnits Cycles
set_interface_property cpu_ctrl writeWaitTime 0
set_interface_property cpu_ctrl ENABLED true
set_interface_property cpu_ctrl EXPORT_OF ""
set_interface_property cpu_ctrl PORT_NAME_MAP ""
set_interface_property cpu_ctrl SVD_ADDRESS_GROUP ""

add_interface_port cpu_ctrl o_readdata readdata Output 32
add_interface_port cpu_ctrl o_readdatavalid readdatavalid Output 1
add_interface_port cpu_ctrl o_waitrequest waitrequest Output 1
add_interface_port cpu_ctrl i_address address Input 20
add_interface_port cpu_ctrl i_chipselect chipselect Input 1
add_interface_port cpu_ctrl i_read read Input 1
add_interface_port cpu_ctrl i_write write Input 1
add_interface_port cpu_ctrl i_writedata writedata Input 32
set_interface_assignment cpu_ctrl embeddedsw.configuration.isFlash 0
set_interface_assignment cpu_ctrl embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment cpu_ctrl embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment cpu_ctrl embeddedsw.configuration.isPrintableDevice 0


# 
# connection point cpu_clk
# 
add_interface cpu_clk clock end
set_interface_property cpu_clk clockRate 0
set_interface_property cpu_clk ENABLED true
set_interface_property cpu_clk EXPORT_OF ""
set_interface_property cpu_clk PORT_NAME_MAP ""
set_interface_property cpu_clk SVD_ADDRESS_GROUP ""

add_interface_port cpu_clk i_cpu_clk clk Input 1


# 
# connection point cpu_reset
# 
add_interface cpu_reset reset end
set_interface_property cpu_reset associatedClock cpu_clk
set_interface_property cpu_reset synchronousEdges DEASSERT
set_interface_property cpu_reset ENABLED true
set_interface_property cpu_reset EXPORT_OF ""
set_interface_property cpu_reset PORT_NAME_MAP ""
set_interface_property cpu_reset SVD_ADDRESS_GROUP ""

add_interface_port cpu_reset i_cpu_reset reset Input 1


# 
# connection point ctrl_sram
# 
add_interface ctrl_sram conduit end
set_interface_property ctrl_sram associatedClock cpu_clk
set_interface_property ctrl_sram associatedReset cpu_reset
set_interface_property ctrl_sram ENABLED true
set_interface_property ctrl_sram EXPORT_OF ""
set_interface_property ctrl_sram PORT_NAME_MAP ""
set_interface_property ctrl_sram SVD_ADDRESS_GROUP ""

add_interface_port ctrl_sram o_sram_addr export Output 18
add_interface_port ctrl_sram o_sram_ub_n export Output 1
add_interface_port ctrl_sram o_sram_lb_n export Output 1
add_interface_port ctrl_sram o_sram_ce_n export Output 1
add_interface_port ctrl_sram o_sram_oe_n export Output 1
add_interface_port ctrl_sram o_sram_we_n export Output 1
add_interface_port ctrl_sram io_sram_dq export Bidir 16


# 
# connection point ctrl_vga
# 
add_interface ctrl_vga conduit end
set_interface_property ctrl_vga associatedClock vga_clk
set_interface_property ctrl_vga associatedReset vga_reset
set_interface_property ctrl_vga ENABLED true
set_interface_property ctrl_vga EXPORT_OF ""
set_interface_property ctrl_vga PORT_NAME_MAP ""
set_interface_property ctrl_vga SVD_ADDRESS_GROUP ""

add_interface_port ctrl_vga o_vga_hsync export Output 1
add_interface_port ctrl_vga o_vga_vsync export Output 1
add_interface_port ctrl_vga o_vga_rgb export Output 12


# 
# connection point vga_clk
# 
add_interface vga_clk clock end
set_interface_property vga_clk clockRate 0
set_interface_property vga_clk ENABLED true
set_interface_property vga_clk EXPORT_OF ""
set_interface_property vga_clk PORT_NAME_MAP ""
set_interface_property vga_clk SVD_ADDRESS_GROUP ""

add_interface_port vga_clk i_vga_clk clk Input 1


# 
# connection point vga_reset
# 
add_interface vga_reset reset end
set_interface_property vga_reset associatedClock vga_clk
set_interface_property vga_reset synchronousEdges DEASSERT
set_interface_property vga_reset ENABLED true
set_interface_property vga_reset EXPORT_OF ""
set_interface_property vga_reset PORT_NAME_MAP ""
set_interface_property vga_reset SVD_ADDRESS_GROUP ""

add_interface_port vga_reset i_vga_reset reset Input 1

