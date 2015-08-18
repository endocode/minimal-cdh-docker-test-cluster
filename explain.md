# Explaination of the scripting, design and config

## Docker

The setup with Docker is complete, reproducable and avoids the complexity of setting up a system with Puppet, Chef, Ansible or other configuration management solutions.

The Dockerfile can be audited. Running for demo or test purposes needs less resources the virtualization solutions like VirtualBox, KVM or VMWware

It can be run on bare metal without performance penalties for the hardware and can be run in production. It is a little bit more secure than a bare metal installation.

The current setup uses the build in OverlayFS, which is a shortcoming and needs to be replaced by native volumes with the `-v` option.

The copying of the `/etc/hosts` file should be replaced by using the `etcd`.

# Cloudera on Debian

Cloudera on Debian Wheezy is a stable and standard way of setting up Hadoop. Cloudera recommends their Cloudera Manager to set up a cluster by web gui, however, in automated environments a script base approach is prefered.

# Hive

Hive is the standard way of querying and managing large datasets residing in distributed storage. 

http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/admin_hos_config.html

# Scaling 

The network based approach of Hadoop has a serious disadvantage as a factor of 15 is wasted in examples where you could keep all data in memory.
Therefore the scaling of the set of 0.5 G to 50 G has different alternatives

## Medium data
- do not use Hadoop at all, but a standard SQL DB like PostgresQL or MySQL
- use [Spark](https://spark.apache.org/docs/1.2.0/sql-programming-guide.html) (not in the standard Cloudera distributed version of Hadoop

## Further optimization 
- in batch mode consider Pig and Tez
- simply add more nodes
- Use compressed table formats like [Orc](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+ORC)
- Use Hive table partitioning
- Run multiple Hive servers with Zookeeper to distribute the queries

The discussion became political between Hortonworks Spark and if Tez or Spark offer better performance.

# Scaling to the limit

Optimization can be applied to system engineering, the components of the distribution, the configuration and the scripts running on the cluster.

# System engineering

The scaling on the system engineering side includes 

more resources in the following order
- RAM
- CPUs per machine
- disks, maybe use SSDs
- bandwidth
- [optimize the JVM](https://software.intel.com/en-us/articles/hadoop-and-hbase-optimization-for-read-intensive-search-applications)

## Further Optimization

- see above: Pig, Tez, Orc
- Hive vectorization,  cost based query optimization
- use Hive analytical capabilities
- more [Hive instances load balanced](http://oobaloo.co.uk/multiple-connections-with-hive)
- write good SQL
- optimization of  text search with [elasticsearch for hadoop](https://www.elastic.co/blog/elasticseach-hadoop-certified-cloudera-cdh5) using [range aggregation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-range-aggregation.html)