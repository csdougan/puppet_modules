class cdougan_mongodb_os (  
  $version         = "32",
  $dbpath          = "/data",
  $mongodb_vg      = "datavg",
  $mongodb_lv      = "datalv",
  $optrh_lv        = "optrhlv",
  $optrh_lv_size   = "1G",
  $mongodb_lv_size = "8G",
  $pv_name         = "/dev/sdb",
  $setup_lvm       = true,
) {
  if $setup_lvm {
    if $operatingsystemmajrelease == '6' {
      $fs_type                    = 'ext4'
      $fs_switch                  = ''
    } else {
      $fs_type                    = 'xfs'
      $fs_switch                  = '-f'
    }
    include ::lvm

    physical_volume { "${pv_name}":
      ensure                      => present,
      unless_vg                   => "${mongodb_vg}",
    }

    volume_group { "${mongodb_vg}":
      ensure                      => present,
      physical_volumes            => "${pv_name}",
      require                     => Physical_volume["${pv_name}"],
      createonly                  => true,
    }

    exec { "create ${mongodb_lv}":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "lvcreate -y -L${mongodb_lv_size} -n ${mongodb_lv} ${mongodb_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${mongodb_vg}-${mongodb_lv}",
      creates                     => "/dev/mapper/${mongodb_vg}-${mongodb_lv}",
      require                     => Volume_group["${mongodb_vg}"],
    }

    exec { "create ${optrh_lv}":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "lvcreate -y -L${optrh_lv_size} -n ${optrh_lv} ${mongodb_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${mongodb_vg}-${optrh_lv}",
      creates                     => "/dev/mapper/${mongodb_vg}-${optrh_lv}",
      require                     => Volume_group["${mongodb_vg}"],
    }

    exec {"Create mount point for ${dbpath}":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "mkdir -p ${dbpath}",
      creates                     => $dbpath,
    }
 
    exec {"Create /opt/rh mount point":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "mkdir -p /opt/rh",
      creates                     => "/opt/rh",
    }
 
    mount {"${dbpath}":
     ensure                       => mounted,
     device                       => "/dev/mapper/${mongodb_vg}-${mongodb_lv}",
     fstype                       => "${fs_type}",
     remounts                     => "true",
     options                      => "defaults",
     require                      => [Exec["Create mount point for ${dbpath}"],
                                      Exec["create ${mongodb_lv}"]],
    }

    mount {"/opt/rh":
     ensure                       => mounted,
     device                       => "/dev/mapper/${mongodb_vg}-${optrh_lv}",
     fstype                       => "${fs_type}",
     remounts                     => "true",
     options                      => "defaults",
     require                      => [Exec["Create /opt/rh mount point"],
                                      Exec["create ${optrh_lv}"]],
    }

    group {"mongod":
      ensure => present,
      gid    => 611,
    }

    user {"mongod":
     ensure  => present,
     uid     => 611,
     require => Group["mongod"],
    }

    file {"/opt/rh":
      ensure  => directory,
      require => Mount["/opt/rh"],
    }

    file {$dbpath:
      ensure  => directory,
      owner   => "mongod",
      group   => "mongod",
      require => [Mount[$dbpath],
                  User["mongod"]],
    }

    file {"${dbpath}/log":
      ensure  => directory,
      owner   => "mongod",
      group   => "mongod",
      require => File[$dbpath],
    }

    file {"${dbpath}/db":
      ensure  => directory,
      owner   => "mongod",
      group   => "mongod",
      require => File[$dbpath],
    }

    file {"${dbpath}/backup":
      ensure  => directory,
      owner   => "mongod",
      group   => "mongod",
      require => File[$dbpath],
    } 

  } else {

    file {"/opt/rh":
      ensure  => directory,
    }

    file {$dbpath:
      ensure  => directory,
      owner   => "mongod",
      group   => "mongod",
    }

    file {"${dbpath}/log":
      ensure  => directory,
      owner   => "mongod",
      group   => "mongod",
      require => File[$dbpath],
    }

    file {"${dbpath}/db":
      ensure  => directory,
      owner   => "mongod",
      group   => "mongod",
      require => File[$dbpath],
    }

    file {"${dbpath}/backup":
      ensure  => directory,
      owner   => "mongod",
      group   => "mongod",
      require => File[$dbpath],
    }
  }

  $conf_file = "/etc/opt/rh/rh-mongodb${version}/mongod.conf"
  # install mongodb
  package {"rh-mongodb${version}-mongodb-server.x86_64":
    ensure  => "present",
    require => [File[$dbpath],
                File["/opt/rh"],
                File["${dbpath}/log"],
                File["${dbpath}/backup"],
                File["${dbpath}/db"]],
  }
  file {$conf_file:
    source  => "puppet:///modules/cdougan_mongodb_os/mongod.conf",
    ensure  => present,
    require => Package["rh-mongodb${version}-mongodb-server.x86_64"],
  }

  file {"/etc/profile.d/mongodb.sh":
    ensure  => 'link',
    target  => "/opt/rh/rh-mongodb${version}/enable",
  }

  file {"/etc/logrotate.d/mongodb":
    ensure => present,
    source => "puppet:///modules/cdougan_mongodb_os/mongo.logrotate",
  }

  exec { "disable_transparent_hugepage_enabled":
    command => "/bin/echo never > /sys/kernel/mm/transparent_hugepage/enabled",
    unless  => "/bin/grep -c \"[never]\" /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null",
  }

  exec { "disable_transparent_hugepage_defrag":
    command => "/bin/echo never > /sys/kernel/mm/transparent_hugepage/defrag",
    unless  => "/bin/grep -c \"[never]\" /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null",
  }

  service{"rh-mongodb${version}-mongod":
    enable => true,
    require => Package["rh-mongodb${version}-mongodb-server.x86_64"],
  }

  sysctl { 'fs.file-max':                      ensure => 'present',  permanent => 'yes',  value => '98000', }
  sysctl { 'kernel.pid_max':                   ensure => 'present',  permanent => 'yes',  value => '64000', }
  sysctl { 'kernel.threads-max':               ensure => 'present',  permanent => 'yes',  value => '64000', }

  class { '::limits':
    config => {
      "mongod"  => { 'nproc'  => { soft => '64000'},},},
    use_hiera => false,
  }
}

