#/usr/bin/python
import os
import sys
def creatMonophone(hmm0path,monophonefile,hmmpath):
    proto=open('%s/proto'%hmm0path,'r');
    monophone=open(monophonefile,'r');
    vFloor=open('%s/vFloors'%hmm0path,'r');
    
    hmmdef=open('%s/hmmdef'%hmmpath,'w');
    macros=open('%s/macros'%hmmpath,'w');
    
    protolines=proto.readlines();
    protoHead=protolines[:3];
    protoBody=protolines[4:];
    hmmdef.writelines(protoHead);
    for phones in monophone.readlines():
        hmmdef.write('~h \"%s\"\n'%phones[:len(phones)-1]);
        hmmdef.writelines(protoBody);
    monophone.close();
    hmmdef.close();
    
    macros.writelines(protoHead);
    macros.writelines(vFloor.readlines());
    
    proto.close();
    vFloor.close();
    macros.close();

if __name__=='__main__':
    creatMonophone(sys.argv[1],sys.argv[2],sys.argv[3]);    