#!/bin/bash -xe
sudo yum update -y
touch /tmp/ud
sudo yum install docker -y
sudo service docker start
sleep 5
touch /tmp/5
sudo systemctl enable docker
sleep 4
touch /tmp/4
sudo docker run -d -p 8080:80 nginx