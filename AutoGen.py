

############################################################


outFileList=[]

import itertools as it

perms=list(it.permutations(range(4)[::-1]))
assert len(perms)==24


outFileList.append("wire [1:0] lookup0 [23:0];")
outFileList.append("wire [4:0] lookup1 [95:0];")



for ii0 in range(24):
	outFileList.append("assign lookup0["+str(ii0)+"]="+str(perms[ii0][3])+";")
	for ii1 in range(4):
		perm=list(perms[ii0])
		perm.pop(perm.index(ii1))
		perm=(ii1,)+tuple(perm)
		outFileList.append("assign lookup1["+str(ii0*4+ii1)+"]="+str(perms.index(perm))+";")

outFileList.append("assign least_used_index_calc=lookup0[raw_perm_out];")
outFileList.append("assign raw_perm_in=lookup1[{raw_perm_out,used_index_delayed}];")

del perms

f=open('AutoGen0.sv','w')
f.write('\n'+'\n'.join(outFileList)+'\n')
f.close()
del f

############################################################



def zeroPad(s0,n):
	s1=s0
	while len(s1)<n:s1='0'+s1
	return s1


def And(v0,v1):return v0 & v1
def Or (v0,v1):return v0 | v1
def Xor(v0,v1):return v0 ^ v1

class BoolObj(object):
	def __init__(self,vtype,vIN0,vIN1):
		self.vtype=vtype
		self.vIN0=vIN0
		self.vIN1=vIN1
	def __and__(self,other):
		return BoolObj("&",self,other)
	def __or__(self,other):
		return BoolObj("|",self,other)
	def __xor__(self,other):
		return BoolObj("^",self,other)
	def __invert__(self):
		return BoolObj("~",self,other)
	def __str__(self):
		return "(" + str(self.vIN0) + self.vtype + str(self.vIN1) + ")"


validInsertionCombinations=[]
for x0 in [-1]+range(1):
	for x1 in [-1]+range(2):
		for x2 in [-1]+range(3):
			for x3 in [-1]+range(4):
				kp=False
				kl=[x0,x1,x2,x3]
				for t0,t1 in list(it.combinations(range(4),2)):
					if kl[t0]!=-1 and kl[t1]!=-1 and kl[t0]>=kl[t1]:kp=True
				if not kp:
					kt=[]
					for i in kl:
						if i==-1:kt.append(None)
						else:kt.append(i)
					validInsertionCombinations.append(tuple(kt))



outFileList2=[]
outFileList3=[]

outFileList2.append("""unique case ({
is_new_instruction_entering_this_cycle_pulse_3,({2{is_new_instruction_entering_this_cycle_pulse_3}} & new_instruction_index3),
is_new_instruction_entering_this_cycle_pulse_2,({2{is_new_instruction_entering_this_cycle_pulse_2}} & new_instruction_index2),
is_new_instruction_entering_this_cycle_pulse_1,(is_new_instruction_entering_this_cycle_pulse_1 & new_instruction_index1[0]),
is_new_instruction_entering_this_cycle_pulse_0
})""")

md={}

for x0,x1,x2,x3 in validInsertionCombinations:
	if x0 is None:xb0='0'
	elif x0==0:xb0='1'
	else:assert False
	
	if x1 is None:xb1='00'
	elif x1==0:xb1='10'
	elif x1==1:xb1='11'
	else:assert False
	
	if x2 is None:xb2='000'
	elif x2==0:xb2='100'
	elif x2==1:xb2='101'
	elif x2==2:xb2='110'
	else:assert False
	
	if x3 is None:xb3='000'
	elif x3==0:xb3='100'
	elif x3==1:xb3='101'
	elif x3==2:xb3='110'
	elif x3==3:xb3='111'
	else:assert False
	
	xn0=not (x0 is None)
	xn1=not (x1 is None)
	xn2=not (x2 is None)
	xn3=not (x3 is None)
	
	xns=[xn0,xn1,xn2,xn3]
	xs=[x0,x1,x2,x3]
	kke=xb3+xb2+xb1+xb0
	md[kke]=[]
	#outFileList2.append("9'b"+xb3+xb2+xb1+xb0+":begin")
	
	for i0 in range(4):
		if xns[i0]:
			for i1 in range(4):
				if i0!=i1:
					vDest="n,"+str(i0)+","+str(i1)
					if i1<i0 and xns[i1]:
						vSource="a,"+str(xs[i0])+","+str(xs[i1]+4)
					else:
						#vSource="executionConflictsAbove["+str(xs[i0])+"]["+str(i1)+"]"
						#vDest="executionConflictsNext["+str(i0)+"]["+str(i1)+"]"
						vSource="a,"+str(xs[i0])+","+str(i1)
					md[kke].append(vDest+"="+vSource)

