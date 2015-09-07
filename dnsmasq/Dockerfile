FROM debian:wheezy
MAINTAINER Anton Khramov <anton@endocode.com>

RUN apt-get update && apt-get upgrade -y && apt-get install -y dnsmasq

EXPOSE 53

CMD ["/usr/sbin/dnsmasq", "-i" ,"eth0", "-p", "53", "-H", "/hosts", "--no-hosts", "-d"]
