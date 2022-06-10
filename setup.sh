#!/bin/bash

set -ex

for i in $(seq 5 8)
do
	# scp -o StrictHostKeyChecking=no /etc/hosts xuhao@node-$i:~
	# scp -o StrictHostKeyChecking=no ~/setup-server.sh xuhao@node-$i:~
	ssh -o StrictHostKeyChecking=no xuhao@node-$i " ./setup-server.sh ; "
	# ssh -o StrictHostKeyChecking=no xuhao@node-$i " rm ~/.ssh/known_hosts ; sudo mv ~/hosts /etc "
done