dti={}
for kke in md.keys():
	for le in md[kke]:
		li0=le.split('=')[0]
		dti[li0]=[li0]
for kke in sorted(md.keys()):
	for le in md[kke]:
		li=le.split('=')
		if not (li[1] in dti[li[0]]):
			dti[li[0]].append(li[1])
for kkb in sorted(dti.keys()):
	assert kkb.split(',')[0]=='n'
	na="excn"+kkb.split(',')[1]+kkb.split(',')[2]+"Mux"
	nb="excn"+kkb.split(',')[1]+kkb.split(',')[2]+"Index"
	for ina in range(4):
		outFileList3.append("wire "+na+str(ina)+" ["+str(len(dti[kkb])-1)+":0];")
	si=1
	while 2**si<len(dti[kkb]):
		si+=1
	if si==1:
		outFileList3.append("reg "+nb+";")
	else:
		outFileList3.append("reg ["+str(si-1)+":0] "+nb+";")
	for ii,kle in list(enumerate(dti[kkb])):
		if kle.split(',')[0]=='n':
			for ina in range(4):
				if ina==3:
					outFileList3.append("assign "+na+str(ina)+"["+str(ii)+"]=orderConflictsNext["+kle.split(',')[1]+"]["+kle.split(',')[2]+"];")
				else:
					outFileList3.append("assign "+na+str(ina)+"["+str(ii)+"]=executionConflicts"+str(ina)+"Next["+kle.split(',')[1]+"]["+kle.split(',')[2]+"];")
		else:
			assert kle.split(',')[0]=='a'
			for ina in range(4):
				if ina==3:
					outFileList3.append("assign "+na+str(ina)+"["+str(ii)+"]=orderConflictsAbove["+kle.split(',')[1]+"]["+kle.split(',')[2]+"];")
				else:
					outFileList3.append("assign "+na+str(ina)+"["+str(ii)+"]=executionConflicts"+str(ina)+"Above["+kle.split(',')[1]+"]["+kle.split(',')[2]+"];")
	for ina in range(4):
		if ina==3:
			outFileList3.append("assign orderConflictsNextTrue["+kkb.split(',')[1]+"]["+kkb.split(',')[2]+"]="+na+str(ina)+"["+nb+"];")
		else:
			outFileList3.append("assign executionConflicts"+str(ina)+"NextTrue["+kkb.split(',')[1]+"]["+kkb.split(',')[2]+"]="+na+str(ina)+"["+nb+"];")
for ii in range(4):
	for ina in range(4):
		if ina==3:
			outFileList3.append("assign orderConflictsNextTrue["+str(ii)+"]["+str(ii)+"]=1'b0;")
		else:
			outFileList3.append("assign executionConflicts"+str(ina)+"NextTrue["+str(ii)+"]["+str(ii)+"]=1'b0;")
rrd={}
for kke in sorted(md.keys()):
	dtt={}
	for kkb in dti.keys():
		dtt[kkb]=0
	for le in md[kke]:
		li=le.split('=')
		dtt[li[0]]=dti[li[0]].index(li[1])
	outFileList2.append("9'b"+kke+":begin")
	rrd[kke]=[]
	for kkb in sorted(dti.keys()):
		nb="excn"+kkb.split(',')[1]+kkb.split(',')[2]+"Index"
		outFileList2.append(nb+"="+str(dtt[kkb])+";")
		rrd[kke].append(nb+"="+str(dtt[kkb])+";")
	outFileList2.append("end")



