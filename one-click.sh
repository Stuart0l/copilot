# using the script in the depfast to draw figures

setup() {
    echo "setup"
    ./batch_op.sh kill
}

LOGFILE="./log.txt"
echo "" > LOGFILE

experiment1() {
    suffix=_$1
    logF="./log-5"
    mkdir -p $logF 

    # number of clients
    # 3 replicas
    clients=( 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 )
    for c in "${clients[@]}";
    do
	rm -rf ./experiments/*
        client=$c
        ./batch_op.sh kill
        cmd="follower/startexpt0.sh copilot 5 $client 4 60 test_$client > ./$logF/log_$client.log 2>&1"
        echo $cmd >> $LOGFILE
        eval "$cmd"
        cp result0_5.csv ./$logF/results0_5_$client.csv
        cp -r experiments ./$logF/experiments-$client
        cp outputdir.log ./$logF/outputdir-$client.log
        sleep 3
    done
}

experiment2() {
    suffix=_$1
    logF="./log_5_exp$suffix"
    mkdir -p $logF
    rm -rf $logF/*
    exp=( 1 2 5 6 )

    # follower
    for e in "${exp[@]}";
    do
	rm -rf ./experiments/*
        ./batch_op.sh kill
        cmd="follower/startexpt$e.sh copilot 5 40 4 60 test_$e> ./$logF/log_follower_$e.log 2>&1"
        echo $cmd >> $LOGFILE
        eval "$cmd"
        cp result0_5.csv ./$logF/results0_5_follower_$e.csv
        cp -r experiments ./$logF/experiments_follower_$e
        cp outputdir.log ./$logF/outputdir_follower_$e.log
        sleep 3
    done

    # leader
    for e in "${exp[@]}";
    do
	rm -rf ./experiments/*
        ./batch_op.sh kill
        cmd="leader/startexpt$e.sh copilot 5 40 4 60 test_$e> ./$logF/log_leader_$e.log 2>&1"
        echo $cmd >> $LOGFILE
        eval "$cmd"
        cp result0_5.csv ./$logF/results0_5_leader_$e.csv
        cp -r experiments ./$logF/experiments_leader_$e
        cp outputdir.log ./$logF/outputdir_leader_$e.log
        sleep 3
    done
}

experiment3() {
    suffix=_$1
    logF="./log_5_no_$suffix"
    mkdir -p $logF
    rm -rf $logF/*

    cmd="follower/startexpt0.sh copilot 5 40 4 60 test > ./$logF/log.log 2>&1"
    echo $cmd >> $LOGFILE
    eval "$cmd"
    cp result0_5.csv ./$logF/results0_5.csv
    cp -r experiments ./$logF/experiments
    cp outputdir.log ./$logF/outputdir.log
    sleep 3
}

setup
# ONLY for 1 time
experiment1 1
experiment2 1
experiment2 2
experiment2 3
experiment3 1
experiment3 2
experiment3 3
