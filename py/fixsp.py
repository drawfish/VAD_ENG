#/usr/bin/python
import re
import sys
def fixsp(hmmfile):
    hmm=open(hmmfile,'a+');
    filestr=hmm.read();
    pattern=re.compile(r'~h \"sil\"[\d\D]*?<ENDHMM>\n');
    result=re.findall(pattern,filestr);
    hmm.write(result[0].replace('sil','sp'));
    hmm.close();
    
if __name__=='__main__':
    fixsp(sys.argv[1]);