class cdougan_was::configure_os::lvm () inherits cdougan_was {
if $setup_lvm {
  $websphere_filesystem         = "${install_path}/WebSphere"
  if $operatingsystemmajrelease == '6' {
    $fs_type                    = 'ext4'
    $fs_switch                  = ''
    } else {
    $fs_type                    = 'xfs'
    $fs_switch                  = '-f'
    }
 include ::lvm

  ensure_resource('file', [$im_filesystem,$dumps_location], {
    ensure => directory,
    owner  => $was_user, 
    group  => $was_group,
  })
 
  if $install_path != $im_filesystem {  
    ensure_resource('file',$install_path, {
      ensure => directory,
      owner  => $was_user, 
      group  => $was_group,
    })
  }

  ensure_resource ('file', [$was_root_dir,$software_location], {
    ensure  => directory,
    owner   => $was_user, 
    group   => $was_group,
    require => [File["$install_path"],Mount["$im_filesystem"]],
  })

  physical_volume { "${pv_name}":
    ensure                      => present,
    unless_vg                   => "${ws_vg}",
  }

  volume_group { "${ws_vg}":
    ensure                      => present,
    physical_volumes            => "${pv_name}",
    require                     => Physical_volume["${pv_name}"],
    createonly	                => true,
  }
	
  exec { "create ${im_lv}":
    path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                     => "lvcreate -y -L${im_lv_size} -n ${im_lv} ${ws_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${ws_vg}-${im_lv}",
    creates                     => "/dev/mapper/${ws_vg}-${im_lv}",
    require                     => Volume_group["${ws_vg}"],
}

  exec { "create ${ws_lv}":
    path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                     => "lvcreate -y -L${ws_lv_size} -n ${ws_lv} ${ws_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${ws_vg}-${ws_lv}",
    creates                     => "/dev/mapper/${ws_vg}-${ws_lv}",
    require                     => Volume_group["${ws_vg}"],
  }

  exec { "create ${sd_lv}":
    path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                     => "lvcreate -y -L${sd_lv_size} -n ${sd_lv} ${ws_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${ws_vg}-${sd_lv}",
    creates                     => "/dev/mapper/${ws_vg}-${sd_lv}",
    require                     => Volume_group["${ws_vg}"],
  }

  exec { "create ${dumps_lv}":
    path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                     => "lvcreate -y -L${dumps_lv_size} -n ${dumps_lv} ${ws_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${ws_vg}-${dumps_lv}",
    creates                     => "/dev/mapper/${ws_vg}-${dumps_lv}",
    require                     => Volume_group["${ws_vg}"],
  }

  exec { "create ${profile_lv}":
    path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                     => "lvcreate -y -L${profile_lv_size} -n ${profile_lv} ${ws_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${ws_vg}-${profile_lv}",
    creates                     => "/dev/mapper/${ws_vg}-${profile_lv}",
    require                     => Volume_group["${ws_vg}"],
  }

  exec { "create ${logs_lv}":
    path                        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                     => "lvcreate -y -L${logs_lv_size} -n ${logs_lv} ${ws_vg} && mkfs.${fs_type} ${fs_switch} /dev/mapper/${ws_vg}-${logs_lv}",
    creates                     => "/dev/mapper/${ws_vg}-${logs_lv}",
    require                     => Volume_group["${ws_vg}"],
  }

  mount {"${was_root_dir}":
   ensure                       => mounted,
   device                       => "/dev/mapper/${ws_vg}-${ws_lv}",
   fstype                       => "${fs_type}",
   remounts                     => "true",
   options                      => "defaults",
   require                      => [File["${install_path}/WebSphere"],Exec["create ${ws_lv}"]],
  }

  mount {"${profile_directory}":
   ensure                       => mounted,
   device                       => "/dev/mapper/${ws_vg}-${profile_lv}",
   fstype                       => "${fs_type}",
   remounts                     => "true",
   options                      => "defaults",
   require                      => [File["${profile_directory}"],Exec["create ${profile_lv}"]],
  }

  mount {"${log_directory}":
   ensure  => mounted,
   device  => "/dev/mapper/${ws_vg}-${logs_lv}",
   fstype  => "${fs_type}",
   remounts=> "true",
   options => "defaults",
   require => [File["${log_directory}"],Exec["create ${logs_lv}"]],
  }

  mount {"${dumps_location}":
   ensure   => mounted,
   device   => "/dev/mapper/${ws_vg}-${dumps_lv}",
   fstype   => "${fs_type}",
   remounts => "true",
   options  => "defaults",
   require  => [File["${dumps_location}"],Exec["create ${dumps_lv}"]],
  }

  mount {"${install_path}/$software_dir":
   ensure   => mounted,
   device   => "/dev/mapper/${ws_vg}-${sd_lv}",
   fstype   => "${fs_type}",
   remounts => "true",
   options  => "defaults",
   notify   => Exec["Set Permissions on ${install_path}"],
   require  => [File["${install_path}/$software_dir"],Exec["create ${sd_lv}"]],
  }

  ensure_resource('file', [$profile_directory,$log_directory], {
    ensure  => directory,
    owner   => "${was_user}",
    group   => "${was_group}",
    require => Mount["${was_root_dir}"],
  })

  ensure_resource('file', "${software_location}/logs", {
    ensure  => directory,
    owner   => "${was_user}",
    group   => "${was_group}",
    require => Mount["${software_location}"],
  })

  if $install_path != $im_filesystem {
    exec {"Set Permissions on ${install_path}":
      path        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command     => "chown -R ${was_user}:${was_group} ${install_path}; chmod -R 775 ${install_path}",
      refreshonly => true,
      require     => [Mount["${install_path}/WebSphere"],Mount["${install_path}/$software_dir"]],
    } 
  } else {
    exec {"Set Permissions on WebSphere directory under install_path":
      path        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command     => "chown -R ${was_user}:${was_group} ${install_path}/WebSphere; chmod -R 775 ${install_path}/WebSphere",
      refreshonly => true,
      require     => [Mount["${install_path}/WebSphere"],Mount["${install_path}/$software_dir"]],
    }
  }

  mount {"${im_filesystem}":
   ensure   => mounted,
   device   => "/dev/mapper/${ws_vg}-${im_lv}",
   fstype   => "${fs_type}",
   remounts => "true",
   options  => "defaults",
   require  => [File["${im_filesystem}"],Exec["create ${im_lv}"]],
  }
 
  ensure_resource('file', ["${im_filesystem}/InstallationManager","${im_filesystem}/IMShared"], {
    ensure  => directory,
    owner   => $was_user, 
    group   => $was_group,
    require => Mount["${im_filesystem}"],
  })
  
  exec {"Set Permissions on ${im_filesystem}":
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "chown -R ${was_user}:${was_group} ${im_filesystem}; chmod -R 775 ${im_filesystem}",
    unless  => "ls -ld ${im_filesystem}|cut -d' ' -f3| grep ${was_user}",
    require => File["${im_filesystem}/IMShared"],
  }
  exec {"Set Permissions on ${profile_directory}":
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "chown -R ${was_user}:${was_group} ${profile_directory}; chmod -R 775 ${profile_directory}",
    unless  => "ls -ld ${profile_directory}|cut -d' ' -f3| grep ${was_user}",
    require => Mount["${profile_directory}"],
  }
  exec {"Set Permissions on ${log_directory}":
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "chown -R ${was_user}:${was_group} ${log_directory}; chmod -R 775 ${log_directory}",
    unless  => "ls -ld ${log_directory}|cut -d' ' -f3| grep ${was_user}",
    require => Mount["${log_directory}"],
  }
  exec {"Set Permissions on ${dumps_location}":
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "chown -R ${was_user}:${was_group} ${dumps_location}; chmod -R 775 ${dumps_location}",
    unless  => "ls -ld ${dumps_location}|cut -d' ' -f3| grep ${was_user}",
    require => Mount["${dumps_location}"],
  }
}
}
