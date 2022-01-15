
fileBasePath="H:\\FPGA\\projects\\cookie\\simulation\\"



waveAdds=[
'/sim_enviroment/core__main/main_clk',

'-radix hexadecimal /sim_enviroment/core__main/memory_interface_inst/memory_system_inst/lru_least_used_way',
'-radix hexadecimal /sim_enviroment/core__main/memory_interface_inst/memory_system_inst/hard_fault',
'-radix hexadecimal /sim_enviroment/core__main/memory_interface_inst/memory_system_inst/was_hard_faulting',
'-radix hexadecimal /sim_enviroment/core__main/memory_interface_inst/memory_system_inst/was_hard_fault_starting',
'-radix hexadecimal /sim_enviroment/core__main/memory_interface_inst/memory_system_inst/change_way_for_data',
'-radix hexadecimal /sim_enviroment/core__main/memory_interface_inst/memory_system_inst/cd_raw_out_full_data',
'-radix hexadecimal /sim_enviroment/core__main/memory_interface_inst/memory_system_inst/cd_target_address',
'-radix hexadecimal /sim_enviroment/core__main/memory_interface_inst/memory_system_inst/addr_at_in_way_index',
'-radix hexadecimal /sim_enviroment/core__main/memory_interface_inst/memory_system_inst/evicted_address',

'/sim_enviroment/core__main/main_clk',

'-radix hexadecimal /sim_enviroment/core__main/mem_data_out_type_0',
'-radix hexadecimal /sim_enviroment/core__main/mem_data_out_type_1',

'/sim_enviroment/core__main/memory_interface_inst/is_general_access_requesting_extern',
'/sim_enviroment/core__main/memory_interface_inst/is_stack_access_requesting_extern',
'-radix unsigned /sim_enviroment/core__main/memory_interface_inst/next_new_index',
'-radix unsigned /sim_enviroment/core__main/memory_interface_inst/phase_diff',
'-radix unsigned /sim_enviroment/core__main/memory_interface_inst/tick_tock_phase0',
'-radix unsigned /sim_enviroment/core__main/memory_interface_inst/tick_tock_phase1',
'-radix unsigned /sim_enviroment/core__main/memory_interface_inst/tick_tock_phase2',
'-radix unsigned /sim_enviroment/core__main/memory_interface_inst/tick_tock_phase3',
'-radix unsigned /sim_enviroment/core__main/memory_interface_inst/tt_access_index',
'-radix unsigned /sim_enviroment/core__main/memory_interface_inst/tt_access_length',

'/sim_enviroment/core__main/memory_interface_inst/write_new_request_at0',
'/sim_enviroment/core__main/memory_interface_inst/write_new_request_at1',

'-radix binary /sim_enviroment/core__main/memory_interface_inst/is_general_or_stack_access_acknowledged_pulse',
'-radix binary /sim_enviroment/core__main/memory_interface_inst/is_first_overflowed_stack_ready',
'-radix binary /sim_enviroment/core__main/memory_interface_inst/raw_out_info',
'-radix binary /sim_enviroment/core__main/memory_interface_inst/raw_out_index0',
'-radix binary /sim_enviroment/core__main/memory_interface_inst/raw_out_index1',
'-radix binary /sim_enviroment/core__main/memory_interface_inst/tick_tock_phase2_moved',

'/sim_enviroment/core__main/main_clk',

'/sim_enviroment/core__main/instruction_cache_inst/void_instruction_fetch',
'/sim_enviroment/core__main/instruction_cache_inst/waiting_on_hyperfetch',
'/sim_enviroment/core__main/instruction_cache_inst/waiting_on_jump',
'/sim_enviroment/core__main/instruction_cache_inst/fetch_tradeoff_toggle',
'/sim_enviroment/core__main/instruction_cache_inst/hyperfetch_address_valid',

'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/jump_triggering',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/jump_address',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/recent_jump_addresses',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/instruction_fetch0_pointer',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/instruction_fetch1_pointer',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/instruction_fetch_requesting',
'-radix binary /sim_enviroment/core__main/instruction_cache_inst/is_data_coming_in',
'/sim_enviroment/core__main/instruction_cache_inst/fetch_tradeoff_toggle',

'/sim_enviroment/core__main/instruction_cache_inst/instruction_pointer_out',

'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/hyperfetch_suggestion_on_input',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/hyperfetch_suggestion_on_input_validity',
'/sim_enviroment/core__main/instruction_cache_inst/haltingjump_on_input_known',
'-radix binary /sim_enviroment/core__main/instruction_cache_inst/recent_jump_update_possible',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/recent_jump_data_size',
'-radix binary /sim_enviroment/core__main/instruction_cache_inst/data_in_size_at_least',
'-radix binary /sim_enviroment/core__main/instruction_cache_inst/extra_haltingjump_known_test',
'-radix binary /sim_enviroment/core__main/instruction_cache_inst/extra_haltingjump_known',
'-radix binary /sim_enviroment/core__main/instruction_cache_inst/extra_hyperjump_known_test',
'-radix binary /sim_enviroment/core__main/instruction_cache_inst/extra_hyperjump_known',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/hyperfetch_buffer_size',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/hyperfetch_buffer',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/extra_hyperfetch_detection_temp_data',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/hyperfetch_detection_temp_data',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/garenteed_prepared_avalible_space',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/buffer_size_used',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/prepared_left',

'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/buffer_size',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/circular_address_read',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/circular_address_write',

'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/prepared_instruction_count',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/prepared_left',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/circular_prepared_instruction_read',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/circular_prepared_instruction_write',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/circular_prepared_instruction_write_enable',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/circular_prepared_instruction_write_values',

'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/ready_instruction_count_next',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/ready_instruction_count_now',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/ready_left',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/ready_fill_request',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/ready_fill_satisfied',

'/sim_enviroment/core__main/main_clk',

'-radix hexadecimal /sim_enviroment/core__main/user_reg',
'-radix hexadecimal /sim_enviroment/core__main/stack_pointer',
'/sim_enviroment/core__main/main_clk',
'-radix hexadecimal /sim_enviroment/core__main/core_gen[0].core_executer_inst/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_gen[1].core_executer_inst/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_gen[2].core_executer_inst/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_gen[3].core_executer_inst/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_gen[4].core_executer_inst/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_gen[5].core_executer_inst/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_gen[6].core_executer_inst/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_gen[7].core_executer_inst/simExecutingInstruction',

'/sim_enviroment/core__main/main_clk',

'-radix hexadecimal /sim_enviroment/core__main/scheduler_inst/ready_instruction_count_now',
'-radix hexadecimal /sim_enviroment/core__main/scheduler_inst/ready_instruction_count_next',
'-radix hexadecimal /sim_enviroment/core__main/scheduler_inst/used_ready_instruction_count',
'-radix binary /sim_enviroment/core__main/scheduler_inst/is_instructions_valid',
'-radix binary /sim_enviroment/core__main/scheduler_inst/is_instructions_valid_next',
'-radix binary /sim_enviroment/core__main/scheduler_inst/instructions_might_be_valid_next',
'-radix binary /sim_enviroment/core__main/scheduler_inst/is_new_instruction_entering_this_cycle',
'-radix hexadecimal /sim_enviroment/core__main/scheduler_inst/setIndexes',
'/sim_enviroment/core__main/scheduler_inst/jump_triggering_next',
'-radix binary /sim_enviroment/core__main/scheduler_inst/isAfter',

'/sim_enviroment/core__main/main_clk'
]

