import sys
infile=sys.argv[1]
prefix=sys.argv[2]
# newfiles=[]
# with open(str(infile), 'r') as readin:
#     fastin=readin.read().split('>')
#     fastin=        
#     for i in fastin:
#         newfiles.append(i)
#         print(i)
# with open("{0}_{1}.txt".format(str(prefix),str(i)),'w') as output:
#     for i in range(len(fastin)-1):
#         print(i)
#         output.write(newfiles[i]+newfiles[i+1])

        
with open(str(infile), 'r') as readin:
    fastin=readin.read().split('>')
    fastin=fastin[1:]
    fastin=['>'+seq for seq in fastin]
    for i in fastin:
        with open("{0}_{1}.txt".format(str(prefix),str(i.split('\n')[0].replace('>',''))),'w') as output:
            output.write(i)
         
