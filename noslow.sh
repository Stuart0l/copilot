#!/bin/bash

clients=(4)
replica=3
iter=1
exp=(1)

for c in ${clients[@]}
do
	for e in ${exp[@]}
	do
		for (( i=1; i<=$iter; i++ ))
		do
			name=copilot_"$replica"r_"$c"c_trail$i
			echo "Running experiment $name"
			./startexpt$e.sh copilot $replica $c 1 20 $name
		done
	done
done
