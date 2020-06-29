# cdougan_db2_client

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with cdougan_db2_client](#setup)
    * [What cdougan_db2_client affects](#what-cdougan_db2_client-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cdougan_db2_client](#beginning-with-cdougan_db2_client)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

Sets up the administration user accounts for the DB2 client and/or the installation
of the DB2 client itself (currently only 10.5.7).

Tested on RHEL 6.x and 7.x with Puppet 3.8.

## Module Description

This applies configuration for the DB2 Client on Red Hat Enterprise Linux
(v6.x and v7.x tested).  It automates the installation of the client, setting
up of the client instance and the creation of Administration accounts for the 
DB2 team (a list of AD accounts currently defined in Hiera).  Sudo access for
these accounts is also set up to allow them to sudo into the account the client
is installed under (db2client).   There is also an option to just set up the 
user accounts without installing the client for those servers where there is a
requirement to install the client manually.

## Setup

### What cdougan_db2_client affects

**Directories Created**
* /opt/IBM/db2
* /home/db2inst1
* /opt/IBM/
* /opt/IBM/Installation
* /opt/IBM/Installation/DB2
* /opt/IBM/Installation/logs



**Files Created**
* /opt/IBM/db2/*
* /home/db2inst1/*
* /opt/IBM/Installation/DB2/v10.5fp7_rtcl.rsp
* /opt/IBM/Installation/logs/install_db2_client.log
* /opt/IBM/Installation/logs/create_db2_client_instance.log



**Files Managed by the Modules**
* /home/db2inst1/.bash_profile
* /opt/IBM/Installation/DB2/v10.5fp7_rtcl.rsp



**Users Created**
* db2inst1
* DB2 Client Users:  currently stored in Hiera under db2_client_users



**Usergroups Created**
* db2dba



**Sudo Rules Created**
* %db2client ALL=(db2inst1) NOPASSWD: ALL [ in /etc/sudoers.d/db2client ]


**Flowchart**
![picture](img/flowchart.jpg)
### Dependencies ####

* stdlib
* archive
* cdougan_users_groups


### Setup Requirements

**Filesystems**
When installing the client on a server where /opt/IBM is to be created as a filesystem
i.e. an Automated install of WAS) the DB2 client module will need to be applied after
this has been done.  This can be accomplished via class ordering in a wrapper
class or by ensuring the filesystem is set up and mounted before applying the db2
client class.  If this is done in the wrong order then the db2 client will be 
unavailable as the /opt/IBM filesystem will be mounted over the top of it.



**Users**
To allow the module to set up administration users for the DB2 client there needs to be 
a 'db2_client_users' entry in Hiera detailing the users - i.e.

```yaml
  db2_client_users:
    'tso308sa':
      ensure: 'ad'
      comment: 'Gordon.Foley@cdougan.co.uk'
      purge_ssh_keys: 'true'
      groups: 'db2dba'
    'tso977sa':
      ensure: 'ad'
      comment: 'Neil.Wellham@cdougan.co.uk'
      purge_ssh_keys: 'true'
      groups: 'db2dba'
```



**Commands Run**

```
mkdir -p ${software_location}/logs
mount -o remount,rw,exec,suid /tmp
mount -o remount,rw,exec,suid /home
cd ${db2c_install_location}/rtcl && ./db2setup -r ${software_location}/DB2/${db2_response_file} > ${software_location}/logs/install_db2_client.log
bash -c 'source ~${db2_client_user}/.bash_profile; cd ${db2_file}/instance; ./db2icrt -s client ${db2_client_user}' > ${software_location}/logs/create_db2_client_instance.log"
```



**Nexus**
The DB2 client installs from packages stored in Nexus.  These are the current details;

* Package Name : DB2_Client-10.5.7.tgz
* Group ID : IBM
* Artifact ID : DB2
* Version Number : 10.5.7
* Packaging Type : tgz
* Nexus Repo : A0520-WebSphere-Application-Server 
* Nexus URL : http://abc-watm-artefactrepo.somehost.co.uk:8081/nexus/service/local/repositories



### Beginning with cdougan_db2_client

Apply the module to a server - the default options will set it to install



## Usage

**Main parameters that can be set**

* install_db2_client (default = true) 
* software_location (default = /opt/IBM/Installation)
* db2c_version_number (default = 10.5.7)
* db2_client_user (default = db2inst1)
* install_path (default = /opt/IBM)
* db2c_install_location (default = \<install path\>/db2)


note that there are a few other parameters relating to Nexus etc, however these
are unlikely to need to be changed on a regular basis.  For these please refer
to 'cdougan_db2_client::params'.



## Reference

**Classes**
* cdougan_db2_client
* cdougan_db2_client::params
* cdougan_db2_client::local_user_config
* cdougan_db2_client::ad_user_config
* cdougan_db2_client::install


Entrypoint is via the main class only.



## Limitations

* RHEL v6.x-v7.x
* Puppet 3.x
