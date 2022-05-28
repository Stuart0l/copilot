conc=( 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 )
LOGFILE="./log.txt"
for i in "${conc[@]}"
do
    client=$i
    ./batch_op.sh kill
    cmd="follower/startexpt0.sh copilot 3 $client 4 60 test_$client > ./log/log_$client.log 2>&1"
    echo $cmd >> $LOGFILE
    eval "$cmd"
    cp result0_3.csv ./log/results0_3_$client.csv
    cp -r experiments ./log/experiments-$client
    sleep 3
done