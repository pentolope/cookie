

dataTransitionString="""
8.923	8.942
8.479	8.579
8.598	8.586
8.513	8.607
8.648	8.713
8.906	8.942
8.495	8.525
8.417	8.503
8.530	8.561
8.517	8.570
8.649	8.587
8.464	8.446
8.421	8.471
8.923	8.860
8.709	8.639
8.709	8.639
8.563	8.616
8.537	8.536
8.820	8.883
8.774	8.752
8.541	8.550
8.397	8.450
8.496	8.548
8.540	8.524
8.669	8.719
8.783	8.740
8.686	8.670
8.750	8.788
8.458	8.534
8.583	8.715
8.586	8.794
8.599	8.614
8.704	8.831
8.820	8.883
8.800	8.701
8.527	8.519
8.393	8.391
8.561	8.545
8.444	8.327

4.133	4.445
4.191	4.547
4.234	4.564
4.215	4.569
4.235	4.598
4.397	4.768
4.155	4.494
4.161	4.509
4.179	4.509
4.170	4.517
4.232	4.545
4.133	4.445
4.156	4.491
4.383	4.707
4.234	4.582
4.264	4.582
4.234	4.587
4.534	4.205
4.178	4.513
4.318	4.667
4.223	4.560
4.178	4.513
4.215	4.569
4.228	4.554
4.289	4.639
4.318	4.661
4.292	4.630
4.282	4.647
4.203	4.550
4.335	4.723
4.357	4.770
4.236	4.573
4.381	4.775
4.387	4.757
4.357	4.654
"""

clkTransitionString="""

1.299 1.323

2.302 2.205

"""

setupFpgaString="""
2.200	2.453
1.441	1.630
1.433	1.622
1.384	1.572
2.200	2.453
1.426	1.615
1.437	1.627
1.413	1.602
1.441	1.631
1.401	1.593
1.714	1.912
1.637	1.829
1.381	1.570
1.714	1.912
1.695	1.891
1.718	1.917
1.681	1.875

0.845	1.396
0.478	0.968
0.472	0.961
0.427	0.914
0.845	1.396
0.467	0.955
0.474	0.964
0.463	0.948
0.477	0.966
0.434	0.924
0.601	1.114
0.553	1.058
0.429	0.918
0.600	1.111
0.598	1.104
0.604	1.115
0.589	1.094
"""

holdFpgaString="""

-0.353	-0.834
-0.405	-0.888
-0.400	-0.881
-0.353	-0.834
-0.754	-1.295
-0.394	-0.876
-0.401	-0.884
-0.390	-0.868
-0.405	-0.887
-0.361	-0.844
-0.522	-1.026
-0.474	-0.971
-0.355	-0.837
-0.519	-1.022
-0.517	-1.016
-0.524	-1.027
-0.509	-1.007

-1.179	-1.361
-1.241	-1.423
-1.233	-1.415
-1.182	-1.363
-1.967	-2.207
-1.226	-1.408
-1.236	-1.420
-1.214	-1.396
-1.242	-1.426
-1.200	-1.386
-1.500	-1.691
-1.424	-1.610
-1.179	-1.361
-1.499	-1.690
-1.482	-1.671
-1.503	-1.696
-1.468	-1.655
"""

scale=7#30

def t0(v0):
    return ' '.join(filter(lambda x:len(x)!=0,v0.replace('\t',' ').replace('\n',' ').split(' ')))

def t1(v0):
    v1=[int(round(float(v2)*scale)) for v2 in v0.split(' ')]
    return (min(v1),max(v1))

dataTransitionMin,dataTransitionMax=t1(t0(dataTransitionString))
clkTransitionMin, clkTransitionMax =t1(t0(clkTransitionString))
setupFpgaMin,setupFpgaMax=t1(t0(setupFpgaString))
holdFpgaMin,holdFpgaMax=t1(t0(holdFpgaString))


def g0(v0):
    v1=v0.replace('.','').replace('x','')
    return v1[-1]

s0='0'
s1='0'
s2='0'
s3='0'
s4='0'
s5='3'
s6='9'
s7='9'
s8='9'

p=int(round(float(11.1111111111111111)*scale))
p2=int(round(float(11.1111111111111111/2)*scale))


