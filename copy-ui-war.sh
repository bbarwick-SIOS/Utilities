#!/bin/bash

target=$1
shift
if [ -z "$target" ]
then
        echo "Please supply target machine"
        return
fi

echo "Building and copying .war to $target"

if [ $? -eq 0 ]
then
        cd /mnt/c/Users/bbarwick/Code/cloud-orchestrator-ui
        mvn clean package
        ssh -i /home/bbarwick/.ssh/cldo-sioss-rsa-4096 root@"$target" 'service tomcat7 stop'
        ssh -i /home/bbarwick/.ssh/cldo-sioss-rsa-4096 root@"$target" 'rm -rf /var/lib/tomcat7/webapps/ui*'
        scp -i /home/bbarwick/.ssh/cldo-sioss-rsa-4096 target/ui.war root@"$target":/var/lib/tomcat7/webapps
        ssh -i /home/bbarwick/.ssh/cldo-sioss-rsa-4096 root@"$target" 'service tomcat7 start'
fi
