# CDH 5.4.4 pseudo-distributed cluster Docker image for Debian Wheezy

This is a rewrite of [Chalis pseudo distributed cluster docker image](https://github.com/chali/cdh5-pseudo-distributed-cluster-docker)

######Changes
* Wheezy as a base image
* Install necessary packages
* Install Obstacle Java with automatic accepting the license
* Install the Cloudera repository with the very version for the GXL project and the Cloudera key
* Install pig
* Install hive
* Install hue

The way of running services looks not optimal, but has not been changed.

#####Installed services
* HDFS
* YARN
* JobHistoryServer
* Oozie
* PIG
* Hive
* Hue

Actually used are HDFS and HIVE, the rest if for future applications.

##Build the docker image

*Warning the build process downloads more than 1.5 GB of data.* A smaller and fully installed image can be distributed.

This can  be very slooooow in the office.

Get docker image

```sh
docker build -t endocode/cdh_5.4.4 .
```

We will run a master node cdh-node1 and one or more slave nodes cdh-node2, cdh-node3

Run image with specified port `-p` and volume `-v` mappings, run the master cdh-node1

```sh
docker run --dns=$(ip addr show dev docker0 | awk -F'[/ ]' '/inet / {print $6}') --name cdh-node1 -h cdh-node1 -d -p 8020:8020 -p 50070:50070 -p 50010:50010 -p 50020:50020 -p 50075:50075 -p 8030:8030 -p 8031:8031 -p 8032:8032 -p 8033:8033 -p 8088:8088 -p 8040:8040 -p 8042:8042 -p 10020:10020 -p 19888:19888 -p 11000:11000 -p 8888:8888 endocode/cdh_5.4.4
docker run --dns=$(ip addr show dev docker0 | awk -F'[/ ]' '/inet / {print $6}') --name cdh-node2 -h cdh-node2 -d --link=cdh-node1:cdh-node1 endocode/cdh_5.4.4
docker run --dns=$(ip addr show dev docker0 | awk -F'[/ ]' '/inet / {print $6}') --name cdh-node3 -h cdh-node3 -d --link=cdh-node1:cdh-node1 endocode/cdh_5.4.4
./dnsmasq/run_dnsmasq.sh
```

The first time you run this command it is slow, because inside the container all necessary maven artefacts are downloaded in the `/root/.gradle` directory. With

```sh
docker exec -t -i cdh-node1 /bin/bash
```

you can enter the container for debugging. Make sure to set the term variable when you are using the bash shell inside a container:

Check if your slave Hadoop nodes are connected to master node:

```sh
root@cdh-node2:/# sudo -u hdfs hdfs dfsadmin -report | grep Hostname
```

Or by opening this URL on your laptop: http://localhost:50070/dfshealth.html#tab-datanode

You can also review datanode log files:

```
root@cdh-node2:/# tail -f /var/log/hadoop-hdfs/hadoop-hdfs-datanode-`hostname`.log
```

If you find that your datanode can not connect to cdh-node1, you have to restart namenode on master:

```
docker exec cdh-node1 /etc/init.d/hadoop-hdfs-namenode restart
```

This requires a recent docker version, see the [Docker cli reference](https://docs.docker.com/reference/commandline/cli)

I use docker 1.6 on kernel 4.2.

Download test data to the /tmp directory

```sh
cd /tmp
wget http://archive.ics.uci.edu/ml/machine-learning-databases/00339/train.csv.zip
unzip train.csv.zip
```

Fix hive permissions if necessary

```sh
sudo -u hdfs hdfs dfs -chmod -R g+w /user/hive/warehouse
```

Run hive as hdfs user:

```sh
sudo -u hdfs hive
```

Create a database and a table ignoring the data types (room for improvement)

```
CREATE DATABASE IF NOT EXISTS test;
USE test;

CREATE TABLE train (TRIP_ID string, CALL_TYPE string,ORIGIN_CALL string,ORIGIN_STAND string,TAXI_ID string,TIMESTAMP string ,DAY_TYPE string,MISSING_DATA string ,POLYLINE string) row format delimited fields terminated by ',' ;
```

and import data

```
LOAD DATA LOCAL INPATH '/tmp/train.csv' OVERWRITE INTO TABLE train;
```

Install cloudera odbc driver

```
wget https://downloads.cloudera.com/connectors/hive_odbc_2.5.16.1005/Debian/clouderahiveodbc_2.5.16.1005-2_amd64.deb
dpkg -i clouderahiveodbc_2.5.16.1005-2_amd64.deb
```

Test table

```
sudo -u hdfs hive -e 'use test; select count(*) from train;'
```

returns output like this on a Carbon X1 Laptop, (close chrome if complains about lack of resources).

```
Logging initialized using configuration in file:/etc/hive/conf.dist/hive-log4j.properties
OK
Time taken: 0.419 seconds
Query ID = hdfs_20150817161616_0e50afd6-2e98-4302-a6a0-493bc76f5ac7
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks determined at compile time: 1
In order to change the average load for a reducer (in bytes):
set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
set mapreduce.job.reduces=<number>
Starting Job = job_1439826105194_0003, Tracking URL = http://cdh-node1:8088/proxy/application_1439826105194_0003/
Kill Command = /usr/lib/hadoop/bin/hadoop job  -kill job_1439826105194_0003
Hadoop job information for Stage-1: number of mappers: 8; number of reducers: 1
2015-08-17 16:16:14,671 Stage-1 map = 0%,  reduce = 0%
2015-08-17 16:16:24,781 Stage-1 map = 13%,  reduce = 0%, Cumulative CPU 3.35 sec
2015-08-17 16:16:28,150 Stage-1 map = 25%,  reduce = 0%, Cumulative CPU 6.72 sec
2015-08-17 16:16:31,574 Stage-1 map = 38%,  reduce = 0%, Cumulative CPU 10.01 sec
2015-08-17 16:16:33,859 Stage-1 map = 54%,  reduce = 0%, Cumulative CPU 16.59 sec
2015-08-17 16:16:34,978 Stage-1 map = 75%,  reduce = 0%, Cumulative CPU 20.18 sec
2015-08-17 16:16:37,108 Stage-1 map = 88%,  reduce = 0%, Cumulative CPU 23.14 sec
2015-08-17 16:16:39,243 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 25.35 sec
2015-08-17 16:16:40,272 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 26.77 sec
MapReduce Total cumulative CPU time: 26 seconds 770 msec
Ended Job = job_1439826105194_0003
MapReduce Jobs Launched:
Stage-Stage-1: Map: 8  Reduce: 1   Cumulative CPU: 26.77 sec   HDFS Read: 1942946863 HDFS Write: 8 SUCCESS
Total MapReduce CPU Time Spent: 26 seconds 770 msec
OK
1710671
Time taken: 34.103 seconds, Fetched: 1 row(s)
```

	
