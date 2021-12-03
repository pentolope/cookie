import os
import sys
import subprocess
from glob import glob
from time import sleep

sep="\\"
parallel=int(sys.argv[1])
seed_lower=int(sys.argv[2])
seed_upper=int(sys.argv[3])
if sys.argv[4].lower()=='true':
	do_clean=True
elif sys.argv[4].lower()=='false':
	do_clean=False
else:
	print('Error: sys.argv[4] must be either true or false')
	quit()
quartus_dir="%QUARTUS_ROOTDIR%"+sep+"bin64"+sep

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

f=open("cookie.qsf","r")
qsf_content=f.read()
f.close()
bad_initial_seed=False
for i in range(10):
	if ("set_global_assignment -name SEED 1"+str(i)) in qsf_content:bad_initial_seed=True
if ("set_global_assignment -name SEED 1" in qsf_content) and not bad_initial_seed:
	if len(glob("seed_search"+sep))!=0:
		print("Removing previous seed search...")
		subprocess.call("rmdir /S /Q seed_search",shell=True)
	os.system("title SeedSearch Starting")
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
	run_script.append('echo the original source files may now be modified.')
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
		if do_clean:
			run_script.append('echo run_script_'+str(seed_value)+' is cleaning up')
			run_script.append('rmdir /S /Q "seed_'+str(seed_value)+'"')
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
		f=open(directory_root+"cookie.qsf","w")
		f.write(qsf_content.replace("set_global_assignment -name SEED 1","set_global_assignment -name SEED "+str(seed_value)))
		f.close()
	total_count=(seed_upper+1)-seed_lower
	que0=list(range(seed_lower,seed_upper+1))
	que1=[]
	while len(que0)!=0 or len(que1)!=0:
		l=[]
		for i in que1:
			try:
				f=open("seed_search"+sep+"cookie_"+str(i)+".sta.summary","r")
				f.close()
				l.append(i)
				print('Detected seed '+str(i)+' is done')
			except:
				pass
		for i in l:
			que1.pop(que1.index(i))
		while len(que0)!=0 and len(que1)<parallel:
			i=que0.pop(0)
			que1.append(i)
			print('Executing seed '+str(i))
			subprocess.call('start /low /b "" "seed_search'+sep+'run_script_'+str(i)+'.bat"',shell=True)
			os.system("title SeedSearch "+str(total_count-len(que0))+"/"+str(total_count))
		sleep(2)
	os.system("title SeedSearch Finishing")
	print('Collecting results...')
	final_slack_seed_values=[]
	for seed_value in range(seed_lower,seed_upper+1):
		temp_slack_values=[]
		f=open("seed_search"+sep+"cookie_"+str(seed_value)+".sta.summary","r")
		fcl=f.read().split('\n')
		f.close()
		for line in fcl:
			line_split=line.split(":")
			if len(line_split)==2 and line_split[0]=="Slack ":
				temp_slack_values.append(float(line_split[1]))
		if len(temp_slack_values)!=0:
			final_slack_seed_values.append((min(temp_slack_values),seed_value))
		else:
			print("Warning: Could not find slack data for seed "+str(seed_value))
	final_slack_seed_values=sorted(final_slack_seed_values,key=lambda x:x[0])
	for seed_value in range(seed_lower,seed_upper+1):
		subprocess.call('del seed_search'+sep+'run_script_'+str(seed_value)+'.bat',shell=True)
	if len(final_slack_seed_values)!=0:
		print("Results below, sorted by lowest slack first.")
		print("")
		print("Seed : Slack")
		result_file_content="Seed : Slack\n"
		for slack_value,seed_value in final_slack_seed_values:
			seed_value_s=str(seed_value)
			while len(seed_value_s)<5:seed_value_s=seed_value_s+" "
			slack_value_s=str(slack_value)
			if slack_value_s[0]!='-':slack_value_s='+'+slack_value_s
			print(seed_value_s+" : "+slack_value_s)
			result_file_content=result_file_content+seed_value_s+" : "+slack_value_s+"\n"
		f=open("seed_search"+sep+"results.txt","w")
		f.write(result_file_content)
		f.close()
	else:
		print("No slack data found!")
	os.system("title SeedSearch Done")
else:
	print("Please set the set the seed value in the .qsf to 1 before running this script.")

