import sys

numfiles=int(len(sys.argv-1)/2)

# # my solution with output directly as writing csv here
with open(,'w') as outfile:
    firstline="Sequence Number, # Startcodons, # Stopcodons\n"
    outfile.write(firstline)
    for i in range(len): 
        seqname=i.split('_')[1]
        with open(i,'r') as infile:
            repnum=infile.read()
        lines=seqname+','+repnum
        outfile.write(lines)
