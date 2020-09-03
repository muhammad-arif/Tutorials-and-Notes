# Project - SNMP EXTEND

##### !! DISCLAIMER!! The is a newbie project so pardon any mistakes.


## Background 
As we already know SNMP stands for simple network management protocol which communicates via port 161 and sends traps using port 162. SNMP consist of 3 versions named V1, V2 and V3. Where V3 is latest among them and offers enhanced security with authentication and encryption. An SNMP-managed network consists of three key components:
  - Managed device
  - Agent — software which runs on managed devices
  - Network management station (NMS) — software which runs on the manager
 
The managed devices can be any type of device, including, but not limited to, routers, access servers, switches, cable modems, bridges, hubs, IP telephones, IP video cameras, computer hosts, and printers.

An agent is a network-management software module that resides on a managed device. An agent has local knowledge of management information and translates that information to or from an SNMP-specific form.

A network management station (NMS) executes applications that monitor and control managed devices. NMSs provide the bulk of the processing and memory resources required for network management. One or more NMSs may exist on any managed network.

#### Management Information Base (MIB)
The MIB is a database that consists of all queries needed to monitor the devices defined by the vendors in a top-down hierarchical tree. Each branch of the tree that forks off is labeled with both an identifying number (starting with 1) and an identifying string that are unique for that level of the hierarchy. We can use the strings and numbers interchangeably. Each junction in the hierarchy is represented by a dot in this notation so that the address ends up being a series of ID strings or numbers separated by dots. This entire address is known as an object identifier or OID. Let's stop talking and visualize stuff. Suppose we have to check basic system information with, 
```sh
$ snmpwalk -v2c -c public localhost system
```
Here last argument 'system' calls a MIB named "NET-SNMP-MIB::netSnmpAgentOIDs.10" where the OID of this MIB is .1.3.6.1.4.1.8072.3.2.10 . If we generate a tree we will see something like this,
```sh
                                            +-------------------+
                                            |        root       |
                                            +------+------------+
                                                   |
                          -------------------------------------------------------+
                          |                        |                             |
              +-----------+-------+       +--------+----------+   +----------+--------+
              |     ccitt(0)      |       |     iso (1)       |   |      joint (2)    |
              +-------------------+       +----------+--------+   +-------------------+
                                                     |
                                              +------+------------+
                                              |      org(3)       |
                                              +-------------+-----+
                                                            |
                                                    +-------+-----------+
                                                    |      dod(6)       |
                                                    +-------------+-----+|
                                                                  |
                                                           +------+------------+
                                                           |   internet(1)     |
                                                           +-----+-------------+
                                                                 |
            +-----------------------+----------------------------+-----------------------+
            |                       |                            |                       |
+-----------+-------+     +---------+---------+       +----------+--------+       +------+------------+
|   directory(1)    |     |      mgmt(2)      |       | experimental(3)   |       |    priVate(4)     |
+-------------------+     +-------------------+       +-------------------+       +--------+----------+
                                                                                           |
                                                   +---------------------------------------+---------+
    ................      ....................     |       NET-SNMP-MIB::netSnmpAgentOIDs (8072)     | 
                                                   +-----------------------+-------------------------+
                                                                                            |
                                                                                   +--------+----------+
                                                                                   |    system (10)    |
                                                                                   +-------------------+
```

### Protocol Details:
SNMPv1 specifies five core protocol data units (PDUs). Two other PDUs, GetBulkRequest and InformRequest were added in SNMPv2 and the Report PDU was added in SNMPv3.
All SNMP PDUs are constructed as follows:

| Plugin | README | IP header| UDP header| version | community | PDU-type | request-id | error-status | error-index | variable |
| ------ | ------ |------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | 

The seven SNMP protocol data unit (PDU) types are as follows:

##### GetRequest
##
A NMS to managed device request to retrieve the value of a variable or list of variables.
##### SetRequest
A manager-to-agent request to change the value of a variable or list of variables. 
##### GetNextRequest
A manager-to-agent request to discover available variables and their values. 
##### GetBulkRequest
Optimized version of GetNextRequest. A manager-to-agent request for multiple iterations of GetNextRequest. GetBulkRequest was introduced in SNMPv2.
##### Response
Returns variable bindings and acknowledgement from agent to manager for GetRequest, SetRequest, GetNextRequest, GetBulkRequest and InformRequest. 
#### Trap
Asynchronous notification from agent to manager. SNMP traps enable an agent to notify the management station of significant events by way of an unsolicited SNMP message. 

#### InformRequest
Acknowledged asynchronous notification. 

