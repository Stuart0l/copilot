# using the script in the depfast to draw figures

setup() {
    echo "setup"
    ./batch_op.sh kill
}

LOGFILE="./log.txt"

experiment1() {
    suffix=_$1
    mkdir -p ./figure6a_copilot$suffix
    rm -rf ./figure6a_copilot$suffix/*

    # number of clients
    # 3 replicas
    clients=( 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 )
    for c in "${clients[@]}"
        client=$c
        ./batch_op.sh kill
        cmd="follower/startexpt0.sh copilot 3 $client 4 60 test_$client > ./log/log_$client.log 2>&1"
        echo $cmd >> $LOGFILE
        eval "$cmd"
        cp result0_3.csv ./log/results0_3_$client.csv
        cp -r experiments ./log/experiments-$client
        sleep 3
    do
    done
}

setup
experiment1 1