print([dataTransitionMin,dataTransitionMax,clkTransitionMin, clkTransitionMax ])
print([p2,p,int(round(float(11.1111111111111111*3)*scale))+7])
print('\n\n')


rt=range(int(round(float(11.1111111111111111*3)*scale))+7)
for t in rt:
    tp=t%p
    tp2=t%p2
    l0=g0(s0)
    l1=g0(s1)
    l2=g0(s2)
    l3=g0(s3)
    l4=g0(s4)
    l5=g0(s5)
    n0='.'
    n1='.'
    n2='.'
    n3='.'
    n4='.'
    n5=l5
    if s5[-1]=='x':n5=str(int(n5)+1)
    assert len(n5)==1
    if tp2==0:
        if l0=='0':n0='1'
        if l0=='1':n0='0'
    if tp2==clkTransitionMin:
        if l0=='0':n1='0'
        if l0=='1':n1='1'
        if l0=='0':n2='0'
        if l0=='1':n3='1'
    if tp2==clkTransitionMax:
        if l0=='0':n4='0'
        if l0=='1':n4='1'
        if l0=='0':n3='0'
        if l0=='1':n2='1'
    if tp>=dataTransitionMin and tp<=dataTransitionMax:
        n5='x'
    s0+=n0
    s1+=n1
    s2+=n2
    s3+=n3
    s4+=n4
    if n5==l5 and (s5[-1]=='.' or s5[-1]==n5):s5+='.'
    else:s5+=n5
    s6+='x'
    s7+='2'
    s8+='x'

for ti,t in enumerate(rt):
    b1=t-(-int(round(float(1.5)*scale)))
    b0=t-(+int(round(float(.8)*scale)))
    assert b0<=b1
    if b0<rt[0]:bi0=0
    elif b0>rt[-1]:bi0=len(rt)
    else:bi0=b0+1
    if b1<rt[0]:bi1=0
    elif b1>rt[-1]:bi1=len(rt)
    else:bi1=b1+1
    if '1' in s1[bi0:bi1]+s2[bi0:bi1]+s3[bi0:bi1]+s4[bi0:bi1]:
        if ti!=0 and (s6[ti-1]=='2' or s6[ti-1]=='.'):s6=s6[:ti]+'.'+s6[ti+1:]
        else:s6=s6[:ti]+'2'+s6[ti+1:]

for ti,t in enumerate(rt):
    b1=t-int(round(float(2.7)*scale))
    b0=t-int(round(float(5.4)*scale))
    assert b0<=b1
    if b0<rt[0] or b0>rt[-1]:
        s7=s7[:ti]+'0'+s7[ti+1:]
        continue
    else:bi0=b0
    if b1<rt[0] or b1>rt[-1]:
        s7=s7[:ti]+'0'+s7[ti+1:]
        continue
    else:bi1=b1+1
    if '1' in s1[bi0:bi1]+s2[bi0:bi1]+s3[bi0:bi1]+s4[bi0:bi1]:
        s7=s7[:ti]+'x'+s7[ti+1:]

for ti,t in enumerate(rt):
    if ti!=0 and ((s7[ti-1]=='.' or s7[ti-1]=='2') and (s7[ti]=='.' or s7[ti]=='2')):
        s7=s7[:ti]+'.'+s7[ti+1:]

for ti,t in enumerate(rt):
    b1=t-(-setupFpgaMax)
    b0=t-(+holdFpgaMin)
    assert b0<=b1
    if b0<rt[0]:bi0=0
    elif b0>rt[-1]:bi0=len(rt)
    else:bi0=b0+1
    if b1<rt[0]:bi1=0
    elif b1>rt[-1]:bi1=len(rt)
    else:bi1=b1+1
    if '1' in s0[bi0:bi1]:
        if ti!=0 and (s8[ti-1]=='2' or s8[ti-1]=='.'):s8=s8[:ti]+'.'+s8[ti+1:]
        else:s8=s8[:ti]+'2'+s8[ti+1:]

sl0=''
sl1=''
sk0=''
sk1=''
for ti,t in enumerate(rt):
    if s6[ti]!='x' and s6[ti]!='0' and s5[ti]=='x':sl0+='9'
    else:sl0+='0'
    if s8[ti]!='x' and s8[ti]!='0' and s7[ti]=='x':sl1+='9'
    else:sl1+='0'
    sk0+='0'
    sk1+='0'




