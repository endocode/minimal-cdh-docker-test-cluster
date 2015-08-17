#!/bin/bash

service hadoop-hdfs-namenode start
service hadoop-hdfs-datanode start

sudo -u hdfs hadoop fs -mkdir -p /tmp/hadoop-yarn/staging/history/done_intermediate
sudo -u hdfs hadoop fs -chown -R mapred:mapred /tmp/hadoop-yarn/staging
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp
sudo -u hdfs hadoop fs -mkdir -p /var/log/hadoop-yarn
sudo -u hdfs hadoop fs -chown yarn:mapred /var/log/hadoop-yarn

service hadoop-yarn-resourcemanager start
service hadoop-yarn-nodemanager start
service hadoop-mapreduce-historyserver start

sudo -u hdfs hadoop fs -mkdir -p /user/hdfs
sudo -u hdfs hadoop fs -chown hdfs /user/hdfs

#init oozie
sudo -u hdfs hadoop fs -mkdir /user/oozie
sudo -u hdfs hadoop fs -chown oozie:oozie /user/oozie
sudo oozie-setup sharelib create -fs hdfs://localhost:8020 -locallib /usr/lib/oozie/oozie-sharelib-yarn.tar.gz

service oozie start

sudo -u hdfs hdfs dfs -mkdir /user/hive
sudo -u hdfs hdfs dfs -chmod -R 777 /user/hive
service hive-metastore start
service hive-server2 start

service hue start

sleep 1

# tail log directory
tail -n 1000 -f /var/log/hadoop-*/*.out
