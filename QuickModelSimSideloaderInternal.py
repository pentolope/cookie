
fileBasePath="H:\\FPGA\\projects\\cookie\\simulation\\"



waveAdds=[
'/sim_enviroment/core__main/main_clk',
'-radix hexadecimal /sim_enviroment/core__main/new_instruction_table',
'-radix hexadecimal /sim_enviroment/core__main/new_instruction_address_table',
'-radix hexadecimal /sim_enviroment/core__main/mem_data_out_type_0',
'/sim_enviroment/core__main/main_clk',

'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/instruction_cache_mux_inst/fifo_instruction_cache_data',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/instruction_cache_mux_inst/fifo_instruction_cache_addresses',
'-radix hexadecimal /sim_enviroment/core__main/instruction_cache_inst/instruction_cache_mux_inst/fifo_instruction_cache_indexes_future',
'-radix unsigned /sim_enviroment/core__main/instruction_cache_inst/instruction_cache_mux_inst/fifo_instruction_cache_indexes_future',
'/sim_enviroment/core__main/instruction_cache_inst/instruction_cache_mux_inst/size_help_value',
'-radix unsigned /sim_enviroment/core__main/instruction_cache_inst/instruction_cache_mux_inst/fifo_instruction_cache_consume_count_p1',


'/sim_enviroment/core__main/main_clk',

'-radix hexadecimal /sim_enviroment/core__main/user_reg',
'-radix hexadecimal /sim_enviroment/core__main/stack_pointer',
'-radix hexadecimal /sim_enviroment/core__main/instant_updated_core_values',
'-radix hexadecimal /sim_enviroment/core__main/core_executer_inst0/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_executer_inst1/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_executer_inst2/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_executer_inst3/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_executer_inst4/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_executer_inst5/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_executer_inst6/simExecutingInstruction',
'-radix hexadecimal /sim_enviroment/core__main/core_executer_inst7/simExecutingInstruction',

'/sim_enviroment/core__main/main_clk',

'/sim_enviroment/core__main/fifo_instruction_cache_size',
'/sim_enviroment/core__main/fifo_instruction_cache_consume_count',
'/sim_enviroment/core__main/fifo_instruction_cache_size_after_read',
'/sim_enviroment/core__main/main_clk',
'/sim_enviroment/core__main/scheduler_inst/fifo_instruction_cache_size_next',
'/sim_enviroment/core__main/is_performing_jump_next_instant_on',
'/sim_enviroment/core__main/is_performing_jump_instant_on',
#'/sim_enviroment/core__main/memory_interface_inst/*',
'/sim_enviroment/core__main/main_clk'
]

try:
	from time import sleep

	filePathHijackTarget=fileBasePath+"modelsim\\cookie_run_msim_rtl_verilog.do"

	f=file(filePathHijackTarget,'w')
	f.write('')
	f.close()
	
	f=file(fileBasePath+"hijacker_ready.txt",'w')
	f.write('y')
	f.close()
	
	print 'modelsim fixer ready...'
	
	hasHijacked=False
	while not hasHijacked:
		f=file(filePathHijackTarget,'r')
		contents=f.read()
		isReady=len(contents)!=0
		f.close()
		if isReady:
			print 'Hijacking in progress...'
			contents='\n'.join(filter(lambda x:not ('autogen' in x.lower()),contents.split('\n')))
			contents+='\n'
			contents+='vsim -L fiftyfivenm_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate_ver -L altera_lnsim_ver work.sim_enviroment'#-c -t 1ps
			#contents+='vsim -L altera_mf_ver work.mem_test'
			contents+='\n'
			for waveAdd in waveAdds:
				contents+='add wave '
				contents+=waveAdd
				contents+='\n'
			contents+='\n'
			contents+='run -all'
			contents+='\n'
			f=file(filePathHijackTarget,'w')
			f.write(contents)
			f.close()
			hasHijacked=True
		sleep(.001)
except Exception as ex:
	print 'Error!'
	print ex
	raw_input('Press Enter to Exit:')
	raise
print 'Finished!'
sleep(.2)