outFileList2.append("endcase")



f=open('AutoGen2.sv','w')
f.write('\n'+'\n'.join(outFileList2)+'\n')
f.close()
del f
del outFileList2
f=open('AutoGen3.sv','w')
f.write('\n'+'\n'.join(outFileList3)+'\n')
f.close()
del f
del outFileList3

del validInsertionCombinations

######### sort of (rrd gets kept) ##############


outFileList=[]

perms=list(it.permutations(range(4)))
assert len(perms)==24

def setFirst(perm,numberToSetFirst):
	permNext=list(perm[:])
	permNext.pop(permNext.index(numberToSetFirst))
	return (numberToSetFirst,)+tuple(permNext)

def zeroPad(s0,n):
	s1=s0
	while len(s1)<n:s1='0'+s1
	return s1

outFileList.append("unique case ({isInstructionValid_scheduler_3_future2,isInstructionValid_scheduler_2_future2,isInstructionValid_scheduler_1_future2,isInstructionValid_scheduler_0_future2,fifo_instruction_cache_size_converted})")

for sizeArrangment in map(lambda x:zeroPad(bin(x)[2:],3),range(5)):
	for validArrangment in map(lambda x:zeroPad(bin(x)[2:],4),range(16)):
		outFileList.append("7'b"+validArrangment+sizeArrangment+":begin")
		sizeLeft=int(sizeArrangment,2)
		sizeUsed=0
		inietc=["0","0","0","0"]
		niiv=["00","00","00","00"]
		for i in range(4):
			if validArrangment[::-1][i]=='0' and sizeLeft!=0:
				outFileList.append("new_instruction_index"+str(i)+"="+str(sizeUsed)+";")
				outFileList.append("is_new_instruction_entering_this_cycle_pulse_"+str(i)+"=1;")
				inietc[i]="1"
				niiv[i]=zeroPad(bin(sizeUsed)[2:],2)
				sizeUsed+=1
				sizeLeft-=1
		for adli in rrd[inietc[3]+niiv[3]+inietc[2]+niiv[2]+inietc[1]+niiv[1][1]+inietc[0]]:
			outFileList.append(adli)
		outFileList.append("if (fifo_instruction_cache_consume_count!="+str(sizeUsed)+") begin $stop(); end")
		outFileList.append("end")

outFileList.append("endcase")

f=open('AutoGen1.sv','w')
f.write('\n'+'\n'.join(outFileList)+'\n')
f.close()
del f
del outFileList


############################################################


