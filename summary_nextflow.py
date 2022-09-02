import sys

allfiles=sys.argv[1:-1]
csvfile=sys.argv[-1]
# # my solution with output directly as writing csv here
with open("{}.csv".format(csvfile),'w') as outfile:
    firstline="Sequence Number"+","+"Number Of Reapeats\n"
    outfile.write(firstline)
    for i in allfiles:
        seqname=i.split('_')[1]
        with open(i,'r') as infile:
            repnum=infile.read()
        lines=seqname+','+repnum
        outfile.write(lines)

# p.w.dabrowski solution with python just printing output and then piping that into csv
# print("# Sequence number, Number of repeats")
# for filename in allfiles:
#     seqnum = filename.split("_")[1]
#     with open(filename, "r") as f:
#         repnum = f.read()
#     print(seqnum + "," + repnum.strip())
