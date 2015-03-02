#usr/bin/python
#Designed by Duisheng.Chen @ SCUT NGHCI
#Replace all the phones in the dictionary with w
import re
import sys
import os
def creatDict(dictpath):
    os.system('rm %s/dictw.dic'%dictpath);
    os.system('rm %s/dictsilspw.dic'%dictpath);
    dict=open('%s/dict.dic'%dictpath,'r');
    dictw=open('%s/dictw.dic'%dictpath,'w');
    
    pattern=re.compile(r'[a-z \t]*?\n');
    for line in dict.readlines():
        if line.find('sil')==-1:
            subres=re.sub(pattern, '\t\tw\n', line);
            dictw.write(subres);
        else :
            dictw.write(line);
    dict.close();
    dictw.close();
    
    dictw=open('%s/dictw.dic'%dictpath,'r');
    dictsilspw=open('%s/dictsilspw.dic'%dictpath,'w');
    
    pattern1=re.compile(r'[a-z \t]*?\n');
    for line in dictw.readlines():
        if line.find('sil')==-1:
            subres=re.sub(pattern1,'\t\tw sp\n',line);
            dictsilspw.write(subres);
            dictsilspw.write(subres.replace('sp','sil'));
        else :
            dictsilspw.write(line);
    dictsilspw.write('silence\t\tsil\n');
    dictsilspw.close();
    
if __name__=='__main__':
    creatDict(sys.argv[1]);