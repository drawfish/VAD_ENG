#/bin/bash
source ./setting
rm -rf $WORKDIR/path/test*

echo 'Find test file.'
find $TESTFILEPATH -name *.wav >> $WORKDIR/path/testwavfile.path
python $WORKDIR/py/testwordLevMlf.py $WORKDIR/path/testwavfile.path $WORKDIR/mlf/testwordlev.mlf
echo 'Coding data.'
python $WORKDIR/py/creatscp.py  $WORKDIR \
								$WORKDIR/path/testwavfile.path \
								$WORKDIR/path/testcodescp.path \
								$WORKDIR/path/testmfccfile.path
$HTKTOOL/HCopy -A -D -T 1 -C $WORKDIR/config/INPUTFORMAT.conf \
												  -C $WORKDIR/config/MFCC.conf \
												-S $WORKDIR/path/testcodescp.path \
												>> $WORKDIR/log/HCopy.log
echo 'Generate word network.'
$HTKTOOL/HParse $WORKDIR/Net/Gram.net $WORKDIR/Net/wdnet.net
echo 'Test start.'
$HTKTOOL/HVite -A -D -T 1 -b silence -H $HMMDIR/hmm10/RMF \
			 -S $WORKDIR/path/testmfccfile.path \
			-l '*' -i recout.mlf -m -t 250 -y lab -I $WORKDIR/mlf/testwordlev.mlf \
			 -p 0.0 -s 5.0 $DICTDIR/test.dict $WORKDIR/monophone/monophonesilsp.pl
			
			