try:
	from time import sleep

	filePathHijackTarget=fileBasePath+"modelsim\\cookie_run_msim_rtl_verilog.do"

	f=open(filePathHijackTarget,'w')
	f.write('')
	f.close()
	
	f=open(fileBasePath+"hijacker_ready.txt",'w')
	f.write('y')
	f.close()
	
	print('modelsim fixer ready...')
	
	hasHijacked=False
	while not hasHijacked:
		f=open(filePathHijackTarget,'r')
		contents=f.read()
		isReady=len(contents)!=0
		f.close()
		if isReady:
			print('Hijacking in progress...')
			contents='\n'.join(filter(lambda x:not ('autogen' in x.lower()),contents.split('\n')))
			contents+='\n'
			contents+='vsim -L fiftyfivenm_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate_ver -L altera_lnsim_ver work.sim_enviroment'#-c -t 1ps
			contents+='\n'
			for waveAdd in waveAdds:
				contents+='add wave '
				contents+=waveAdd
				contents+='\n'
			contents+='\n'
			contents+='run -all'
			contents+='\n'
			f=open(filePathHijackTarget,'w')
			f.write(contents)
			f.close()
			hasHijacked=True
		sleep(.001)
except Exception as ex:
	print('Error!')
	print(ex)
	input('Press Enter to Exit:')
	raise
print('Finished!')
sleep(.2)
