#!/bin/bash

set -e      # Stop on errors
#set -x      # Print commands before they are run

descrip="perfect new data c= 0.1 (default), 4 folds, normalized features"
#method=sum1.IP
if [ "$1" = "" ]; then
    c=0.1
    echo "Using default c value: $c"
else
    c="$1"
    echo "Using overridden c value: $c"
fi
e=0.01
w=3
pid=(0 0 0 0)
suffix=c$c.e$e.w$w
modelFile=model.$suffix

for i in `seq 1 4`; do
    modelFolder=fold$i/models
    echo "out.$method.$modelFile" >> fold$i/lastout.txt
    sh run_svm.sh $c $e $i $modelFile $modelFolder $suffix $w &
    p=$!
    pid[$i]=$p
done 
  
ps
echo ${pid[1]},${pid[2]},${pid[3]},${pid[4]} 
wait ${pid[1]}
wait ${pid[2]}
wait ${pid[3]}
wait ${pid[4]} 
echo "processes completed!"
perl get_avg_pr.pl out.$modelFile > avg_pr.$modelFile
method=$suffix.$cmethod
perl get_confusion_matrix.pl .  > confusionM.$method

rm -f runinfo
echo $HOSTNAME >> runinfo
pwd >> runinfo

echo "description: $descrip" >> runinfo
echo "method : $method" >> runinfo
echo "loss: $loss" >> runinfo

echo "errors:" >> runinfo
echo >> errfile    # make sure the file exists
cat errfile >> runinfo
rm -f errfile

echo "" >> runinfo
echo "~~~~~~~~~~~~~~~" >> runinfo
echo "" >> runinfo
echo "" >> runinfo
cat avg_pr* >> runinfo
echo "" >> runinfo
echo "~~~~~~~~~~~~~~~" >> runinfo
echo "" >> runinfo
echo "" >> runinfo
cat confusionM.$method >> runinfo

