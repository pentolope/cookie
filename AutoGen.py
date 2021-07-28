from time import time
START_TIME=time()

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
del outFileList

############################################################

from PIL import Image
img = Image.open('(7, 8) font.png').convert('RGB')
default_character=[]
all_characters={}
this_character=[]
outFileList=['''DEPTH = 10240; % DEPTH is the number of addresses %
WIDTH = 16;  % WIDTH is the number of bits of data per word %
% DEPTH and WIDTH should be entered as decimal numbers %
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX; % Enter BIN, DEC, HEX, OCT, or UNS; %

CONTENT
BEGIN''']
default_character.append('0'*8)
for y in range(8):
	default_character.append('0')
	for x in range(7):
		if y==1 or y==6 or x==1 or x==5:
			default_character.append('1')
		else:
			default_character.append('0')
for i in range(256):
	all_characters[i]=''.join(default_character)
for visibleCharPictureIndex in range(95):
	this_character.append('0'*8)
	for y in range(8):
		this_character.append('0')
		for x in range(7):
			pixel = img.getpixel((visibleCharPictureIndex*8+x,y))
			if pixel==(0,0,0):
				this_character.append('1')
			elif pixel==(255,255,255):
				this_character.append('0')
			else:
				raise RuntimeError('invalid value in font picture')
	all_characters[visibleCharPictureIndex+32]=''.join(this_character)
	this_character=[]
img.close()
del img
values={}
font_start=14400#14328
assert ord(' ')==32
for i in range(0,font_start,3):
	values[i+0]=32
	values[i+1]=255
	values[i+2]=0
rain=[
	(2,0,0),
	(2,1,0),
	(2,2,0),
	(1,2,0),
	(0,2,0),
	(0,2,1),
	(0,2,2),
	(0,1,2),
	(0,0,2),
	(1,0,2),
	(2,0,2),
	(2,0,1),
]
c0=[7,3,0]
c1=[3,1,0]
for i,v in enumerate("COOKIE is finding it's recipe..."):
	values[i * 3 + 0]=ord(v)
	t=rain[(i+0)%12]
	t=(c0[t[2]]<<5)+(c0[t[1]]<<2)+(c1[t[0]])
	assert t>=0
	assert t<256
	values[i * 3 + 1]=t
	t=rain[(i+6)%12]
	t=(c0[t[2]]<<5)+(c0[t[1]]<<2)+(c1[t[0]])
	assert t>=0
	assert t<256
	values[i * 3 + 2]=t
for i,v in enumerate("For now, enjoy this font test:"):
	values[(i+160) * 3 + 0]=ord(v)
	values[(i+160) * 3 + 1]=(7<<5) | (7<<2)
	values[(i+160) * 3 + 2]=0
for i,v in enumerate(''.join(map(chr,range(32,127)))):
	values[(i+240) * 3 + 0]=ord(v)
	values[(i+240) * 3 + 1]=7<<2
	values[(i+240) * 3 + 2]=3

for i in range(256):
	assert 8 * 9==len(all_characters[i])
	vb=font_start + 9 * i
	for vi in range(9):
		assert not (vb+vi in values.keys())
		if vb+vi>=20476:
			raise RuntimeError('font doesn\'t fit')
		values[vb+vi]=int(all_characters[i][vi * 8:vi * 8 + 8][::-1],2)
values[20476]=(font_start) & 255
values[20477]=((font_start) >> 8) & 255
values[20479]=6 | 16
for i in sorted(values.keys())[::-1]:
	assert i<20480
	assert i>=0
value_pairs={}
for i in values.keys():
	value_pairs[i >> 1]=[0,0]
for i in values.keys():
	value_pairs[i >> 1][i & 1]=values[i]
for i in value_pairs.keys():
	outFileList.append((hex(i)[2:]+':'+hex((value_pairs[i][1]<<8)|(value_pairs[i][0]))[2:]+';').upper())
outFileList.append('END;')
f=open('InitVGA.mif','w')
f.write('\n'.join(outFileList))
f.close()
del f
del outFileList
del values
del value_pairs

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

def a_tR(dataIn):
	d={
	'RET' :'FB00',
	}
	r=d[dataIn[0]]
	assert len(r)==4
	return r

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
	'CALL':'FA'+dataIn[2]+dataIn[1],
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

assemblerInstructions['RET' ]=(tuple([]),2,a_tR) #ret
assemblerInstructions['CALL']=(('%','%'),2,a_t2) #call

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


assemblerCacheWayInfo=[[-1,-1,-1,-1] for x in range(2 ** 11)]

for ii0 in assemblerMemoryLocations.keys():
	addressLow=ii0 % 16
	addressMiddle=(ii0 // 16) % (2 ** 11)
	addressUpper=(ii0 // 16) // (2 ** 11)
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
	addressMiddle=(ii0 // 16) % (2 ** 11)
	addressUpper=(ii0 // 16) // (2 ** 11)
	placed=False
	for ii1 in range(4):
		if not placed:
			if assemblerCacheWayInfo[addressMiddle][ii1]==addressUpper:
				placed=True
				assemblerMemoryData[((ii1*(2**11))+addressMiddle)*16+addressLow]=assemblerMemoryPreliminaryData[ii0]
	assert placed

for ii0 in assemblerMemoryPreliminaryData.keys():
	addressLow=ii0 % 16
	addressMiddle=(ii0 // 16) % (2 ** 11)
	addressUpper=(ii0 // 16) // (2 ** 11)
	for ii1 in range(4):
		if assemblerCacheWayInfo[addressMiddle][ii1]!=-1:
			for ii2 in range(16):
				if not (((ii1*(2**11))+addressMiddle)*16+ii2 in assemblerMemoryData.keys()):
					assemblerMemoryData[((ii1*(2**11))+addressMiddle)*16+ii2]='00'

for ii0 in range(4):
	for ii1 in range(2**11):
		ii2=0
		while ii2 in assemblerCacheWayInfo[ii1]:ii2=ii2+1
		if assemblerCacheWayInfo[ii1][ii0]==-1:
			assemblerCacheWayInfo[ii1][ii0]=ii2




outFileList=[]

outFileList.append("DEPTH = 8192; % DEPTH is the number of addresses %")
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
	acc='''DEPTH = 2048; % DEPTH is the number of addresses %
WIDTH = 13;  % WIDTH is the number of bits of data per word %
% DEPTH and WIDTH should be entered as decimal numbers %
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX; % Enter BIN, DEC, HEX, OCT, or UNS; %

CONTENT
BEGIN
'''.split('\n')
	for ii1 in range(2**11):
		acc.append(hex(ii1)[2:].upper()+":"+hex(assemblerCacheWayInfo[ii1][ii0])[2:].upper()+";")
	acc.append("END;")
	f=open('InitWay'+str(ii0)+'.mif','w')
	f.write('\n'+'\n'.join(acc)+'\n')
	f.close()
	del f

print('AutoGen.py : Success [Took '+str(time()-START_TIME)+' Seconds]')


