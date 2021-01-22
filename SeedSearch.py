import os
import subprocess
from glob import glob
sep="\\"
seed_lower=1
seed_upper=20
quartus_dir="H:\\FPGA\\program\\quartus\\bin64\\"

def directory_find(origin):
	return [(dr,directory_find(dr)) for dr in glob(origin+"*"+sep)]
def initial_directory_find():
	return [("",directory_find(""))]
def directory_filter(source,removal):
	l=[]
	for dr,sub in source:
		if dr[:len(removal)]!=removal:
			l.append((dr,directory_filter(sub,removal)))
	return l
def file_extract(origins):
	l=[]
	for dr,sub in origins:
		drs=glob(dr+"*"+sep)
		l+=filter(lambda x:not ((x+sep) in drs),glob(dr+"*"))
	for dr,sub in origins:
		l+=file_extract(sub)
	return l
def directory_extract(origins):
	l=[]
	for dr,sub in origins:
		l+=glob(dr+"*"+sep)
	for dr,sub in origins:
		l+=directory_extract(sub)
	return l
if len(glob("seed_search"+sep))!=0:
	print("Removing previous seed search...")
	subprocess.call("rmdir /S /Q seed_search",shell=True)
f=open("cookie.qsf","rb")
qsf_content=f.read()
f.close()
if "set_global_assignment -name SEED 1" in qsf_content:
	print("Finding files...")
	directory_structure=directory_filter(directory_filter(initial_directory_find(),"simulation"+sep),"output_files"+sep)
	directory_list=list(filter(lambda y:y!="output_files"+sep,filter(lambda x:x!="simulation"+sep,directory_extract(directory_structure))))
	file_list=list(filter(lambda x:x!="cookie.qsf",file_extract(directory_structure)))
	print("Setting up base...")
	os.mkdir("seed_search"+sep)
	os.mkdir("seed_search"+sep+"base"+sep)
	for directory_item in directory_list:
		os.mkdir("seed_search"+sep+"base"+sep+directory_item)
	run_script=[]
	run_script.append('@echo off')
	run_script.append('echo base setup script is copying files')
	for file_item in file_list:
		run_script.append('copy /B "'+file_item+'" /B "'+"seed_search"+sep+"base"+sep+file_item+'" >NUL')
	run_script.append('echo base setup script has finished copying files.')
	run_script.append('echo the original may now be modified,')
	run_script.append('echo because the scripts will use my copy for their sources')
	run_script.append('exit')
	f=open("seed_search"+sep+"base_setup.bat","w")
	f.write('\n'.join(run_script)+'\n')
	f.close()
	subprocess.call('"seed_search'+sep+'base_setup.bat"',shell=True)
	subprocess.call('del "seed_search'+sep+'base_setup.bat"',shell=True)
	print("Generating run scripts...")
	for seed_value in range(seed_lower,seed_upper+1):
		run_script=[]
		run_script.append('@echo off')
		run_script.append('echo run_script_'+str(seed_value)+' is copying files')
		run_script.append('cd seed_search')
		for file_item in file_list:
			run_script.append('copy /B "base'+sep+file_item+'" /B "'+"seed_"+str(seed_value)+sep+file_item+'" >NUL')
		run_script.append('cd seed_'+str(seed_value))
		run_script.append('echo run_script_'+str(seed_value)+' is running fitter')
		run_script.append('"'+quartus_dir+'quartus_fit.exe" --read_settings_files=on --write_settings_files=off cookie -c cookie >NUL')
		run_script.append('echo run_script_'+str(seed_value)+' is running timing analyser')
		run_script.append('"'+quartus_dir+'quartus_sta.exe" cookie -c cookie >NUL')
		run_script.append('echo run_script_'+str(seed_value)+' is copying result file')
		run_script.append('cd ..')
		run_script.append('copy /B "seed_'+str(seed_value)+sep+'output_files'+sep+'cookie.sta.summary" /B "cookie_'+str(seed_value)+'.sta.summary" >NUL')
		#run_script.append('echo run_script_'+str(seed_value)+' is cleaning up')
		#run_script.append('rmdir /S /Q "seed_'+str(seed_value)+'"')
		run_script.append('cd ..')
		run_script.append('echo run_script_'+str(seed_value)+' is finished with this seed')
		run_script.append('exit')
		f=open("seed_search"+sep+"run_script_"+str(seed_value)+".bat","w")
		f.write('\n'.join(run_script)+'\n')
		f.close()
	for seed_value in range(seed_lower,seed_upper+1):
		directory_root="seed_search"+sep+"seed_"+str(seed_value)+sep
		os.mkdir(directory_root)
		for directory_item in directory_list:
			os.mkdir(directory_root+directory_item)
		f=open(directory_root+"cookie.qsf","wb")
		f.write(qsf_content.replace("set_global_assignment -name SEED 1","set_global_assignment -name SEED "+str(seed_value)))
		f.close()
	for seed_value in range(seed_lower,seed_upper+1):
		print('Executing seed '+str(seed_value))
		subprocess.call("start /low /wait /b seed_search"+sep+"run_script_"+str(seed_value)+".bat",shell=True)
else:
	print("you must set the set the seed value in the .qsf to 1 before running this script")





