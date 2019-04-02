
# Class: solr
# ===========================
#
# Full description of class solr here.
# Examples
# --------
#
# @example
#    class { 'solr':
#      version => '7.7.0',
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
  String  $user,
  Boolean $manage_user,
  String  $group,
  Boolean $manage_group,
  String  $install_dir,
  String  $service_name,
  String  $version,
  Integer $port,
  String  $memory,
  Boolean $jmx_remote,
  String  $data_dir,
  Array[String] $zk_hosts,
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
    checksum_type => 'sha512',
    checksum_url  => "http://archive.apache.org/dist/lucene/solr/${$version}/solr-${$version}.tgz.sha512",
    cleanup       => false,
    creates       => 'dummy_value', # extract every time. This is needed because archive has unexpected behaviour without it. (seems to be mandatory, instead of optional)
    extract       => true,
    extract_path  => $install_dir,
    source        => "http://archive.apache.org/dist/lucene/solr/${$version}/solr-${$version}.tgz",
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
  $install_command = "${home_dir}/bin/install_solr_service.sh ${install_archive} -n -i ${install_dir} -d ${data_dir} -u ${user} -s ${service_name} -p ${port}"
  exec { "Solr install for Solr-${version}" :
        command => $install_command,
        timeout => 200,
        path    => '/usr/bin:/bin',
        unless  => "/usr/bin/test -e ${home_dir}/.solr-${version}-installed-flag",
        require => [
          File[$data_dir],
          Archive[$install_archive],
        ];
  }

  # Leave breadcrumbs/flags to indicate that the installation + restarts was already performed and should not be repeated next time!
  file { "Solr-${version} - Leave breadcrumbs to indicate that the Solr-${version} was already installed." :
    ensure  => present,
    path    => "${home_dir}/.solr-${version}-installed-flag",
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
    ensure  => present,
    path    => $config_file,
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

  if $jmx_remote {
    file_line { 'Enable JMX remote':
      notify  => Service[$service_name],
      path    => $config_file,
      line    => "ENABLE_REMOTE_JMX_OPTS=\"true\"",
      match   => '.*ENABLE_REMOTE_JMX_OPTS=.*',
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
    ensure => running,
    enable => true,
  }

}
