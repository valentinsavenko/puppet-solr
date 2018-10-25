# Puppet-Solr module

Solr module, very basic. Only tested on CentOS7 / RedHat7.

It downloads the version defined in hiera from http://archive.apache.org/dist/lucene/solr/, installs Solr following the offcial docu [here](https://lucene.apache.org/solr/guide/7_1/taking-solr-to-production.html#taking-solr-to-production) and starts Solr as a init.d Service.

## Setup

### Setup Requirements

This module expects Java to be present on the system e.g. 'puppetlabs-java'. The default solr version was tested with Oracle Java 1.8.

### Beginning with solr

The minimal code to make it run is simply:
```
include solr
```
It uses all the default values from hiera at [data/common.yaml](data/common.yaml)
## Usage / Reference

Check the hiera file at [data/common.yaml](data/common.yaml) for all possible inputs
The only tricky param is maybe *solr::zk_hosts*, you need to actually have Zookeeper running, for it to make sense, e.g.: 
```
  #------------------------------------------------------------------------------#
  # deric/puppet-zookeeper                                                       #
  # https://github.com/deric/puppet-zookeeper                                    #
  #------------------------------------------------------------------------------#
  class { 'zookeeper': 
    install_method  => 'archive',
    archive_dl_site => 'http://mirror.netcologne.de/apache.org/zookeeper',
    archive_version => '3.4.10',
    service_provider    => 'systemd',
    manage_service_file => true,
  }
```
