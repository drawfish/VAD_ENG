#/usr/bin/python
import re
import sys

def hhedfix(hmmfile):
    hmm=open(hmmfile,'r');
    silfix=0;
    transRow=0;
    rowFix=0;
    lines=hmm.readlines();
    hmm.close();
    pattern=re.compile(r' [0\.e+]* ');
    for line in lines:
        rowFix+=1;
        if line.find("~h \"sil\"")!=-1:
            silfix=1;
        if line.find('<TRANSP>')!=-1 and silfix==1:
            transRow=1;
        if transRow!=0:
            transRow+=1;
        if transRow==3:
            lines[rowFix+1]=re.sub(pattern, ' 2.000000e-01 ',lines[rowFix+1]);
            rowFix=0;
            silfix=0;
            transRow=0;
    hmm=open(hmmfile,'wt');
    hmm.writelines(lines);
    hmm.close();
    
if __name__=='__main__': 
    hhedfix(sys.argv[1]);
    