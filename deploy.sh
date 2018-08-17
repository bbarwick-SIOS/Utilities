#!/bin/bash

build() {
        scp bbarwick@ci.sc.steeleye.com:/var/lib/jenkins/jobs/cloud-orchestrator-service/workspace/pkg/version /var/lib/jenkins/jobs/cloud-orchestrator-service/workspace/pkg/
        mvn clean install && cd pkg && make && cd ..
}

buildnotests() {
        scp bbarwick@ci.sc.steeleye.com:/var/lib/jenkins/jobs/cloud-orchestrator-service/workspace/pkg/version /var/lib/jenkins/jobs/cloud-orchestrator-service/workspace/pkg/
        mvn clean install -DskipTests=true && cd pkg && make && cd ..
}

target=$1
shift
if [ -z "$target" ]
then
        echo "Please supply target machine"
        return
fi

test=$1
shift
if [ -n "$test" ] && [ "$test" = "-nt" ]
then
	echo "Tests disabled in Maven build"
	buildnotests
else
	echo "Tests enabled in Maven build"
	build
fi

echo "Building and deploying to $target"

if [ $? -eq 0 ]
then
        mkdir -p /home/bbarwick/staging
        cd /home/bbarwick/staging
        rm *
        apt-get update
        apt-get download cloud-orchestrator
        ssh -i /home/bbarwick/.ssh/cldo-sioss-rsa-4096 root@"$target" 'rm /home/sioss/cloud-orchestrator*.deb'
        scp -i /home/bbarwick/.ssh/cldo-sioss-rsa-4096 cloud-orchestrator*.deb root@"$target":/home/sioss
        ssh -i /home/bbarwick/.ssh/cldo-sioss-rsa-4096 root@"$target" 'cd /home/sioss/ && dpkg -i ./cloud-orchestrator*.deb'
        cd /mnt/c/Users/bbarwick/Code/cloud-orchestrator-service
        ssh -i /home/bbarwick/.ssh/cldo-sioss-rsa-4096 root@"$target" 'iptables -A INPUT -p tcp -m tcp --dport 9875 -j ACCEPT'
        ssh -i /home/bbarwick/.ssh/cldo-sioss-rsa-4096 root@"$target" 'iptables -A INPUT -p tcp -m tcp --dport 9881 -j ACCEPT'
fi
