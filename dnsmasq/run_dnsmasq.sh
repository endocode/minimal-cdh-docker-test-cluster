#!/bin/bash

DIR=$(cd `dirname $0` && pwd)

docker build -t dnsmasq $DIR
docker inspect --format '{{ .NetworkSettings.IPAddress}} {{ .Config.Hostname }}' `docker ps -q` > $DIR/hosts
docker rm dnsmasq
docker run --name dnsmasq -d -v $DIR/hosts:/hosts -p 172.17.42.1:53:53/udp dnsmasq