for ti,t in enumerate(rt):
    if ti!=0:
        if sl0[ti]=='9' and (sk0[ti-1]=='2' or (not (s6[ti-1]!='x' and s6[ti-1]!='0'))):
            assert sk0[ti]=='0'
            sk0=sk0[:ti]+'2'+sk0[ti+1:]
        if sl0[ti]=='9' and (sk0[ti-1]=='3' or (not (s5[ti-1]=='x'))):
            assert sk0[ti]=='0'
            sk0=sk0[:ti]+'3'+sk0[ti+1:]
        if sl1[ti]=='9' and (sk1[ti-1]=='2' or (not (s8[ti-1]!='x' and s8[ti-1]!='0'))):
            assert sk1[ti]=='0'
            sk1=sk1[:ti]+'2'+sk1[ti+1:]
        if sl1[ti]=='9' and (sk1[ti-1]=='3' or (not (s7[ti-1]=='x'))):
            assert sk1[ti]=='0'
            sk1=sk1[:ti]+'3'+sk1[ti+1:]




def rr1(v0,v3):
    v1=v0[::-1]
    while True:
        try:
            v2=v1.index(v3+v3)
            v1=v1[:v2]+'.'+v3+v1[v2+2:]
        except:
            return v1[::-1]
def rr0(v0):
    v1=v0
    for i in range(11):
        v1=rr1(v1,str(i))
    return v1





sl2=rr0(sl0)
sl3=rr0(sl1)
sk2=rr0(sk0)
sk3=rr0(sk1)



fpgaToExternalViolationTimeSteps=max(map(len,sk0.split('0')))
externalToFpgaViolationTimeSteps=max(map(len,sk1.split('0')))

if fpgaToExternalViolationTimeSteps!=0:
    vt0=map(len,sk0.split('0')).index(fpgaToExternalViolationTimeSteps)
    vt1=sk0.split('0')[vt0][0]
    assert vt1=='2' or vt1=='3'
    if vt1=='2':
        print('VIOLATION: fpga->external : estimated maxiumum setup violation of '+str(float(fpgaToExternalViolationTimeSteps)/scale)+'ns ['+str(fpgaToExternalViolationTimeSteps)+' time steps]')
        print(' ')
    else:
        print('VIOLATION: fpga->external : estimated maxiumum hold  violation of '+str(float(fpgaToExternalViolationTimeSteps)/scale)+'ns ['+str(fpgaToExternalViolationTimeSteps)+' time steps]')
        print(' ')
if externalToFpgaViolationTimeSteps!=0:
    vt0=map(len,sk1.split('0')).index(externalToFpgaViolationTimeSteps)
    vt1=sk1.split('0')[vt0][0]
    assert vt1=='2' or vt1=='3'
    if vt1=='2':
        print('VIOLATION: external->fpga : estimated maxiumum setup violation of '+str(float(externalToFpgaViolationTimeSteps)/scale)+'ns ['+str(externalToFpgaViolationTimeSteps)+' time steps]')
        print(' ')
    else:
        print('VIOLATION: external->fpga : estimated maxiumum hold  violation of '+str(float(externalToFpgaViolationTimeSteps)/scale)+'ns ['+str(externalToFpgaViolationTimeSteps)+' time steps]')
        print(' ')




print('\n\n\n')

print("""{signal: [
{name: 'clk_relative', wave: '"""+s0+"""'},
{},
{name: 'clk_min_min', wave: '"""+s1+"""'},
{name: 'clk_min_max', wave: '"""+s2+"""'},
{name: 'clk_max_min', wave: '"""+s3+"""'},
{name: 'clk_max_max', wave: '"""+s4+"""'},
{},
{name: 'data_out_fpga_real', wave: '"""+s5+"""'},
{name: 'data_in_device_expect', wave: '"""+s6+"""'},
{name: 'failure', wave: '"""+sl2+"""'},
{name: 'failure_type', wave: '"""+sk2+"""'},
{},
{name: 'data_out_device_real', wave: '"""+s7+"""'},
{name: 'data_in_fpga_expect', wave: '"""+s8+"""'},
{name: 'failure', wave: '"""+sl3+"""'},
{name: 'failure_type', wave: '"""+sk3+"""'},
]}""")
















