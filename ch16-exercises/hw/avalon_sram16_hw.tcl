# TCL File Generated by Component Editor 13.0sp1
# Tue Oct 01 14:52:38 EDT 2019
# DO NOT MODIFY


# 
# avalon_sram16 "avalon_sram16" v1.0
#  2019.10.01.14:52:38
# 
# 

# 
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1


# 
# module avalon_sram16
# 
set_module_property DESCRIPTION ""
set_module_property NAME avalon_sram16
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME avalon_sram16
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL avalon_sram16
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file avalon_sram16.v VERILOG PATH ../hw/avalon_sram16.v TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point cpu_ctrl
# 
add_interface cpu_ctrl avalon end
set_interface_property cpu_ctrl addressUnits WORDS
set_interface_property cpu_ctrl associatedClock clock
set_interface_property cpu_ctrl associatedReset reset
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

add_interface_port cpu_ctrl chipselect_n chipselect_n Input 1
add_interface_port cpu_ctrl read_n read_n Input 1
add_interface_port cpu_ctrl write_n write_n Input 1
add_interface_port cpu_ctrl byteenable_n byteenable_n Input 2
add_interface_port cpu_ctrl writedata writedata Input 16
add_interface_port cpu_ctrl readdata readdata Output 16
add_interface_port cpu_ctrl readdatavalid_n readdatavalid_n Output 1
add_interface_port cpu_ctrl waitrequest_n waitrequest_n Output 1
add_interface_port cpu_ctrl address address Input 18
set_interface_assignment cpu_ctrl embeddedsw.configuration.isFlash 0
set_interface_assignment cpu_ctrl embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment cpu_ctrl embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment cpu_ctrl embeddedsw.configuration.isPrintableDevice 0


# 
# connection point ctrl_sram
# 
add_interface ctrl_sram conduit end
set_interface_property ctrl_sram associatedClock clock
set_interface_property ctrl_sram associatedReset reset
set_interface_property ctrl_sram ENABLED true
set_interface_property ctrl_sram EXPORT_OF ""
set_interface_property ctrl_sram PORT_NAME_MAP ""
set_interface_property ctrl_sram SVD_ADDRESS_GROUP ""

add_interface_port ctrl_sram sram_addr export Output 18
add_interface_port ctrl_sram sram_dq export Bidir 16
add_interface_port ctrl_sram sram_ce_n export Output 1
add_interface_port ctrl_sram sram_oe_n export Output 1
add_interface_port ctrl_sram sram_we_n export Output 1
add_interface_port ctrl_sram sram_lb_n export Output 1
add_interface_port ctrl_sram sram_ub_n export Output 1