"""
    more significant bits                    less significant bits
# -  15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0
0 -   0,  0,s01,s00, i7, i6, i5, i4, i3, i2, i1, i0,r03,r02,r01,r00
1 - s03,s02,s01,s00,r23,r22,r21,r20,r13,r12,r11,r10,r03,r02,r01,r00        *Note:  s03,s02 != 0,0   and  s03,s02,s01,s00 != 1,1,1,1
2 -   1,  1,  1,  1,s03,s02,s01,s00,r13,r12,r11,r10,r03,r02,r01,r00


Instructions:

0 -     0,0, - immediate -> r0[7:0] , 0 -> r0[F:8]
0 -     0,1, - immediate -> r0[F:8] , r0[7:0] is unchanged
0 -     1,0, - read  stack word at (%1+(2*immediate)) into r0
0 -     1,1, - write stack word at (%1+(2*immediate)) with data in r0

1 - 0,1,0,0, - r1  and r2 -> r0
1 - 0,1,0,1, - r1  or  r2 -> r0
1 - 0,1,1,0, - r1  xor r2 -> r0
1 - 0,1,1,1, - r0 + r1 +~r2 -> r1, with carry stored to ones bit of r0, if carry would be larger then 1, r0 would still hold 1.
1 - 1,0,0,0, - memory read a  word into r0 at r1,r2  (must be aligned to word boundry)
1 - 1,0,0,1, - memory write the word in r0 at r1,r2  (must be aligned to word boundry)
1 - 1,0,1,0, - r1 + r2 -> r0
1 - 1,0,1,1, - r1 + r2 + %F -> r0, with carry stored to ones bit of %F, if carry would be larger then 1, r0 would still hold 1.
1 - 1,1,0,0, - r1 - r2 -> r0
1 - 1,1,0,1, - r1 - r2 (carry)-> r0
1 - 1,1,1,0, - conditional jump if(r2 == 0) to r0,r1 (must be aligned to word boundry)

2 - 0,0,0,0, - push r0 to stack
2 - 0,0,0,1, - push r0 then r1 to stack
2 - 0,0,1,0, - pop stack to r0
2 - 0,0,1,1, - pop stack to r0 then to r1
2 - 0,1,0,0, - mov r1 to r0
2 - 0,1,0,1, - swap bytes in r1, place result in r0 (r1 is not modified)
2 - 0,1,1,0, - shift r1 down one bit towards lower bits and store in r0 (r1 is not modified)
2 - 0,1,1,1, - r0 * r1 -> r0 (word multiply, the upper word is not generated)
2 - 1,0,0,0, - %D,%E * r0,r1 -> %D,%E  (32 bit multiplication, lower 32 bits are stored. %E is the upper word.)
2 - 1,0,0,1, - r0 / r1 -> r0 , r0 % r1 -> r1   (% is the remainder of the division)
2 - 1,0,1,0, - call to address at r0,r1 (must be aligned to word boundry)
2 - 1,0,1,1, - ret
2 - 1,1,0,0, - memory read byte into lower byte of r0 at %D,r1  (upper byte of r0 is set to 0)
2 - 1,1,0,1, - memory write byte in  lower byte of r0 at %D,r1  (upper byte of r0 is effectively ignored, however it should be 0)
2 - 1,1,1,0, - jump to r0,r1 (must be aligned to word boundry)
2 - 1,1,1,1, - SP - r0 -> r0 , then r0 -> SP
"""

assemblerInstructions={}
assemblerMemoryPreliminaryData={}
assemblerMemoryData={}
assemblerMemoryLocations={}
assemblerLabelLocations={}
walkingPointer=-1

def a_t0(dataIn):
	d={
	'LDLO':'0'+dataIn[2]+dataIn[1],
	'LDUP':'1'+dataIn[2]+dataIn[1]
	}
	r=d[dataIn[0]]
	assert len(r)==4
	return r

def a_t1(dataIn):
	d={
	'AND' :'4'+dataIn[3]+dataIn[2]+dataIn[1],
	'OR'  :'5'+dataIn[3]+dataIn[2]+dataIn[1],
	'XOR' :'6'+dataIn[3]+dataIn[2]+dataIn[1],
	'SSUB':'7'+dataIn[3]+dataIn[2]+dataIn[1],
	'MREW':'8'+dataIn[3]+dataIn[2]+dataIn[1],
	'MWRW':'9'+dataIn[3]+dataIn[2]+dataIn[1],
	'ADDN':'A'+dataIn[3]+dataIn[2]+dataIn[1],
	'ADDC':'B'+dataIn[3]+dataIn[2]+dataIn[1],
	'SUBN':'C'+dataIn[3]+dataIn[2]+dataIn[1],
	'SUBC':'D'+dataIn[3]+dataIn[2]+dataIn[1],
	'CJMP':'E'+dataIn[3]+dataIn[2]+dataIn[1]
	}
	r=d[dataIn[0]]
	assert len(r)==4
	return r

