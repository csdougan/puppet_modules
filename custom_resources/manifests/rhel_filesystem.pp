# Resource to create filesystems, including setting up mount point, 
# creating lvs, formatting filesystems, adding to fstab, mounting and 
# setting permissions post-mount.    Also added condition to handle docker
# containers by skipping lv creation steps
define custom_resources::rhel_filesystem (
  $volume_group  = undef,
  $lv_name       = undef,
  $mount_options = defaults,
  $owner         = undef,
  $group         = undef,
  $mode          = undef,
  $fstype        = undef,
  $size          = undef,
  $recurse_perms = false,
  $recurse_depth = 1,
) {
  if ! $fstype {
    if $::operatingsystemmajrelease == '6' {
        $fs_type = 'ext4'
    } else {
        $fs_type = 'xfs'
    }
  } else {
    $fs_type = $fstype
  }

  if $fs_type == 'xfs' {
    $fs_switch = '-f'
  } else {
    $fs_switch = ''
  }

  if '%' in $size {
    $size_flag = '-l'
  } else {
    $size_flag = '-L'
  }
  exec {"Create mountpoint for ${title}":
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "mkdir -p ${title}",
    creates => $title,
  }
  if $recurse_perms {
    $mount_array = split($title,'/')
    $recursive_perm_change_start_point= inline_template('<%= @mount_array.delete_if {|fspart| @mount_array.index(fspart) > @recurse_depth.to_i}.join("/") %>')

    if $owner != undef {
      exec {"Recursively set owner for ${recursive_perm_change_start_point}":
        path    => '/bin:/usr/bin:/sbin:/usr/sbin',
        command => "chown -R ${owner} ${recursive_perm_change_start_point}",
        unless  => "stat ${recursive_perm_change_start_point} --printf=%U|grep ${owner}",
        require => [
          Exec["Create mountpoint for ${title}"],
          Mount[$title]],
        before  => File[$title],
      }
    }

    if $group != undef {
      exec {"Recursively set group for ${recursive_perm_change_start_point}":
        path    => '/bin:/usr/bin:/sbin:/usr/sbin',
        command => "chgrp -R ${group} ${recursive_perm_change_start_point}",
        unless  => "stat ${recursive_perm_change_start_point} --printf=%G|grep ${group}",
        require => [
          Exec["Create mountpoint for ${title}"],
          Mount[$title]],
        before  => File[$title],
      }
    }
  }

  if ! $::dockerenv {
    exec { "create ${lv_name}":
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      command =>
        "lvcreate -y ${size_flag}${size} -n ${lv_name} ${volume_group}",
      creates => "/dev/mapper/${volume_group}-${lv_name}",
      notify  => Exec["format ${lv_name}"],
      onlyif  => "vgs ${volume_group}",
      before  => File[$title],
    }
    exec { "format ${lv_name}":
      path        => '/bin:/usr/bin:/sbin:/usr/sbin',
      command     =>
        "mkfs.${fs_type} ${fs_switch} /dev/mapper/${volume_group}-${lv_name}",
      refreshonly => true,
      onlyif      => "vgs ${volume_group}",
      require     => Exec["create ${lv_name}"],
      before      => File[$title],
    }
    mount {$title:
      ensure   => mounted,
      device   => "/dev/mapper/${volume_group}-${lv_name}",
      fstype   => $fs_type,
      remounts => true,
      options  => $mount_options,
      require  => [
        Exec["Create mountpoint for ${title}"],
        Exec["create ${lv_name}"],
        Exec["format ${lv_name}"]
      ],
      before   => File[$title],
    }
  }
  file {$title:
    ensure  => directory,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    require => Exec["Create mountpoint for ${title}"],
  }
}

