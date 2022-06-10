#!/bin/bash

for i in $(seq 4 5)
do
	az vm create \
		--name andrew-03-janus-ssd-server${i} \
		--resource-group "Depfast_va" \
		--subscription "Microsoft Azure Sponsorship 2" \
		--zone 1 \
		--image debian \
		--os-disk-size-gb 32 \
		--data-disk-sizes-gb 32 \
		--storage-sku Standard_LRS  \
		--size Standard_D16s_v3 \
		--admin-username "xuhao" \
		--ssh-key-values ~/.ssh/id_rsa.pub \
		--accelerated-networking true
done

# sudo sh -c ' wget https://golang.org/dl/go1.15.5.linux-amd64.tar.gz; tar -C /usr/local -xzf go1.15.5.linux-amd64.tar.gz; export PATH=$PATH:/usr/local/go/bin; echo "PATH=\$PATH:/usr/local/go/bin" >> .bashrc ; source .bashrc; '
# mkdir copilot
# sudo apt-get install nfs-common -y