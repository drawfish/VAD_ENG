#/usr/bin/python
import re
import sys
import os
def createscp(workdir,wavfile,scpfile,mfccfile):
    wav=open(wavfile,'r');
    scp=open(scpfile,'w');
    mfcc=open(mfccfile,'w');
    pattern=re.compile(r'(/[a-zA-Z]*?){6}');
    pattern2=re.compile(r'\w*\.wav');
    os.system('rm -rf mfcc');
    for line in wav.readlines():
        subres=re.sub(pattern, '%s/mfcc/'%workdir, line);
        scp.write('%s %s'%(line.replace('\n',''),subres.replace('wav','mfc')));
        mfcc.write(subres.replace('wav','mfc'));
        dirpath=re.sub(pattern2, '', subres).replace('\n','');
        os.system('mkdir -p %s'%dirpath);
    wav.close();
    scp.close();
    mfcc.close();

if __name__=='__main__':
    createscp(sys.argv[1], sys.argv[2],sys.argv[3],sys.argv[4]);  