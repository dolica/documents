#! /bin/bash

set -x 
set -e

#shutdown system firewall
systemctl stop firewalld
systemctl disable firewalld

#setup bash-autocompletion
yum install -y bash-completion

#download registry ca
mkdir -p /etc/docker/certs.d/asc.registry.com:5043 && cd /etc/docker/certs.d/asc.registry.com:5043
curl -L https://raw.githubusercontent.com/dolica/documents/master/DPS-env-script/ca.crt --output ca.crt --silent

#login private docker registry
docker login asc.registry.com:5043 --username admin --password admin123

if [ $1 = 'manager' ]
then
    docker swarm join --token SWMTKN-1-2wps2sai29oomksgcrbitrmkbfdwfl8thtjgr1460kbioff064-7kiap38yrccicw327ctm6kv2j 10.1.10.190:2377
elif [ $1 = 'worker' ]
then
    docker swarm join --token SWMTKN-1-2wps2sai29oomksgcrbitrmkbfdwfl8thtjgr1460kbioff064-bkbvtgdtn847ryh4i15jyz2xy 10.1.10.190:2377
else
    echo "$1 not match."
fi

#install docker compose 1.90
curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose




    
    
