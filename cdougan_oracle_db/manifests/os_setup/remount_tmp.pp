class cdougan_oracle_db::os_setup::remount_tmp () {
  exec {'backup fstab':
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => 'cp /etc/fstab /etc/fstab.old',
    onlyif  => 'grep /tmp /etc/fstab',
    creates => '/etc/fstab.old',
  }

  exec {'make tmp executable':
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => "sed -i 's/defaults,nodev,nosuid,noexec/defaults/g' /etc/fstab",
    unless  => 'grep tmp /etc/fstab | grep mapper |grep -v noexec | grep defaults',
    onlyif  => 'grep /tmp /etc/fstab',
    require => Exec['backup fstab'],
    notify  => Exec['remount tmp'],
  }

  exec {'remount tmp':
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    command     => 'mount -o remount /tmp',
    onlyif      => 'grep /tmp /etc/fstab',
    refreshonly => true,
    require     => Exec['make tmp executable'],
  }
}
