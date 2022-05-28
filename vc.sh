#!/bin/bash

set -x

# protocol to run: "copilot", "latentcopilot", "epaxos", "multipaxos" (default)
proto=$1

n=$2 # number of replicas
clients=$3 # number of client threads
cnodes=$4  # number of client machines
reqs=1000000
exec="true"
reply="true"
durable="false"
check="true"
cpus=2
#prefix="/proj/cops/$USER/slowdown"
prefix=$(pwd)
#outputDir=""
cpuprofile=""
verbose="true"
numkeys=100000
length="180" # experiment length
trim="0.25"
writes=100      # percentage of writes
#conflicts=$1   # <0: zipf ; >=0:uniform, conflict x%
#conflicts=0   # <0: zipf ; >=0:uniform, conflict x%
conflicts=25   # <0: zipf ; >=0:uniform, conflict x%
#conflicts=100   # <0: zipf ; >=0:uniform, conflict x%
proxyReplica=0 # for epaxos only
#thrifty="true" # YES thrifty
thrifty="false" # NO thrifty
once="false"
tput_interval_in_sec="0.5"
target_rps="2000"

doEpaxos="false"
doTwoLeaders="false"
doCopilot="false"
doLatentCopilot="false"

if [ "$proto" == "copilot" ]; then
  echo "### Run Copilot protocol ###"
  doTwoLeaders="true"
  doCopilot="true"
elif [ "$proto" == "latentcopilot" ]; then
  echo "### Run Latent Copilot protocol ###"
  doTwoLeaders="true"
  doLatentCopilot="true"
elif [ "$proto" == "epaxos" ]; then
  echo "### Run EPaxos protocol ###"
  doEpaxos="true"
else
  echo "### Run Multi-Paxos protocol ###"
fi

# number of client threads on each client node
threads=$((clients / cnodes))
#echo $threads

masterAddr="node-1"
masterPort="7087"
serverPort="7070"

exp_uid=$(date +%s)
if [[ "$#" -gt 4 ]]
then
    exp_uid="${exp_uid}_$5"
fi
exp_uid="${exp_uid}_${variable}"
outputDir="${prefix}/experiments/${exp_uid}/"
mkdir -p ${outputDir}
rm ${prefix}/experiments/latest
ln -s $outputDir ${prefix}/experiments/latest

echo -e "Running ${proto} at $(date)\t${exp_uid}\t${n}\t${clients}\t${cnodes}" >> ${prefix}/progress


# Cleanup
totalNodes=$((n + cnodes + 1))
for i in $(seq 1 $totalNodes); do
  (ssh -t -t -o StrictHostKeyChecking=no node-$i "\
	cd $prefix; ./killall.sh") &
  pid=$!
  pids="$pids $pid"
done
for pid in $pids; do
  wait $pid
done

# Start Master
for i in $(seq 1 1); do
  ssh node-$i -o StrictHostKeyChecking=no "\
	cd $prefix; \
	bin/master \
	-N=$n \
	-twoLeaders=$doTwoLeaders" \
    2>&1 | awk '{ print "Master: "$0 }' &
done

# Start Servers
declare -a pids
for i in $(seq 2 $((n + 1))); do
  ssh -o StrictHostKeyChecking=no node-$i "\
	cd $prefix; taskset -ac 1 bin/server -maddr=${masterAddr} -mport=${masterPort} -addr=node-$i -port=${serverPort} -e=$doEpaxos -copilot=$doCopilot -latentcopilot=$doLatentCopilot -exec=$exec -dreply=$reply -durable=$durable -p=$cpus -thrifty=$thrifty" \
    2>&1 | awk '{ print "Server-'$i': "$0 }' &
    sleep 2
done

sleep 5

unset pids

offset=$((n + 2))
leftover=$((clients%cnodes))
clientId=0
cnodes_per_server=$((cnodes/n))
for i in $(seq 0 $((cnodes - 1))); do
  # actual node-x on emulab to ssh
  nodeId=$((i + offset))

  processes_per_node=${threads}
  if [ "$i" -lt "$leftover" ]; then
    processes_per_node=$((threads+1))
  fi

  for j in $(seq 0 $((processes_per_node - 1))); do

    # specify proxy replica for epaxos client
    if [ "$proto" == "epaxos" ] && [ "$proxyReplica" -ge 0 ]; then
      #proxyReplica=$((clientId%n))
      proxyReplica=$((i/cnodes_per_server))
    fi
    ssh node-${nodeId} -o StrictHostKeyChecking=no "\
    cd $prefix;
    bin/clientol -maddr=${masterAddr} -mport=${masterPort} -q=$reqs -check=true -e=$doEpaxos -twoLeaders=$doTwoLeaders -numKeys=${numkeys} -c=$conflicts -id=$clientId -cpuprofile=${cpuprofile} -prefix=$outputDir -runtime=$length -trim=${trim} -w=$writes -proxy=$proxyReplica -p=$cpus -tput_interval_in_sec=${tput_interval_in_sec} -target_rps=${target_rps}" \
      2>&1 | awk '{ print "Client-'$clientId'(node-'$nodeId'): "$0 }' &
    pid=$!
    pids="$pids $pid"

    clientId=$((clientId+1))

  done

done

(sleep 90; echo -e "Kill Pilot-0 at $(date) $(date +%s)" >> progress; ssh -t -t -o StrictHostKeyChecking=no node-2 "\
	cd $prefix; ./killall.sh") &
#(sleep 60; echo -e "Kill Pilot-0 at $(date)" >> progress; ssh -t -t -o StrictHostKeyChecking=no node-2 "\
#	cd $prefix; ./killall.sh"; ssh -t -t -o StrictHostKeyChecking=no node-3 "\
#	cd $prefix; ./killall.sh") &
#(sleep 90; echo -e "Kill Pilot-0 at $(date)" >> progress; \
#(ssh -t -t -o StrictHostKeyChecking=no node-2 "cd $prefix; ./killall.sh")& \ 
#(ssh -t -t -o StrictHostKeyChecking=no node-3 "cd $prefix; ./killall.sh")&)&

for pid in $pids; do
  wait $pid
done

sleep 2

# Cleanup
for i in $(seq 1 $totalNodes); do
  ssh -t -t -o StrictHostKeyChecking=no node-$i "\
	cd $prefix; ./killall.sh"
done

####################
# put all throughput latency in one place for easy plotting
cd ${outputDir}
awkScriptPath="${prefix}/scripts/median.awk"
latencyScriptPath="${prefix}/scripts/latency.bash"
for i in $(seq 0 $((clients - 1))); do
  cat client-$i.tputlat.txt >>clients.tputlat.txt
done
# sum throughput of all clients
awk -F"\t" '{sum+=$1;}END{print sum;}' clients.tputlat.txt >tput.txt

source ${latencyScriptPath}

echo -e "$(cat tput.txt)\t$(awk 'BEGIN { ORS = "\t" } { print $2 }' percentilesnew.txt)" | tee tputlat.txt

cd $prefix
python scritps/tput.py $clients ${tput_interval_in_sec} ${outputDir}
