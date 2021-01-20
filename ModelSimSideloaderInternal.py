
fileBasePath="H:\\FPGA\\projects\\cookie\\simulation\\"

waveAdds=[
'/sim_enviroment/core__main/main_clk',
'/sim_enviroment/core__main/*',
'-radix hexadecimal /sim_enviroment/core__main/fifo_instruction_cache_data',
'-radix hexadecimal /sim_enviroment/core__main/fifo_instruction_cache_addresses',
'-radix hexadecimal /sim_enviroment/core__main/user_reg',
'/sim_enviroment/core__main/executerEnable',
'/sim_enviroment/core__main/orderConflictsSaved',
'/sim_enviroment/core__main/orderConflictsNextTrue',
'/sim_enviroment/core__main/orderConflictsAbove',
'/sim_enviroment/core__main/executionConflicts0Saved',
'/sim_enviroment/core__main/executionConflicts0NextTrue',
'/sim_enviroment/core__main/executionConflicts0Above',
'/sim_enviroment/core__main/executionConflicts1Saved',
'/sim_enviroment/core__main/executionConflicts1NextTrue',
'/sim_enviroment/core__main/executionConflicts1Above',
'/sim_enviroment/core__main/executionConflicts2Saved',
'/sim_enviroment/core__main/executionConflicts2NextTrue',
'/sim_enviroment/core__main/executionConflicts2Above',
'-radix hexadecimal /sim_enviroment/core__main/executingInstructionsSimView',
'-radix hexadecimal /sim_enviroment/core__main/allInstructionsSimView',
'/sim_enviroment/core__main/main_clk',
#'/sim_enviroment/core__main/full_memory_inst/*',
#'/sim_enviroment/core__main/main_clk',
#'/sim_enviroment/core__main/core_executer_inst0/*',
#'/sim_enviroment/core__main/main_clk',
#'/sim_enviroment/core__main/core_executer_inst1/*',
#'/sim_enviroment/core__main/main_clk',
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
