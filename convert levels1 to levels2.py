
# tcl commands:

# source report_levels_of_logic.tcl
# report_levels_of_logic -setup -greater_than 8 -npaths 2000 -file levels1.txt

f=open('levels1.txt','r')
cl_orig=f.read().split('\n')
f.close()
cl_out=cl_orig[:4]
data_rows=[]
for i,r in enumerate(cl_orig):
	if i>=4 and len(r)!=0 and r[0]==';':
		data_rows.append(r)
data_rows=sorted([tuple([float(v.strip()) for v in r.split(';')[1:3]]+[cl_orig.index(r)]) for r in data_rows])[::-1]
for r in data_rows:
	cl_out.append(cl_orig[r[2]])
f=open('levels2.txt','w')
f.write('\n'.join(cl_out))
f.close()
