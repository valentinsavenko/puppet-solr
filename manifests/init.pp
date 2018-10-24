
# Class: solr
# ===========================
#
# Full description of class solr here.
#
# Parameters
# ----------
#
# [*collection*]
#   Solr core collection that will be created after installation
#
# [*version*]
#   Solr version that will be installed
#
# Examples
# --------
#
# @example
#    class { 'solr':
#      version => '7.1.0',
#    }
#
# Authors
# -------
#
# Michael Strache <michael.strache@netcentric.biz>
# Valentin Savenko <valentin.savenko@netcentric.biz>
#
# Copyright
# ---------
#
# Copyright 2018 Michael Strache & Valentin Savenko, Netcentric
#

# TODO:
#   - Make download url configurable


class solr (
  String  $user           = lookup('solr::user',        { value_type => String }),
  Boolean $manage_user    = lookup('solr::manage_user', { value_type => Boolean }),
  String  $group          = lookup('solr::group',       { value_type => String }),
  Boolean $manage_group   = lookup('solr::manage_group',{ value_type => Boolean }),
  String  $install_dir    = lookup('solr::install_dir', { value_type => String }),
  String  $service_name   = lookup('solr::service_name',{ value_type => String }),
  String  $version        = lookup('solr::version',     { value_type => String }),
  Integer $port           = lookup('solr::port',        { value_type => Integer }),
  String  $memory         = lookup('solr::memory',      { value_type => String }),
  String  $data_dir       = lookup('solr::data_dir',    { value_type => String }),
  String  $hostname       = lookup('solr::hostname',    { value_type => String }),
  Array[String] $zk_hosts = lookup('solr::zk_hosts',    { value_type => Array[String, 1] }),
) {

  #------------------------------------------------------------------------------#
  # Code                                                                         #
  #------------------------------------------------------------------------------#
  # So far based on https://lucene.apache.org/solr/guide/7_1/taking-solr-to-production.html#taking-solr-to-production


  if $manage_group {
    group { $group:
      ensure => 'present',
    }
  }

  if $manage_user {
    user { $user:
      ensure => 'present',
      gid    => $group,
    }
  }


  # solr dependency on RedHat servers
  package { 'lsof':
    ensure => 'installed',
  }

  # Download the installer archive and extract the install script
  $install_archive = "${install_dir}/solr-${$version}.tgz"
  archive { $install_archive:
    checksum_type   => 'sha1',
    checksum_url    => "http://archive.apache.org/dist/lucene/solr/${$version}/solr-${$version}.tgz.sha1",
    cleanup         => false,
    creates         => $home_dir,
    extract         => true,
    extract_path    => $install_dir,
    source          => "http://archive.apache.org/dist/lucene/solr/${$version}/solr-${$version}.tgz",
  }

  # Create instance data folder
  file { $data_dir:
    recurse => true,
    owner   => $user,
    group   => $group,
  }

  # Solr is extracted & installed here
  $home_dir = "${install_dir}/solr-${$version}"
  
  # triggers install script as defined in the solr docu
  $install_command = "${home_dir}/bin/install_solr_service.sh ${install_archive} -n -i ${install_dir} -d ${data_dir} -u ${user} -s ${service_name} -p $port"
  exec { "Solr install for Solr-${version}" :
        command   => $install_command,
        timeout   => 200,
        path      => "/usr/bin:/bin",        
        unless    => "/usr/bin/test -e ${home_dir}/.solr-${version}-installed-flag",
        require   => [
          File[$data_dir],
          Archive[$install_archive],
        ];
  }

  # Leave breadcrumbs/flags to indicate that the installation + restarts was already performed and should not be repeated next time!
  file { "Solr-${version} - Leave breadcrumbs to indicate that the Solr-${version} was already installed." :
    path    => "${home_dir}/.solr-${version}-installed-flag",
    ensure  => 'present',
    owner   => $user,
    mode    => '0644',
    content => "This file indicates that solr was already installed in this version and doesn\'t need to be repeated on every puppet run!",
    require => [
      Exec["Solr install for Solr-${version}"],
    ];
  }
  
  # default solr config file 
  $config_file = "/etc/default/${service_name}.in.sh"
  
  file { $config_file:
    path    => $config_file,
    ensure  => present,
    require => [
      Exec["Solr install for Solr-${version}"],
    ];
  }

  if $memory {
    file_line { 'Append memory setting to the default config file for the solr service':
      notify  => Service[$service_name],
      path    => $config_file,  
      line    => "SOLR_JAVA_MEM=\"${memory}\"",
      match   => '.*SOLR_JAVA_MEM=.*',
      require => File[$config_file],

    }
  }

  if $zk_hosts {
    $zk_hosts_options = $zk_hosts.join(',')
    file_line { 'Append zookeeper settings to the default config file for the solr service':
      notify  => Service[$service_name],
      path    => $config_file,  
      line    => "ZK_HOST=\"${zk_hosts_options}\"",
      match   => '.*ZK_HOST=.*',
      require => File[$config_file],
    }
  }


  # start and enable solr service
  service { $service_name:
    ensure    => running,
    enable    => true,
  }

}
