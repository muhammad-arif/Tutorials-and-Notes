# Securing Elasticsearch  
First Step to secure Elasticsearch is to download and install the [basic version ]([https://www.elastic.co/subscriptions](https://www.elastic.co/subscriptions)) of the elasticsearch. As the open source package doesn't have security features. You can find all of the configuration in much more elaborate and official way[in here.]([https://www.elastic.co/guide/en/elasticsearch/reference/6.6/configuring-tls.html#configuring-tls](https://www.elastic.co/guide/en/elasticsearch/reference/6.6/configuring-tls.html#configuring-tls))  
Procedures are following,  
  
### Encrypting Communication on Elasticsearch  
  
Generating `CA` Certificate,  
[Note: To simplify we are not providing any password, which doesn't compromise security in big time]  
```  
[root@siem01 ~]# /usr/share/elasticsearch/bin/elasticsearch-certutil ca  
```  
Where,  
- `elasticsearch-certutil` is a tool of Elasticsearch to generate a PKCS#12 keystore that contains the public certificate for `CA` and the private key that will be used to sign the certificates for each node and other components.  
- `ca` is for generating `CA` certificate  
- will create a `CA` with file named `elastic-stack-ca.p12` [if you don't change the default]  
  
Creating keys for other nodes and components from the just generated `CA` file which is `elastic-stack-ca.p12`,  
```  
[root@siem01 ~]# /usr/share/elasticsearch/bin/elasticsearch-certutil cert --silent --in instances.yml --out certs.zip --ca elastic-stack-ca.p1  
```  
Where,  
- `cert` generates X.509 certificates and private key for each of the node and components  
- `--in` is used to use `instances.yml` file as a configuration file  
- `--out` is used to create a zip archived named `certs.zip` where all the PKCS#12 keystores are kept  
- `--ca` is used to generate the `X.509` certificate and private key from the certificate authority `elastic-stack-ca.p12`  
- `instances.yml` is following,  
  
```  
instances:  
- name: "siem00"  
  ip:  
    - "192.168.56.51"  
  dns:  
    - "siem00.arif.local"  
- name: "siem01"  
  ip:  
    - "192.168.56.52"  
  dns:  
    - "siem01.arif.local"  
- name: "siem02"  
  ip:  
    - "192.168.56.53"  
  dns:  
    - "siem02.arif.local"  
- name: "siem03"   
  ip:  
    - "192.168.56.54"  
  dns:  
    - "siem03.arif.local"  
- name: "logstash02"  
  ip:  
    - "192.168.56.56"  
  dns:  
    - "logstash02.arif.local"  
- name: "kibana"  
  ip:  
    - "192.168.56.51"  
  dns:  
    - "siem00.arif.local"  
```  
Unzip and copy the contents of the `certs.zip` to the respective hosts,  
```  
[root@siem01 ~]# ls /etc/elasticsearch/certs/  
elastic-stack-ca.p12 siem01.p12  
──────────────────────────────────────────────────────  
[root@siem02 ~]# ls /etc/elasticsearch/certs/  
siem02.p12  
──────────────────────────────────────────────────────  
[root@siem03 ~]# ls /etc/elasticsearch/certs/  
siem03.p12  
```  
### Enabling inter-node TLS transmission  
Adding the following configuration on the `elasticsearch.yml` file on the appropriate hosts  
For `siem03.arif.local` config is the following,  
```  
xpack.security.enabled: true  
xpack.security.transport.ssl.enabled: true  
xpack.security.transport.ssl.verification_mode: certificate  
xpack.security.transport.ssl.keystore.path: certs/siem03.p12  
xpack.security.transport.ssl.truststore.path: certs/siem03.p12  
```  
Where,  
- `siem01.p12` is the `PKCS#12` Keystore appropriate for the host `siem01.arif.local`  
- `siem02.p12` is the `PKCS#12` Keystore appropriate for the host `siem02.arif.local`
- `siem03.p12` is the `PKCS#12` Keystore appropriate for the host `siem03.arif.local`
- ....  
### Enabling TLS on HTTP transmission  
Adding the following configuration on the `elasticsearch.yml` file on the appropriate hosts  
For `siem00.arif.local` config is the following,  
```  
xpack.security.http.ssl.enabled: true  
xpack.security.http.ssl.keystore.path: certs/siem00.p12  
xpack.security.http.ssl.truststore.path: certs/siem00.p12  
```  
### Enabling Built-in users of Elasticsearch  
Elasticsearch have the following [Built-in roles]([https://www.elastic.co/guide/en/elastic-stack-overview/current/built-in-roles.html](https://www.elastic.co/guide/en/elastic-stack-overview/current/built-in-roles.html) "Built-in roles") [quoted directly from the documentation],  
- `elastic` : A built-in _superuser_. See .  
- `kibana`: The user Kibana uses to connect and communicate with Elasticsearch.  
- `logstash_system`: The user Logstash uses when storing monitoring information in Elasticsearch.  
- `beats_system`: The user the Beats use when storing monitoring information in Elasticsearch.  
- `apm_system`: The user the APM server uses when storing monitoring information in Elasticsearch.  
- `remote_monitoring_user`: The user Metricbeat uses when collecting and storing monitoring information in Elasticsearch. It has the `remote_monitoring_agent` and `remote_monitoring_collector` built-in roles.  
  
Generating password for **all** the built-in roles,  
The following command will prompt you for each role hence you have to type your password about **6 x 2** times. This password will later be used in `kibana.yml`, `logstash.yml`, `beats.yml` etc. config files.  

```  
[root@siem01 ~]# /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive  
```
user Kibana uses to connect and communicate with Elasticsearch.  
- `logstash_system`: The user Logstash uses when storing monitoring information in Elasticsearch.  
- `beats_system`: The user the Beats use when storing monitoring information in Elasticsearch.  
- `apm_system`: The user the APM server uses when storing monitoring information in Elasticsearch.  
- `remote_monitoring_user`: The user Metricbeat uses when collecting and storing monitoring information in Elasticsearch. It has the `remote_monitoring_agent` and `remote_monitoring_collector` built-in roles.  
  
Generating password for **all** the built-in roles,  
The following command will prompt you for each role hence you have to type your password about **6 x 2** times. This password will later be used in `kibana.yml`, `logstash.yml`, `beats.yml` etc. config files.  
```  
[root@siem01 ~]# /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive  
```  
Now try to access your elasticsearch context with `https`.
```
