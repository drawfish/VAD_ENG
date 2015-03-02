#/usr/bin/python
#coding:"utf-8"
import re
import os
import sys
def createWorldMlf(wavfilePath,mlfName):
    key_value={'0':0,'1':1,'2':2,'3':3,'4':4,'5':5,'6':6,'7':7,'8':8,'9':9, \
               'A':10,'B':11,'C':12,'D':13,'E':14,'F':15,'G':16,'H':17,'I':18, \
               'J':19,'K':20,'L':21,'M':22,'N':23,'O':24,'P':25,'Q':26,'R':27,\
               'S':28,'T':29,'U':30,'V':31,'W':32,'X':33,'Y':34,'Z':35};
    os.system(r"rm -f ./wordLev.mlf");
    wavfile=open("%s"%wavfilePath,'r');
    wordLevMlf=open("%s"%mlfName,'w');
    wordLevMlf.write("#!MLF!#\n");
    lines=wavfile.readlines();
    for line in lines:
        pattern=re.compile(r"[0-9A-Z]*?\.wav\n");
        match=pattern.findall(line);
        if match:
            wavfileName=match[0];
            wavName=wavfileName.replace(".wav\n","");
            wordLevMlf.write("\"*/"+wavName+".lab\"\n");
            scriptfileName=line.replace(wavfileName,wavName[:len(wavName)-2]+"00.DOT");
            OffSet=wavName[len(wavName)-2:len(wavName)];
            scriptLines=open(scriptfileName).readlines();
            script=scriptLines[key_value[OffSet[0]]*36+key_value[OffSet[1]]-1];
            wavScriptMlf=script.upper().replace(" (%s)"%wavName,'').split(' ');
            for word in wavScriptMlf:
                wordLevMlf.write('W\n');
            wordLevMlf.write('.\n');
    wordLevMlf.close();
    wavfile.close();
    print "create word level MLF finish.";
if __name__=='__main__':
    createWorldMlf(sys.argv[1], sys.argv[2]);
    