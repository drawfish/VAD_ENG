#/bin/bash
source ../setting
rm -rf $WORKDIR/log
rm -rf $WORKDIR/path/train*
rm -rf $WORKDIR/mlf
rm -rf $HMMDIR/hmm*
rm -rf $WORKDIR/mixuphed
rm -rf $HMMDIR/mix*
rm -rf $WORKDIR/mfcc/*
mkdir $WORKDIR/log
mkdir $WORKDIR/mlf
echo 'Create dictionary.'
python $WORKDIR/py/dictionary.py $DICTDIR >> $WORKDIR/log/dict.log
echo 'Creat word level mlf.'
find $TRAINFILEPATH -name *.wav >> $WORKDIR/path/trainwavfile.path
python $WORKDIR/py/wordLevMlf.py $WORKDIR/path/trainwavfile.path $WORKDIR/mlf/wordlev.mlf
echo 'Creat phone level mlf.'
$HTKTOOL/HLEd -A -D -T 1 -l '*' -d $WORKDIR/dictionary/dictw.dic \
								-i $WORKDIR/mlf/phonelev.mlf $WORKDIR/led/mkphone.led $WORKDIR/mlf/wordlev.mlf \
								>> $WORKDIR/log/HLEd.log								
echo 'Coding data.'
python $WORKDIR/py/creatscp.py  $WORKDIR \
								$WORKDIR/path/trainwavfile.path \
								$WORKDIR/path/traincodescp.path \
								$WORKDIR/path/trainmfccfile.path
$HTKTOOL/HCopy -A -D -T 1 -C $WORKDIR/config/INPUTFORMAT.conf \
												  -C $WORKDIR/config/MFCC.conf \
												 -S $WORKDIR/path/traincodescp.path \
												 >> $WORKDIR/log/HCopy.log
echo 'Building Monophone HMMs.'
mkdir $HMMDIR/hmm0
$HTKTOOL/HCompV -A -D -T 1 -C $WORKDIR/config/MFCC.conf \
												-f 0.01 \
												-m -S $WORKDIR/path/trainmfccfile.path \
												-M $HMMDIR/hmm0 $HMMDIR/proto \
												>> $WORKDIR/log/HCompV.log
											
python $WORKDIR/py/creatmonophone.py $HMMDIR/hmm0 \
									 $WORKDIR/monophone/monophone.pl \
									 $HMMDIR/hmm0
echo 'Training the model.'
for ((i=1;i<=4;i++))
do
	mkdir $HMMDIR/hmm$i
	$HTKTOOL/HERest -A -C $WORKDIR/config/MFCC.conf \
					-I $WORKDIR/mlf/phonelev.mlf \
					-t 250.0 150.0 1000.0 \
					-S $WORKDIR/path/trainmfccfile.path \
					-H $HMMDIR/hmm$((i-1))/macros -H $HMMDIR/hmm$((i-1))/hmmdef \
					-M $HMMDIR/hmm$i $WORKDIR/monophone/monophone.pl \
					>> $WORKDIR/log/HERest.log
done
$HTKTOOL/HHEd -H $HMMDIR/hmm4/hmmdef -H $HMMDIR/hmm4/macros \
			-w $HMMDIR/hmm4/RMF /dev/null $WORKDIR/monophone/monophone.pl
echo 'Add the sp model'
python $WORKDIR/py/fixsp.py $HMMDIR/hmm4/RMF 
mkdir $HMMDIR/hmm5
$HTKTOOL/HHEd -H $HMMDIR/hmm4/RMF -w $HMMDIR/hmm5/RMF \
			$WORKDIR/hed/sil.hed $WORKDIR/monophone/monophonesilsp.pl
#python $WORKDIR/py/hhedfix.py $HMMDIR/hmm5/RMF
echo 'Create phone level sp&sil mlf.'
$HTKTOOL/HLEd -A -D -T 1 -l '*' -d $WORKDIR/dictionary/dictsilspw.dic \
								-i $WORKDIR/mlf/phonelevsilsp.mlf $WORKDIR/led/mkphonesilsp.led $WORKDIR/mlf/wordlev.mlf \
								>> $WORKDIR/log/HLEd.log
echo 'HMM training the model.'
for ((i=6;i<=7;i++))
do 
	mkdir $HMMDIR/hmm$i
	$HTKTOOL/HERest -A -D -T 1 -C $WORKDIR/config/MFCC.conf \
					-I $WORKDIR/mlf/phonelevsilsp.mlf \
					-t 250.0 150.0 1000.0 \
					-S $WORKDIR/path/trainmfccfile.path \
					-H $HMMDIR/hmm$((i-1))/RMF \
					-M $HMMDIR/hmm$i $WORKDIR/monophone/monophonesilsp.pl >> $WORKDIR/log/HERest.log				
done
echo 'Fource alignment.'
$HTKTOOL/HVite -A -D -T 1 -l '*' -o SWT -b silence -C $WORKDIR/config/MFCC.conf \
			-a -H $HMMDIR/hmm7/RMF -i $WORKDIR/mlf/aligned.mlf \
			-m -t 250.0 -y lab -I $WORKDIR/mlf/wordlev.mlf \
			-S $WORKDIR/path/trainmfccfile.path $DICTDIR/dictsilspw.dic \
			$WORKDIR/monophone/monophonesilsp.pl \
			>>$WORKDIR/log/HVite.log
echo 'Fix aligned mlf.'
$HTKTOOL/HLEd -A -D -T 1 -l '*' \
			-i $WORKDIR/mlf/alignedfix.mlf \
			$WORKDIR/led/fixaligned.led \
			$WORKDIR/mlf/aligned.mlf \
			>>$WORKDIR/log/HLed.log

echo 'HMM training the model.'
for ((i=8;i<=9;i++))
do 
	mkdir $HMMDIR/hmm$i
	$HTKTOOL/HERest -A -D -T 1 -C $WORKDIR/config/MFCC.conf \
					-I $WORKDIR/mlf/alignedfix.mlf \
					-t 250.0 150.0 1000.0 \
					-S $WORKDIR/path/trainmfccfile.path \
					-H $HMMDIR/hmm$((i-1))/RMF \
					-M $HMMDIR/hmm$i $WORKDIR/monophone/monophonesilsp.pl \
					>> $WORKDIR/log/HERest.log				
done
echo 'Mix up.'
mkdir $WORKDIR/mixuphed
python $WORKDIR/py/mixupstep.py $WORKDIR/config/mixstep.conf $WORKDIR/mixuphed
mkdir -p $HMMDIR/mix0/hmm4
cp $HMMDIR/hmm9/RMF $HMMDIR/mix0/hmm4/
preline='0'
while read line
do	
	echo 'Mix up '$HMMDIR/mix$line
	mkdir -p $HMMDIR/mix$line/hmm0/
	$HTKTOOL/HHEd  -A -D -T 1 -w $HMMDIR/mix$line/hmm0/RMF \
				 -H $HMMDIR/mix$preline/hmm4/RMF \
					$WORKDIR/mixuphed/mixupstep$line.hed \
					$WORKDIR/monophone/monophonesilsp.pl \
					>>$WORKDIR/log/HHEd.log
	for ((i=1;i<=4;i++))
	do
		mkdir $HMMDIR/mix$line/hmm$i
		echo 'Training the model '$HMMDIR/mix$line/hmm$i
		$HTKTOOL/HERest -A -D -T 1 -C $WORKDIR/config/MFCC.conf \
						-H $HMMDIR/mix$line/hmm$((i-1))/RMF \
						-I $WORKDIR/mlf/alignedfix.mlf \
						-S $WORKDIR/path/trainmfccfile.path \
						-M $HMMDIR/mix$line/hmm$i $WORKDIR/monophone/monophonesilsp.pl \
						>> $WORKDIR/log/HERest.log
	done
	preline=$line
done < $WORKDIR/config/mixstep.conf
mkdir $HMMDIR/hmm10
cp $HMMDIR/mix$preline/hmm4/RMF $HMMDIR/hmm10
rm -rf $HMMDIR/mix*
echo 'Trainning the VAD model finish.'		

	
		
	