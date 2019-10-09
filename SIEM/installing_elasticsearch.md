# Installing and Clustering Elasticsearch
## Overview,
### Requirements
**OS:** 		Oracle Linux
**RAM:** 	  8GB
**CPU:** 	  4 CPU (Duel Core)
**HDD1:**   16 GB
**HDD2:**   500 GB
**IP:** 		192.168.56.51-54

### Hostname And Roles
Co-ordinator and Kibana Node: `siem.arif.local`
Master and Data Node: `siem01.arif.local`, `siem02.arif.local`, `siem03.arif.local`

## Installing and Configuration

### Creating Storage
Formatting drive to **XFS** 
```
[root@siem01 ~] mkfs.xfs /dev/sdb
```
Creating **storage** Directory
```
[root@siem01 ~] mkdir --parents /storage/elasticsearch
```
mounting **storage** Directory
```
[root@siem01 ~] mount /dev/sdb /storage
```
Making it Persistent 
```
[root@siem01 ~] echo '/dev/sdb1  /storage xfs  defaults  0  0' >> /etc/fstab
```
### Installing Java
```
[root@siem01 ~] yum install java
```
### Installing Elasticsearch
Import the Elasticsearch PGP key,
```
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```
Creating a file called `elk.repo`
```
[root@siem01 ~]touch /etc/yum.repos.d/elk.repo
```
And paste the following content on `elk.repo`,
```
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```
Installing Elasticsearch Packages,
```
[root@siem01 ~] yum -y install elasticsearch
```
Creating data path for elasticsearch. In this case a 500GB mount is configured on `/storage`  Creating a directory inside `/storage`
```
[root@siem01 ~] mkdir elasticsearch
```
Making sure the  `/storage/elasticscearch`  dir is owned by user `elasticsearch` 
```
[root@siem01 ~] chown -R elasticsearch /storage/elasticsearch
```
Adjusting virtual memory and configure swappiness on `/etc/sysctl.conf`
```
vm.max_map_count=262144
vm.swappiness=1
```
[Disabling swapping](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration-memory.html) and remove swap configuration from `/etc/fstab`
```
[root@siem01 ~] swapoff -f
```
Changing the value of `MAX_LOCK_MEMORY` on `/etc/default/elasticsearch`
```
MAX_LOCKED_MEMORY=unlimited
```
Change `LimitMEMLOCK` and `LimitNOFILE=131070` on `/usr/lib/systemd/system/elasticsearch.service`
```
LimitMEMLOCK=infinity
LimitNOFILE=131070
```
Now reload the `systemctl` daemon and restart Elasticsearch to put the changes into place:
```
[root@siem01 ~] systemctl daemon-reload
[root@siem01 ~] systemctl restart elasticsearch
```


### Configuring Elasticsearch
We are going to edit on `/etc/elasticsearch/elasticsearch.yml` and make following changes, 
[Best way to troubleshoot is to give the service a restart after each change than you will have the idea where things went wrong when elasticsearch status is not okay. You can find all the complete `elasticsearch.yml` on the current directory]

Changing name of the Cluster
```
cluster.name: siem
```
Configuring Master and Data eligible nodes `siem{01..03}.arif.local`,
```
node.master: true
node.data: true
node.ml: false
```
Configuring Co-ordinating node ( `siem.arif.local` ) ,
```
node.master: false
node.data: false
node.ingest: false
node.ml: false
```
Changing the default file directory to `/storage/elasticsearch`.
[This step is not necessary for co-ordinator node]
```
path.data: /storage/elasticsearch
```
Un-commenting the `network.host` and add  `ip` as value.  [CAUTION: This will enable [production mode!](https://www.elastic.co/guide/en/elasticsearch/reference/current/network.host.html)]
```
network.host: 192.168.1.55
```
Add node discovery hosts, [make sure you add them on `/etc/hosts`]
```
discovery.seed_hosts: ["siem.arif.local",""siem01.arif.local","siem02.arif.local", "siem03.arif.local"]
```

Adding `cluster.initial_master_nodes`  on the all of the hosts,
```
cluster.initial_master_nodes: ["siem01.arif.local", "siem02.arif.local", "siem03.arif.local"]
```

After completing the configuration restart all the elasticsearch and check if all servicess are up properly,
```
[root@siem01 ~] systemctl status elasticsearch.service
```
Check the node status with the following,
```
[root@siem01 ~]# curl -XGET "http://192.168.56.52:9200/_cat/nodes?v"
ip           heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
192.168.1.52            7          96   1    0.05    0.02     0.07 dim        *      siem01.arif.local
192.168.1.54           12          95   1    0.00    0.00     0.03 dim        -      siem03.arif.local
192.168.1.53           12          95   1    0.00    0.00     0.04 dim        -      siem02.arif.local
192.168.1.54           12          95   1    0.00    0.00     0.03 -          -      siem.arif.local
```
Check Cluster health,
```
[root@siem01 ~]# curl -XGET "http://192.168.56.52:9200/_cluster/health?pretty"
{
  "cluster_name" : "siem",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 2,
  "active_primary_shards" : 0,
  "active_shards" : 0,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```

More doc to follow,


[1. Bootsraping Cluster](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-bootstrap-cluster.html#modules-discovery-bootstrap-cluster-joining)

[2. Important Discovery Cluster information](https://www.elastic.co/guide/en/elasticsearch/reference/current/discovery-settings.html#unicast.hosts)

[3. Discovery and Cluster formation](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/modules-discovery.html)

[4. Important System Configuration](https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html)

[5. Simple Tutorial by Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-production-elasticsearch-cluster-on-centos-7)

[6. Hardware Resource Allocation](https://www.elastic.co/guide/en/elasticsearch/guide/current/hardware.html)

[6. Simple Tutorial by Logz.io](https://logz.io/blog/elasticsearch-cluster-tutorial/)
