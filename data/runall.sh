./main $1 $2 > $1-$2.txt

done=`cat $1-$2.txt | tail -1`

if [ "$done" == "\"done!\"" ]
then
    echo "done!"
else
    done=`echo "${done//\"}"`
    last=`echo $done | cut -d \  -f 2`
    echo "trying again... $last $2"
    ./runall.sh $last $2
fi