def a_t2(dataIn):
	if len(dataIn)==2:
		dataIn=dataIn+('',)
	d={
	'PUSH':'F0'+'0'      +dataIn[1],
	'POP' :'F2'+'0'      +dataIn[1],
	'MOV' :'F4'+dataIn[2]+dataIn[1],
	'BSWP':'F5'+dataIn[2]+dataIn[1],
	'SHFT':'F6'+dataIn[2]+dataIn[1],
	'MULS':'F7'+dataIn[2]+dataIn[1],
	'MULL':'F8'+dataIn[2]+dataIn[1],
	'DIVM':'F9'+dataIn[2]+dataIn[1],
	'MREB':'FC'+dataIn[2]+dataIn[1],
	'MWRB':'FD'+dataIn[2]+dataIn[1],
	'AJMP':'FE'+dataIn[2]+dataIn[1],
	'SPSS':'FF'+'0'      +dataIn[1]
	}
	r=d[dataIn[0]]
	assert len(r)==4
	return r

def a_t3(dataIn):
	assert dataIn[0]=='LDFU'
	r=a_t0(['LDUP',dataIn[1],dataIn[2][0:2]])+a_t0(['LDLO',dataIn[1],dataIn[2][2:4]])
	assert len(r)==8
	return r

def a_t4(dataIn):
	assert dataIn[0]=='LDLA'
	if not (dataIn[3] in assemblerLabelLocations.keys()):
		print('Label Error [label "'+dataIn[3]+'" not declared]')
		assert False
	real=assemblerLabelLocations[dataIn[3]]
	r=a_t3(['LDFU',dataIn[2],real[0:4]])+a_t3(['LDFU',dataIn[1],real[4:8]])
	assert len(r)==16
	return r


#assemblerInstructions['instruction']=((arg prefixes),byte size,data generation function)

assemblerInstructions['LDLO']=(('%','$'),2,a_t0) #lower (byte) load
assemblerInstructions['LDUP']=(('%','$'),2,a_t0) #upper (byte) load
assemblerInstructions['LDFU']=(('%','#'),4,a_t3) #full (word) load
assemblerInstructions['LDLA']=(('%','%','@'),8,a_t4) #label load

assemblerInstructions['AND' ]=(('%','%','%'),2,a_t1) #bitwise and
assemblerInstructions['OR'  ]=(('%','%','%'),2,a_t1) #bitwise or
assemblerInstructions['XOR' ]=(('%','%','%'),2,a_t1) #bitwise xor
assemblerInstructions['SSUB']=(('%','%','%'),2,a_t1) #special subtraction
assemblerInstructions['MREW']=(('%','%','%'),2,a_t1) #read  memory word
assemblerInstructions['MWRW']=(('%','%','%'),2,a_t1) #write memory word
assemblerInstructions['ADDN']=(('%','%','%'),2,a_t1) #add normal
assemblerInstructions['ADDC']=(('%','%','%'),2,a_t1) #add (with) carry
assemblerInstructions['SUBN']=(('%','%','%'),2,a_t1) #subtraction normal
assemblerInstructions['SUBC']=(('%','%','%'),2,a_t1) #subtraction carry (only)
assemblerInstructions['CJMP']=(('%','%','%'),2,a_t1) #conditional jump if(r2 == 0)

assemblerInstructions['PUSH']=(('%',),2,a_t2) #push 1 word to stack
assemblerInstructions['POP' ]=(('%',),2,a_t2) #pop  1 word from stack

assemblerInstructions['MOV' ]=(('%','%'),2,a_t2) #move one register to another
assemblerInstructions['BSWP']=(('%','%'),2,a_t2) #byte swap
assemblerInstructions['SHFT']=(('%','%'),2,a_t2) #single left shift

assemblerInstructions['MULS']=(('%','%'),2,a_t2) #multiply small (16 bits)
assemblerInstructions['MULL']=(('%','%'),2,a_t2) #multiply large (32 bits)
assemblerInstructions['DIVM']=(('%','%'),2,a_t2) #division and modulus (remainder)

assemblerInstructions['MREB']=(('%','%'),2,a_t2) #read  memory byte
assemblerInstructions['MWRB']=(('%','%'),2,a_t2) #write memory byte

assemblerInstructions['AJMP']=(('%','%'),2,a_t2) #absolute (always) jump
assemblerInstructions['SPSS']=(('%',),2,a_t2) #stack pointer subtract (and) set

