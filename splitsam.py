import sys
import re
infile=sys.argv[1]
prefix=sys.argv[2]


with open(infile,'r') as f:
    readin=[line for line in f if '@' not in line]
    
    for i in range(len(readin)):
         readin[i]=re.sub('\t[\*\d]','',readin[i])
         seqname=readin[i].split()[0]
         sequence=readin[i].split()[1]
         #print(readin[i])
         outname=prefix + ".fasta"
         with open(outname, 'w') as o:
              o.write('>'+seqname+'\n')
              o.write(sequence+'\n')


print(readin[0])
print(type(readin[1]))
print(readin[0].split()[0])

    # # for i in readin:
    #     data=i.split('\t')
    #     with open("{}_{}.fasta".format(outfile,i),'w')as o:
            
    #         o.write(i)