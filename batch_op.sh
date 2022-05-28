repos="copilot"  # repos name, default
workdir="~/"  # we default put our repos under the root

n0=$( cat ./ips/node-0 )
n2=$( cat ./ips/node-2 )
n3=$( cat ./ips/node-3 )
n4=$( cat ./ips/node-4 )
n5=$( cat ./ips/node-5 )
n6=$( cat ./ips/node-6 )
n7=$( cat ./ips/node-7 )
n8=$( cat ./ips/node-8 )

servers=(
  $n2
  $n3
  $n4
  $n5
  $n6
  $n7
  $n8
)

# local operation
cmd1=""
cmd2="cd $workdir/$repos ; sudo bash dep.sh"
cmd3=""
cmd4="cd $workdir/$repos ; sudo bash killall.sh"
cmd5=""
cmd6=""

if [ $1 == 'init' ]; then
	:
elif [ $1 == 'dep' ]; then
	eval $cmd2
elif [ $1 == 'kill' ]; then
	echo "kill locally"
	eval $cmd4
elif [ $1 == 'random' ]; then
    echo "[local]------"
    eval $2
else
  :
fi


# sync to others
cmd1="sudo mount -o v4 $n0:/home/xuhao/copilot copilot"
cmd2="cd $workdir/$repos ; sudo bash dep.sh"
cmd3=""
cmd4="cd $workdir/$repos ; sudo bash killall.sh"
cmd5=""
cmd6=""

for host in ${servers[@]}
do
  if [ $1 == 'init' ]; then
    echo "init to $host cmd: $cmd1"
    ssh $host "$cmd1"
  elif [ $1 == 'dep' ]; then
    echo "scp to $host cmd: $cmd2"
    ssh $host "$cmd2" &
elif [ $1 == 'kill' ]; then
    echo "kill depfast $host cmd: $cmd4"
    ssh $host "$cmd4"
elif [ $1 == 'random' ]; then
    echo -e "\n[$host]--------- cmd: $2"
    ssh $host "$2"
else
	  :
  fi
done

echo "Wait for jobs..."
FAIL=0

for job in `jobs -p`
do
    wait $job || let "FAIL+=1"
done

if [ "$FAIL" == "0" ];
then
    echo "YAY!"
else
    echo "FAIL! ($FAIL)"
fi