assemblerMemoryLocations[ 0]=('LDLO','0','00')
assemblerMemoryLocations[ 1]=True
assemblerMemoryLocations[ 2]=('LDLO','1','00')
assemblerMemoryLocations[ 3]=True
assemblerMemoryLocations[ 4]=('LDLO','2','00')
assemblerMemoryLocations[ 5]=True
assemblerMemoryLocations[ 6]=('SPSS','2')
assemblerMemoryLocations[ 7]=True
assemblerMemoryLocations[ 8]=('SPSS','2')
assemblerMemoryLocations[ 9]=True
assemblerMemoryLocations[10]=('LDLO','2','02')
assemblerMemoryLocations[11]=True
assemblerMemoryLocations[12]=('SPSS','2')
assemblerMemoryLocations[13]=True
assemblerMemoryLocations[14]=('LDLA','2','3','00000000')
assemblerMemoryLocations[15]=True

assemblerMemoryLocations[16]=True
assemblerMemoryLocations[17]=True
assemblerMemoryLocations[18]=True
assemblerMemoryLocations[19]=True
assemblerMemoryLocations[20]=True
assemblerMemoryLocations[21]=True
assemblerMemoryLocations[22]=('AJMP','2','3')
assemblerMemoryLocations[23]=True


f=open('boot.asm','r')
assembleFileContentsString=f.read()+'\n'
f.close()
del f

