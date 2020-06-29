class cdougan_mq ( 
  $mq_listener_name = "MYORG1",
  $mq_user = "mqm",
  $mq_uid = "411",
  $mq_group = "mqm",
  $mq_gid = "411",
  $disable_authentication = true,
  $environment_layer = undef,
  $environment_number = "1",
  $single_character_layer_id = undef,
  $application_indentifer = undef,
  $application_instance_number = "1",
  $application_purpose = undef,
  $was_user = "wasuser",
  $mq_outbound_topic_string = "ESITOPIC",
  $queue_names = undef,
  $install_path = "/opt/mqm",
  $base_path = "/var/mqm",
  $mq_software_pv_name = "/dev/sdb",
  $mq_log_pv_name = "/dev/sdc",
  $mq_qmgr_pv_name = "/dev/sdd",
  $mq_data_vg = "datavg",
  $mq_lv = "mqlv",
  $mq_lv_size = "5G",
  $mq_log_lv_size = "10G",
  $mq_qmgr_lv_size = "10G",
  $software_location = "/opt/Installation",
  $software_lv = "softwarelv",
  $software_lv_size = "4G",
  $mq_server_version = "8.0.0.2",
  $mq_fixpack_version = "8.0.0.3",
  $nexus_url                = "http://abc-watm-artefactrepo.somehost.co.uk:8081/nexus/service/local/repositories",
  $nexus_repo                = "A0520-WebSphere-Application-Server",
  $nexus_mq_server_subfolder   = "/IBM/MQ/Server/",
  $nexus_mq_fixpack_subfolder   = "/IBM/MQ/FP/",
  $arch = "x86_64",
) {
  $queue_name_array = split($queue_names,",")
  $qmgr_name = "MQ${application_purpose}${single_character_layer_id}${environment_number}"
  $log_path = "${base_path}/log/${qmgr_name}"
  $qmgr_path = "${base_path}/qmgrs/${qmgr_name}"
  $mq_qmgr_vg = "${qmgr_name}_qmgr_vg"
  $mq_log_vg = "${qmgr_name}_log_vg"
  $mq_channel_main = "MQC_${application_identifier}${environment_layer}${environment_number}_MAIN"
  $mq_channel_dir = "MQC_${application_identifier}${environment_layer}${environment_number}_DIR"
  $mq_channel_bma = "MQC_${application_identifier}${environment_layer}${environment_number}_BMA"
  $mq_outbound_topic_name = "MQT_${application_identifier}${environment_layer}${environment_number}_ESITOPIC"
  $mq_qmgr_lv = "${qmgr_name}lv"
  $mq_log_lv = "${qmgr_name}loglv"
  $nexus_mq_server_path      = "${nexus_url}/${nexus_repo}/content/${nexus_mq_server_subfolder}"
  $nexus_mq_fixpack_path      = "${nexus_url}/${nexus_repo}/content/${nexus_mq_fixpack_subfolder}/"
  $mq_server_archive_file = "Server-${mq_server_version}.tar"
  $mq_fixpack_archive_file = "FP-${mq_fixpack_version}.tar"
  $mq_server_extract_path = "${software_location}/MQ/Server/${mq_server_version}"
  $mq_fixpack_extract_path = "${software_location}/MQ/FP/${mq_fixpack_version}"
  $mq_version_array = split($mq_server_version,'\.')
  $mq_maj_ver = $mq_version_array[0]
  $mq_min_ver = $mq_version_array[1]
  $mq_mic_ver = $mq_version_array[2]
  $mq_fp_ver  = $mq_version_array[3]
  $mq_rpm_version = "${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}-${mq_fp_ver}"
  $mq_fp_version_array = split($mq_fixpack_version,'\.')
  $mq_fp_fp_ver  = $mq_fp_version_array[3]
  $mq_fp_rpm_version = "U${mq_maj_ver}${mq_min_ver}${mq_mic_ver}${mq_fp_fp_ver}-${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}-${mq_fp_fp_ver}"
  $mq_server_install_file_path = "${software_location}/MQ/Server/${mq_server_version}"
  $mq_fixpack_install_file_path = "${software_location}/MQ/FP/${mq_fixpack_version}"
  include ::lvm

  define create_queues (
    $array,
    $software_location,
    $mq_user,
    $mq_group,
    $install_path,
    $qmgr_name,
  ) 
  {
    $queue_name = $name
    $length = inline_template('<%= @array.length %>')
    $index = inline_template('<%= @array.index(@name) %>')

    file {"${software_location}/${queue_name}-queue.def":
      content => template('cdougan_mq/queue.def.erb'),
      owner   => $mq_user,
      group   => $mq_group,
      require => [User[$mq_user],
                Mount[$software_location]],
      notify  => Exec["Create channel definition for ${queue_name}"],
    }
     
    exec {"Create channel definition for ${queue_name}":
      path     => '/bin:/usr/bin:/sbin:/usr/sbin',
      command  => "${install_path}/bin/runmqsc ${qmgr_name} < ${software_location}/${queue_name}-queue.def",
      user     => $mq_user,
      require  => File["${software_location}/${queue_name}-queue.def"],
      refreshonly => true,
    }

    exec {"Set permissions on ${queue_name} for Websphere App Server user account":
      path     => '/bin:/usr/bin:/sbin:/usr/sbin',
      command  => "${install_path}/bin/setmqaut -m ${qmgr_name} -t q -g ${mq_group} -n ${queue_name} +all",
      user     => $mq_user,
      require  => Exec["Create channel definition for ${queue_name}"],
      refreshonly => true,
    }
  }

  if $operatingsystemmajrelease == '6' {
    $fs_type                    = 'ext4'
    $fs_switch                  = ''
    } else {
    $fs_type                    = 'xfs'
    $fs_switch                  = '-f'
    }
    
    group {"$mq_group":
      ensure => present,
      gid => $mq_gid,
    }

    user {"$mq_user":
      ensure => present,
      uid    => $mq_uid,
      gid    => $mq_group,
      managehome => true,
      require => Group[$mq_group],
    }

    physical_volume { "${mq_software_pv_name}":
      ensure                      => present,
      unless_vg                   => "${mq_data_vg}",
    }

    physical_volume { "${mq_log_pv_name}":
      ensure                      => present,
      unless_vg                   => "${mq_log_vg}",
    }

    physical_volume { "${mq_qmgr_pv_name}":
      ensure                      => present,
      unless_vg                   => "${mq_qmgr_vg}",
    }

    volume_group { "${mq_data_vg}":
      ensure                      => present,
      physical_volumes            => "${mq_software_pv_name}",
      require                     => Physical_volume["${mq_software_pv_name}"],
      createonly                  => true,
    }

    volume_group { "${mq_qmgr_vg}":
      ensure                      => present,
      physical_volumes            => "${mq_qmgr_pv_name}",
      require                     => Physical_volume["${mq_qmgr_pv_name}"],
      createonly                  => true,
    }

    volume_group { "${mq_log_vg}":
      ensure                      => present,
      physical_volumes            => "${mq_log_pv_name}",
      require                     => Physical_volume["${mq_log_pv_name}"],
      createonly                  => true,
    }

    exec { "create ${mq_lv}":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "lvcreate -y -L${mq_lv_size} -n ${mq_lv} ${mq_data_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${mq_data_vg}-${mq_lv}",
      creates                     => "/dev/mapper/${mq_data_vg}-${mq_lv}",
      require                     => Volume_group["${mq_data_vg}"],
    }

    exec { "create ${mq_log_lv}":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "lvcreate -y -L${mq_log_lv_size} -n ${mq_log_lv} ${mq_log_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${mq_log_vg}-${mq_log_lv}",
      creates                     => "/dev/mapper/${mq_log_vg}-${mq_log_lv}",
      require                     => Volume_group["${mq_log_vg}"],
    }

    exec { "create ${mq_qmgr_lv}":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "lvcreate -y -L${mq_qmgr_lv_size} -n ${mq_qmgr_lv} ${mq_qmgr_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${mq_qmgr_vg}-${mq_qmgr_lv}",
      creates                     => "/dev/mapper/${mq_qmgr_vg}-${mq_qmgr_lv}",
      require                     => Volume_group["${mq_qmgr_vg}"],
    }

    exec { "create ${software_lv}":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "lvcreate -y -L${software_lv_size} -n ${software_lv} ${mq_data_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${mq_data_vg}-${software_lv}",
      creates                     => "/dev/mapper/${mq_data_vg}-${software_lv}",
      require                     => Volume_group["${mq_data_vg}"],
    }

    exec {"Create mount point for ${install_path}":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "mkdir -p ${install_path}",
      creates                     => $install_path,
    }

    exec {"Create mount point for ${software_location}":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "mkdir -p ${software_location}",
      creates                     => $software_location,
    }

   mount {"${install_path}":
     ensure                       => mounted,
     device                       => "/dev/mapper/${mq_data_vg}-${mq_lv}",
     fstype                       => "${fs_type}",
     remounts                     => "true",
     options                      => "defaults",
     require                      => [Exec["Create mount point for ${install_path}"],
                                      Exec["create ${mq_lv}"]],
    }

   mount {"${software_location}":
     ensure                       => mounted,
     device                       => "/dev/mapper/${mq_data_vg}-${software_lv}",
     fstype                       => "${fs_type}",
     remounts                     => "true",
     options                      => "defaults",
     require                      => [Exec["Create mount point for ${software_location}"],
                                      Exec["create ${software_lv}"]],
     notify                       => Exec["Set permissions on ${software_location}"],
    }

    file {$base_path:
      ensure                      => directory,
      owner                       => $mq_user,
      group                       => $mq_group,
    }

    exec {"Create mount point for ${log_path}":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "mkdir -p ${log_path}",
      user                        => $mq_user,
      creates                     => $log_path,
      require                     => File[$base_path],
    }
 
    exec {"Create mount point for ${qmgr_path}":
      path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                     => "mkdir -p ${qmgr_path}",
      user                        => $mq_user,
      creates                     => $qmgr_path,
      require                     => File[$base_path],
    }
 
   mount {"${log_path}":
     ensure                       => mounted,
     device                       => "/dev/mapper/${mq_log_vg}-${mq_log_lv}",
     fstype                       => "${fs_type}",
     remounts                     => "true",
     options                      => "defaults",
     require                      => [Exec["Create mount point for ${log_path}"],
                                      Exec["create ${mq_log_lv}"]],
   }

   mount {"${qmgr_path}":
     ensure                       => mounted,
     device                       => "/dev/mapper/${mq_qmgr_vg}-${mq_qmgr_lv}",
     fstype                       => "${fs_type}",
     remounts                     => "true",
     options                      => "defaults",
     require                      => [Exec["Create mount point for ${qmgr_path}"],
                                      Exec["create ${mq_qmgr_lv}"]],
     notify                       => Exec["Set permissions on ${base_path}"],
   }


   exec {"Set permissions on ${base_path}":
     path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
     command                     => "chown -R ${mq_user}:${mq_group} ${base_path}",
     require                     => [Mount["${log_path}"],
                                     Mount["${qmgr_path}"],
                                     User[$mq_user]],
     refreshonly                 => true,
   }

   exec {"Set permissions on ${install_path}":
     path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
     command                     => "chown -R ${mq_user}:${mq_group} ${install_path}",
     require                     => [Mount["${install_path}"],
                                     User[$mq_user]],
     refreshonly                 => true,
   }

   exec {"Set permissions on ${software_location}":
    path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                     => "chown -R ${mq_user}:${mq_group} ${software_location}",
    require                     => [Mount[$software_location],
                                     User[$mq_user]],
    refreshonly                 => true,
  } 

  file {"${software_location}/MQ":
    ensure          => directory,
    owner           => $mq_user,
    group           => $mq_group,
    require         => [Mount[$software_location],
                        Exec["Set permissions on ${software_location}"],
                        User[$mq_user]],
  }
  file {"${software_location}/MQ/Server":
    ensure          => directory,
    owner           => $mq_user,
    group           => $mq_group,
    require         => [File["${software_location}/MQ"],
                        Exec["Set permissions on ${software_location}"],
                        User[$mq_user]],
  }
  file {$mq_server_install_file_path:
    ensure          => directory,
    owner           => $mq_user,
    group           => $mq_group,
    require         => [File["${software_location}/MQ/Server"],
                        Exec["Set permissions on ${software_location}"],
                        User[$mq_user]],
  }

  file {"${software_location}/MQ/FP":
    ensure          => directory,
    owner           => $mq_user,
    group           => $mq_group,
    require         => [File["${software_location}/MQ"],
                        Exec["Set permissions on ${software_location}"],
                        User[$mq_user]],
  }
  file {$mq_fixpack_install_file_path:
    ensure          => directory,
    owner           => $mq_user,
    group           => $mq_group,
    require         => [File["${software_location}/MQ/FP"],
                        Exec["Set permissions on ${software_location}"],
                        User[$mq_user]],
  }

  archive { "${mq_server_archive_file}":
    path            => "${software_location}/${mq_server_archive_file}",
    source          => "${nexus_mq_server_path}/${mq_server_version}/${mq_server_archive_file}",
    extract         => true,
    extract_path    => "${mq_server_extract_path}",
    creates         => "${mq_server_extract_path}/server/mqlicense.sh",
    cleanup         => true,
    user            => "${mq_user}",
    group           => "${mq_group}",
    require         => [File["${mq_server_extract_path}"],
                        Mount["${software_location}"],
                        User[$mq_user]],
  }

  archive { "${mq_fixpack_archive_file}":
    path            => "${software_location}/${mq_fixpack_archive_file}",
    source          => "${nexus_mq_fixpack_path}/${mq_fixpack_version}/${mq_fixpack_archive_file}",
    extract         => true,
    extract_path    => "${mq_fixpack_extract_path}",
    creates         => "${mq_fixpack_extract_path}/crtmqfp",
    cleanup         => true,
    user            => "${mq_user}",
    group           => "${mq_group}",
    require         => [File["${mq_fixpack_extract_path}"],
                        Mount["${software_location}"],
                        User[$mq_user]],
  }

  sysctl {'fs.file-max':            ensure => 'present',  permanent => 'yes',  value => '524288', }

  class { '::limits':
    config => {
      "${mq_user}"  => { 'nofile'  => { soft => '10240'  , hard => '10240',},},
      "${mq_user}"  => { 'nproc'  => { soft => '4096'  , hard => '4096',},},
    },
    use_hiera => false,
    require => User[$mq_user],
  } 

  exec {"Add PATH line to $mq_user bashrc":
    path            => '/bin:/usr/bin:/sbin:/usr/sbin',
    command         => "echo 'export PATH=\$PATH:/opt/mqm/bin' >> /home/$mq_user/.bashrc",
    user            => $mq_user,
    unless          => "grep '/opt/mqm' /home/$mq_user/.bashrc",
    require         => User[$mq_user],
  }

  exec {"Accept MQ Licence File":
    path            => '/bin:/usr/bin:/sbin:/usr/sbin',
    command         => "bash -c '${software_location}/MQ/Server/${mq_server_version}/mqlicense.sh -accept'",
    user            => $mq_user,
    refreshonly     => true,
    require         => [Archive[$mq_server_archive_file],
                        User[$mq_user]],
  }

  file {"/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}":
    ensure          => directory,
    owner           => $mq_user,
    group           => $mq_group,
    require         => [User[$mq_user],
                        Exec["Accept MQ Licence File"]],
  }
  
  file {"/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license":
    ensure          => directory,
    owner           => $mq_user,
    group           => $mq_group,
    require         => [User[$mq_user],
                        File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}"]],
  }
 
  file {"/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat":
    ensure          => present,
    source          => "puppet:///modules/cdougan_mq/mq_license_status.dat",
    owner           => $mq_user,
    group           => $mq_group,
    require         => [User[$mq_user],
                        File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license"]],
  }
  
  package {"MQSeriesRuntime-${mq_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_server_install_file_path}/server/MQSeriesRuntime-${mq_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Exec["Set permissions on ${base_path}"],
                 Exec["Set permissions on ${install_path}"]],
  }

  package {"MQSeriesServer-${mq_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_server_install_file_path}/server/MQSeriesServer-${mq_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesRuntime-${mq_rpm_version}.${arch}.rpm"]],
  }


  package {"MQSeriesClient-${mq_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_server_install_file_path}/server/MQSeriesClient-${mq_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesServer-${mq_rpm_version}.${arch}.rpm"]],
  }

  package {"MQSeriesGSKit-${mq_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_server_install_file_path}/server/MQSeriesGSKit-${mq_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesJRE-${mq_rpm_version}.${arch}.rpm"],
                 Package["MQSeriesServer-${mq_rpm_version}.${arch}.rpm"]],
  }

  package {"MQSeriesJava-${mq_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_server_install_file_path}/server/MQSeriesJava-${mq_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesServer-${mq_rpm_version}.${arch}.rpm"]],
  }

  package {"MQSeriesJRE-${mq_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_server_install_file_path}/server/MQSeriesJRE-${mq_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesServer-${mq_rpm_version}.${arch}.rpm"]],
  }

  package {"MQSeriesSDK-${mq_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_server_install_file_path}/server/MQSeriesSDK-${mq_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesServer-${mq_rpm_version}.${arch}.rpm"]],
  }

  package {"MQSeriesRuntime-${mq_fp_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_fixpack_install_file_path}/MQSeriesRuntime-${mq_fp_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesRuntime-${mq_rpm_version}.${arch}.rpm","MQSeriesSDK-${mq_rpm_version}.${arch}.rpm","MQSeriesJRE-${mq_rpm_version}.${arch}.rpm","MQSeriesJava-${mq_rpm_version}.${arch}.rpm","MQSeriesGSKit-${mq_rpm_version}.${arch}.rpm","MQSeriesClient-${mq_rpm_version}.${arch}.rpm"]],
  }

  package {"MQSeriesServer-${mq_fp_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_fixpack_install_file_path}/MQSeriesServer-${mq_fp_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesRuntime-${mq_fp_rpm_version}.${arch}.rpm"]],
  }
  package {"MQSeriesClient-${mq_fp_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_fixpack_install_file_path}/MQSeriesClient-${mq_fp_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesServer-${mq_fp_rpm_version}.${arch}.rpm"]],
    before  => Exec["Create Queue Manager $qmgr_name"],
  }

  package {"MQSeriesGSKit-${mq_fp_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_fixpack_install_file_path}/MQSeriesGSKit-${mq_fp_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesJRE-${mq_rpm_version}.${arch}.rpm"],
                 Package["MQSeriesServer-${mq_fp_rpm_version}.${arch}.rpm"]],
  }

  package {"MQSeriesJava-${mq_fp_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_fixpack_install_file_path}/MQSeriesJava-${mq_fp_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesServer-${mq_fp_rpm_version}.${arch}.rpm"]],
  }

  package {"MQSeriesJRE-${mq_fp_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_fixpack_install_file_path}/MQSeriesJRE-${mq_fp_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesServer-${mq_fp_rpm_version}.${arch}.rpm"]],
  }

  package {"MQSeriesSDK-${mq_fp_rpm_version}.${arch}.rpm":
    provider => rpm,
    ensure   => installed,
    source   => "${mq_fixpack_install_file_path}/MQSeriesSDK-${mq_fp_rpm_version}.${arch}.rpm",
    install_options => {'--prefix' => $install_path},
    require  => [File["/tmp/mq_license_${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}/license/status.dat"],
                 Package["MQSeriesServer-${mq_fp_rpm_version}.${arch}.rpm"]],
  }


  if $disable_authentication {
    exec {"Add MQSNOAUT line to $mq_user bashrc":
      path            => '/bin:/usr/bin:/sbin:/usr/sbin',
      command         => "echo 'export MQSNOAUT=NO' >> /home/$mq_user/.bashrc",
      user            => $mq_user,
      unless          => "grep 'MQSNOAUT=NO' /home/$mq_user/.bashrc",
      require         => User[$mq_user],
      before          => Exec["Create Queue Manager $qmgr_name"],       
    }
  } 

  exec {"Create Queue Manager $qmgr_name":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "${install_path}/bin/crtmqm $qmgr_name",
    user     => $mq_user,
    creates => "${base_path}/qmgrs/${qmgr_name}/qmstatus.ini",
    require => Package["MQSeriesServer-${mq_fp_rpm_version}.${arch}.rpm"],
    notify => [Exec["Start Queue Manager $qmgr_name"],Exec["Set ${was_user} Permissions for Queue Manager $qmgr_name"]],
  }

  exec {"Set LogFilePages for QM":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "sed -i 's/LogFilePages.*/LogFilePages=65535/g' ${base_path}/qmgrs/${qmgr_name}/qm.ini",
    unless   => "grep 'LogFilePages=65535' ${base_path}/qmgrs/${qmgr_name}/qm.ini",
    require  => Exec["Create Queue Manager $qmgr_name"],
    before   => Exec["Start Queue Manager $qmgr_name"], 
  }

  exec {"Start Queue Manager $qmgr_name":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "${install_path}/bin/strmqm $qmgr_name",
    user     => $mq_user,
    refreshonly => true,
    require => Exec["Create Queue Manager $qmgr_name"],
  }

  exec {"Set ${was_user} Permissions for Queue Manager $qmgr_name":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "${install_path}/bin/setmqaut -m ${qmgr_name} -t qmgr -g ${mq_group} +all",
    user     => $mq_user,
    refreshonly => true,
    require => Exec["Start Queue Manager $qmgr_name"],
  }


  file {"${software_location}/listener.mqsc":
    content => template('cdougan_mq/listener.mqsc.erb'),
    owner   => $mq_user,
    group   => $mq_group,
    require => [User[$mq_user],
                Mount[$software_location]],
    notify  => Exec["Create listener"],
  }

  exec {"Create listener":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "${install_path}/bin/runmqsc ${qmgr_name} < ${software_location}/listener.mqsc",
    user     => $mq_user,
    require  => [File["${software_location}/listener.mqsc"],
                Exec["Start Queue Manager $qmgr_name"],
                Exec["Set ${was_user} Permissions for Queue Manager $qmgr_name"]],
    refreshonly => true,
  }

  file {"${software_location}/start_listener.mqsc":
    content => template('cdougan_mq/start_listener.mqsc.erb'),
    owner   => $mq_user,
    group   => $mq_group,
    require => [User[$mq_user],
                Mount[$software_location]],
    notify  => Exec["Start listener"],
  }

  exec {"Start listener":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "${install_path}/bin/runmqsc ${qmgr_name} < ${software_location}/start_listener.mqsc",
    user     => $mq_user,
    require  => [File["${software_location}/start_listener.mqsc"],
                 Exec["Create listener"],
                 Exec["Set ${was_user} Permissions for Queue Manager $qmgr_name"]],
    refreshonly => true,
  }

  file {"${software_location}/channel.def":
    content => template('cdougan_mq/channel.def.erb'),
    owner   => $mq_user,
    group   => $mq_group,
    require => [User[$mq_user],
                Exec["Start Queue Manager $qmgr_name"],
                Mount[$software_location]],
    notify  => Exec["Create channel definitions"],
  }

  exec {"Create channel definitions":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "${install_path}/bin/runmqsc ${qmgr_name} < ${software_location}/channel.def",
    user     => $mq_user,
    require  => [File["${software_location}/channel.def"],
                 Exec["Start Queue Manager $qmgr_name"]],
    notify   => [Exec["Set permissions on Channel ${mq_channel_main} for WAS user"],
                 Exec["Set permissions on Channel ${mq_channel_dir} for WAS user"]],
    refreshonly => true,
  }

  exec {"Set permissions on Channel ${mq_channel_main} for WAS user":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    user     => $mq_user,
    command  => "${install_path}/bin/setmqaut -m ${qmgr_name} -t channel -g ${mq_group} -n ${mq_channel_main} +all",
    require  => Exec["Create channel definitions"], 
    refreshonly => true,
  }

  exec {"Set permissions on Channel ${mq_channel_dir} for WAS user":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    user     => $mq_user,
    command  => "${install_path}/bin/setmqaut -m ${qmgr_name} -t channel -g ${mq_group} -n ${mq_channel_dir} +all",
    require  => Exec["Create channel definitions"], 
    refreshonly => true,
  }

  create_queues {$queue_name_array: 
    array               => $queue_name_array,
    software_location  => $software_location,
    mq_user             => $mq_user,
    mq_group            => $mq_group,
    install_path        => $install_path,
    qmgr_name           => $qmgr_name,
    require => [User[$mq_user],
                Mount[$software_location],
                Exec["Start Queue Manager $qmgr_name"]],
  }

  file {"${software_location}/topic.mqsc":
    content => template('cdougan_mq/topic.erb'),
    owner   => $mq_user,
    group   => $mq_group,
    require => [User[$mq_user],
                Mount[$software_location]],
    notify  => Exec["Create Topic"],
  }

  exec {"Create Topic":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "${install_path}/bin/runmqsc ${qmgr_name} < ${software_location}/topic.mqsc",
    user     => $mq_user,
    require  => [File["${software_location}/topic.mqsc"],
                Exec["Start Queue Manager $qmgr_name"]],
    refreshonly => true,
    notify    => Exec["Set permissions on Topic for WAS user"],
  }

  exec {"Set permissions on Topic for WAS user":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    user     => $mq_user,
    command  => "${install_path}/bin/setmqaut -m ${qmgr_name} -t topic -g ${mq_group} -n ${mq_outbound_topic_name} +all",
    require  => Exec["Create Topic"], 
    refreshonly => true,
  }

  file {"${software_location}/qmgr.mqsc":
    source => "puppet:///modules/cdougan_mq/qmgr_security",
    owner  => $mq_user,
    group  => $mq_group,
    ensure => present,
    require => [Mount[$software_location],
                User[$mq_user]],
    notify  => Exec["Update QMGR Security"],
  }

  exec {"Update QMGR Security":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "${install_path}/bin/runmqsc ${qmgr_name} < ${software_location}/qmgr.mqsc",  
    user     => $mq_user,
    refreshonly => true,
    require  => [File["${software_location}/qmgr.mqsc"],
                 User[$mq_user],
                 Exec["Start Queue Manager $qmgr_name"],
                 Exec["Set ${was_user} Permissions for Queue Manager $qmgr_name"]], 
  }
  file {"${software_location}/mq_security.mqsc":
    content => template('cdougan_mq/mq_security.erb'),
    owner   => $mq_user,
    group   => $mq_group,
    require => [User[$mq_user],
                Mount[$software_location]],
  }

  exec {"Set Channel Auth Security":
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "${install_path}/bin/runmqsc ${qmgr_name} < ${software_location}/mq_security.mqsc",
    user     => $mq_user,
    refreshonly => true,
    require  => [File["${software_location}/mq_security.mqsc"],
                 User[$mq_user],
                 Exec["Start Queue Manager $qmgr_name"],
                 Exec["Set ${was_user} Permissions for Queue Manager $qmgr_name"],
                 Exec["Set permissions on Channel ${mq_channel_main} for WAS user"],
                 Exec["Set permissions on Channel ${mq_channel_dir} for WAS user"]],
  }
 


}