## Example with the Therap scenario 
In therap production, our current monitoring tool NAGIOS installed on OPS01 where net-snmp is also installed and configured. We also have other devices like router, switches, netapp etc where vendors are by default installed and configured snmp. Here ops01 (NMS) generates snmp query using MIB/OID from managed device i.e router, switch, netapp etc. Then the snmp agents installed in the managed devices translate that query (MIB/OID), collect required information and respond to the NMS (ops01) with proper information. After getting information, ops01 fed that info into nagios to perform it's (nagios's) monitoring activities.

## Working with SNMPv2 and SNMPv3
### Installing Net-snmp 
*** Installation process may very in different distribituion in diffrent release. We can alaways use google in case of trouble. :)
##### In Ubuntu  :
```
$ sudo apt-get update; sudo apt-get install snmp snmp-mibs-downloader
```
##### In CentOS/RHEL :
```
# yum install net-snmp net-snmp-libs net-snmp-utils
```
### Configuring 
##### Enabling daemon
```
# systemctl enable snmpd
or
# chkconfig snmpd on
```
##### Configuring for SNMPv1 and SNMPv2
```
# echo rocommunity read_only_user > /etc/snmp/snmpd.conf
# echo rwcommunity read_write_user >> /etc/snmp/snmpd.conf
```
##### Configuring for SNMPv3
```
# echo rouser read_only_user >> /etc/snmp/snmpd.conf
# net-snmp-create-v3-user -ro -a SHA -x AES
```
##### Starting Daemon
```
# systemctl start snmpd
or
# service snmpd start
```
### Testing
##### If using SNMP 1 or 2c, use one of the following commands to test configuration:
#
```
# snmpwalk -v 1 -c read_only_user localhost system
or
# snmpwalk -v 2c -c read_only_user localhost system
```
##### If using SNMPv3, use the following command to test configuration: 
#
```
# snmpwalk -v 3 -u read_only_user -a SHA -A password1 -x AES -X password2 -l authNoPriv localhost system
```
##### If everything works fine then we have successfully completed our testing and configuration. Now we are going to use start our project works.
#
#
## Project requirement:
#### Extending capabilities of snmp by returning diffrent values with custom scripts.

## Using Net-SNMP Extend
Here we will use net-snmp's extending option to extend the functionality of the agent - not by recompiling with code for new MIB modules, but by configuring the running agent to report additional information. We can do this by running external command or scripts with the following procedure,
First we will built a small script, which will return 3 highest cpu consuming process.
```
$ sudo vi /usr/bin/t3cpu-ps
```
Adding following contents:
```
#!/bin/bash
ps -eo comm,%cpu --sort=-%cpu | head -4 | awk '{print $1}'| sed '1d'
```
 Giving permission to execute by everyone
```
$ chmod a+x /usr/bin/t3cpu-ps
```
 Adding to snmp config file,
```
$ sudo echo "exec t3cpu-ps /usr/bin/t3cpu-ps" >> /etc/snmp/snmpd.conf
```
Restart snmpd service
```
$ sudo systemctl restart snmpd
or 
$ sudo service snmpd restart
```
Retriving values with SNMPv1, sNMPv2 and SNMPv3,
```
$ snmpwalk -v1 -c read_only_user localhost nsExtendOutput1
or
$ snmpwalk -v2c -c read_only_user localhost nsExtendOutput1
or 
$ snmpwalk -v 3 -u read_only_user -a SHA -A password1 -x AES -X password2 -l authNoPriv localhost nsExtendOutput1
NET-SNMP-EXTEND-MIB::nsExtendOutput1Line."t3cpu-ps" = STRING: firefox
NET-SNMP-EXTEND-MIB::nsExtendOutputFull."t3cpu-ps" = STRING: firefox
vivaldi-bin
Xorg
NET-SNMP-EXTEND-MIB::nsExtendOutNumLines."t3cpu-ps" = INTEGER: 3
NET-SNMP-EXTEND-MIB::nsExtendResult."t3cpu-ps" = INTEGER: 0
 
```
Finding The OID,
```
$ snmptranslate -On NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"t3cpu-ps\"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.8.116.51.99.112.117.45.112.115
```
 Calling with OID,
```
$ snmpwalk -v2c -c read_only_user localhost 1.3.6.1.4.1.8072.1.3.2.3.1.2.8.116.51.99.112.117.45.112.115
NET-SNMP-EXTEND-MIB::nsExtendOutputFull."t3cpu-ps" = STRING: firefox
vivaldi-bin
Xorg
## DONE !!