assembleFileContentsList=[]
for ii0p,ii1 in enumerate(assembleFileContentsString.split('\n')):
	ii0=ii0p+1
	ii2=(ii1.split(';')[0]).replace('	',' ').replace('_','').strip(' ').upper()
	if len(ii2)!=0:
		ii3=tuple(filter(lambda x:len(x)!=0,ii2.split(' ')))
		if len(ii3)!=0:
			if walkingPointer==-1 and ii3[0]!='.ORG':
				print('Initial Error [".org" must be used prior to placing instructions/data/label] on line '+str(ii0)+' ~'+ii2+'~')
				assert False
			if ii3[0][0]==':':
				if len(ii3[0][1:])!=8:
					print('Syntax Error [label prefix ":" must take 8 hex digits] on line '+str(ii0)+' ~'+ii2+'~')
					assert False
				if ii3[0][1:] in assemblerLabelLocations.keys():
					print('Label Error [label "'+ii3[1][1:]+'" already declared] on line '+str(ii0)+' ~'+ii2+'~')
					assert False
				p=hex(walkingPointer)[2:]
				while len(p)<8:p='0'+p
				assemblerLabelLocations[ii3[0][1:]]=p
			elif ii3[0][0]=='.':
				if ii3[0]=='.ORG':
					if len(ii3)!=2 or ii3[1][0]!='!':
						print('Syntax Error [".org" takes one argument of "!" prefix] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					if len(ii3[1][1:])!=8:
						print('Syntax Error [prefix "!" must take 8 hex digits] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					walkingPointer=int(ii3[1][1:],base=16)
				elif ii3[0]=='.DATAW':
					if len(ii3)!=2 or ii3[1][0]!='#':
						print('Syntax Error [".dataw" takes one argument of "#" prefix] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					if len(ii3[1][1:])!=4:
						print('Syntax Error [prefix "#" must take 4 hex digits] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					if walkingPointer%2!=0:
						print('Allignment Error [data word attempted to be written at address that is misalligned] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					p=walkingPointer
					if p   in assemblerMemoryLocations.keys():
						print('Overwrite Error [address collision at '+hex(p  )+'] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					if p+1 in assemblerMemoryLocations.keys():
						print('Overwrite Error [address collision at '+hex(p+1)+'] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					assemblerMemoryLocations[p  ]=ii3[1][1:][2:4]
					assemblerMemoryLocations[p+1]=ii3[1][1:][0:2]
					walkingPointer=walkingPointer+2
				elif ii3[0]=='.DATAB':
					if len(ii3)!=2 or ii3[1][0]!='$':
						print('Syntax Error [".datab" takes one argument of "$" prefix] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					if len(ii3[1][1:])!=2:
						print('Syntax Error [prefix "$" must take 2 hex digits] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					p=walkingPointer
					if p   in assemblerMemoryLocations.keys():
						print('Overwrite Error [address collision at '+hex(p  )+'] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					assemblerMemoryLocations[p  ]=ii3[1][1:]
					walkingPointer=walkingPointer+1
				else:
					print('Syntax Error [unknown directive] on line '+str(ii0)+' ~'+ii2+'~')
					assert False
			else:
				if not (ii3[0] in assemblerInstructions.keys()):
					print('Syntax Error [unknown instruction] on line '+str(ii0)+' ~'+ii2+'~')
					assert False
				if len(ii3[1:])!=len(assemblerInstructions[ii3[0]][0]):
					print('Syntax Error [invalid number of arguments] on line '+str(ii0)+' ~'+ii2+'~')
					assert False
				args=[]
				for ii4 in range(len(ii3[1:])):
					p=ii3[1:][ii4][0]
					if p!=assemblerInstructions[ii3[0]][0][ii4]:
						print('Syntax Error [invalid prefix] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					arg=ii3[1:][ii4][1:]
					if p=='%' and len(arg)!=1:
						print('Syntax Error [prefix "%" must take 1 hex digit] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					if p=='$' and len(arg)!=2:
						print('Syntax Error [prefix "$" must take 2 hex digits] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					if p=='#' and len(arg)!=4:
						print('Syntax Error [prefix "#" must take 4 hex digits] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					if p=='!' and len(arg)!=8:
						print('Syntax Error [prefix "!" must take 8 hex digits] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					if p=='@' and len(arg)!=8:
						print('Syntax Error [prefix "@" must take 8 hex digits] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					args.append(arg)
				if walkingPointer%2!=0:
					print('Allignment Error [instruction attempted to be written at address that is misalligned] on line '+str(ii0)+' ~'+ii2+'~')
					assert False
				for ii4 in range(assemblerInstructions[ii3[0]][1]):
					p=ii4+walkingPointer
					if p in assemblerMemoryLocations.keys():
						print('Overwrite Error [address collision at '+hex(p)+'] on line '+str(ii0)+' ~'+ii2+'~')
						assert False
					assemblerMemoryLocations[p]=True
				assemblerMemoryLocations[walkingPointer]=tuple([ii3[0]]+args)
				walkingPointer=walkingPointer+assemblerInstructions[ii3[0]][1]


assemblerCacheWayInfo=[[-1,-1,-1,-1] for x in range(2 ** 9)]

for ii0 in assemblerMemoryLocations.keys():
	addressLow=ii0 % 16
	addressMiddle=(ii0 // 16) % (2 ** 9)
	addressUpper=(ii0 // 16) // (2 ** 9)
	placed=False
	for ii1 in range(4):
		if not placed:
			if assemblerCacheWayInfo[addressMiddle][ii1]==addressUpper:
				placed=True
			elif assemblerCacheWayInfo[addressMiddle][ii1]==-1:
				placed=True
				assemblerCacheWayInfo[addressMiddle][ii1]=addressUpper
	if not placed:
		print('Cache Error [cache cannot hold entire "boot.asm" file, either due to the 4 way association limit or the cache is not large enough]')
		assert False

for ii0 in assemblerMemoryLocations.keys():
	item=assemblerMemoryLocations[ii0]
	if item!=True:
		if type(item)==type(''):
			assemblerMemoryPreliminaryData[ii0]=item
		else:
			assert type(item)==type(tuple([]))
			data=((assemblerInstructions[item[0]][2])(item))[::-1]
			assert len(data)==2*assemblerInstructions[item[0]][1]
			for ii1 in range(assemblerInstructions[item[0]][1]):
				assemblerMemoryPreliminaryData[ii0+ii1]=data[ii1*2+1]+data[ii1*2+0]

assert sorted(assemblerMemoryPreliminaryData.keys())==sorted(assemblerMemoryLocations.keys())

for ii0 in assemblerMemoryPreliminaryData.keys():
	addressLow=ii0 % 16
	addressMiddle=(ii0 // 16) % (2 ** 9)
	addressUpper=(ii0 // 16) // (2 ** 9)
	placed=False
	for ii1 in range(4):
		if not placed:
			if assemblerCacheWayInfo[addressMiddle][ii1]==addressUpper:
				placed=True
				assemblerMemoryData[((ii1*(2**9))+addressMiddle)*16+addressLow]=assemblerMemoryPreliminaryData[ii0]
	assert placed

for ii0 in assemblerMemoryPreliminaryData.keys():
	addressLow=ii0 % 16
	addressMiddle=(ii0 // 16) % (2 ** 9)
	addressUpper=(ii0 // 16) // (2 ** 9)
	for ii1 in range(4):
		if assemblerCacheWayInfo[addressMiddle][ii1]!=-1:
			for ii2 in range(16):
				if not (((ii1*(2**9))+addressMiddle)*16+ii2 in assemblerMemoryData.keys()):
					assemblerMemoryData[((ii1*(2**9))+addressMiddle)*16+ii2]='00'

for ii0 in range(4):
	for ii1 in range(2**9):
		ii2=0
		while ii2 in assemblerCacheWayInfo[ii1]:ii2=ii2+1
		if assemblerCacheWayInfo[ii1][ii0]==-1:
			assemblerCacheWayInfo[ii1][ii0]=ii2




outFileList=[]

outFileList.append("DEPTH = 2048; % DEPTH is the number of addresses %")
outFileList.append("WIDTH = 128;  % WIDTH is the number of bits of data per word %")
outFileList.append("% DEPTH and WIDTH should be entered as decimal numbers %")
outFileList.append("ADDRESS_RADIX = HEX;")
outFileList.append("DATA_RADIX = HEX; % Enter BIN, DEC, HEX, OCT, or UNS; %")

outFileList.append("CONTENT")
outFileList.append("BEGIN")
#for ii0 in range(2048):
#	tt0=[]
#	for ii1 in range(8):
#		tt0.append(hex(ii1%2)[2:].upper())
#	for ii1 in range(8):
#		for ii2 in range(4):
#			if len(tt0[ii1])!=4:
#				assert len(tt0[ii1])<4
#				tt0[ii1]='0'+tt0[ii1]
#	outFileList.append(""+hex(ii0)[2:].upper()+": "+''.join(tt0)+";")

for ii0 in sorted(filter(lambda x:x%16==0,assemblerMemoryData.keys())):
	acc=''
	for ii1 in range(16)[::-1]:
		acc+=assemblerMemoryData[ii0+ii1]
	outFileList.append(hex(ii0 // 16)[2:].upper()+":"+acc.replace(' ','')+";")


#outFileList.append(hex(0)[2:].upper()+":"+"A755 A755 A755 A755 A755 A675 0016 0017".replace(' ','')+";")

#outFileList.append(hex(1)[2:].upper()+":"+"FE89 1008 0008 1009 0009 0000 0000 0000".replace(' ','')+";")



outFileList.append("END;")

f=open('InitCacheData.mif','w')
f.write('\n'+'\n'.join(outFileList)+'\n')
f.close()
del f

for ii0 in range(4):
	acc='''DEPTH = 512; % DEPTH is the number of addresses %
WIDTH = 13;  % WIDTH is the number of bits of data per word %
% DEPTH and WIDTH should be entered as decimal numbers %
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX; % Enter BIN, DEC, HEX, OCT, or UNS; %

CONTENT
BEGIN
'''.split('\n')
	for ii1 in range(2**9):
		acc.append(hex(ii1)[2:].upper()+":"+hex(assemblerCacheWayInfo[ii1][ii0])[2:].upper()+";")
	acc.append("END;")
	f=open('InitWay'+str(ii0)+'.mif','w')
	f.write('\n'+'\n'.join(acc)+'\n')
	f.close()
	del f

print('AutoGen.py : Success')


