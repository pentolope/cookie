
#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {MAX10_CLK1_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports { MAX10_CLK1_50 }]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {dram_ext_clk} -source [get_pins {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}] -master_clock {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]} [get_ports {DRAM_CLK}] 
create_generated_clock -name {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {ip_pll_internal_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 8 -divide_by 5 -master_clock {MAX10_CLK1_50} [get_pins {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {ip_pll_vga_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 71 -divide_by 141 -master_clock {MAX10_CLK1_50} [get_pins {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {ip_pll_vga_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {dram_ext_clk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {dram_ext_clk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {dram_ext_clk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {dram_ext_clk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {dram_ext_clk}] -rise_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {dram_ext_clk}] -fall_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {dram_ext_clk}] -rise_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {dram_ext_clk}] -fall_to [get_clocks {ip_pll_internal_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.110  

#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[0]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[0]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[1]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[1]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[2]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[2]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[3]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[3]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[4]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[4]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[5]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[5]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[6]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[6]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[7]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[7]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[8]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[8]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[9]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[9]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[10]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[10]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[11]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[11]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[12]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[12]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[13]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[13]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[14]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[14]}]
set_input_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  5.900 [get_ports {DRAM_DQ[15]}]
set_input_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  2.600 [get_ports {DRAM_DQ[15]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[0]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[0]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[1]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[1]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[2]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[2]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[3]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[3]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[4]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[4]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[5]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[5]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[6]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[6]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[7]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[7]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[8]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[8]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[9]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[9]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[10]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[10]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[11]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[11]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_ADDR[12]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_ADDR[12]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_BA[0]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_BA[0]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_BA[1]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_BA[1]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_CAS_N}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_CAS_N}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_CKE}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_CKE}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_CS_N}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_CS_N}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[0]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[0]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[1]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[1]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[2]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[2]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[3]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[3]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[4]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[4]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[5]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[5]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[6]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[6]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[7]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[7]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[8]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[8]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[9]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[9]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[10]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[10]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[11]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[11]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[12]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[12]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[13]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[13]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[14]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[14]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_DQ[15]}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_DQ[15]}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_LDQM}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_LDQM}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_RAS_N}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_RAS_N}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_UDQM}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_UDQM}]
set_output_delay -add_delay -max -clock [get_clocks {dram_ext_clk}]  1.800 [get_ports {DRAM_WE_N}]
set_output_delay -add_delay -min -clock [get_clocks {dram_ext_clk}]  -2.000 [get_ports {DRAM_WE_N}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers {memory_io:memory__io|vga_driver:vga_driver_inst|vga_memory_system:vga_memory_system_inst|frame_counter_1[*]}] -to [get_keepers {memory_io:memory__io|vga_driver:vga_driver_inst|vga_memory_system:vga_memory_system_inst|frame_counter_2[*]}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

