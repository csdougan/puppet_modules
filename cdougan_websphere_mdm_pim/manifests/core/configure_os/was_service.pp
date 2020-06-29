class cdougan_websphere_mdm_pim::core::configure_os::was_service () inherits cdougan_websphere_mdm_pim {
  file {'/etc/init.d/wasserver':
    ensure => absent,
    #content => template('cdougan_websphere_mdm_pim/wasserver.erb'),
    #owner   => root,
    #group   => root,
    #mode    => 0744,
    notify => Exec['refresh systemd after removal of wasserver'],
  }

  file {'/usr/local/bin/jvmrestart.sh':
    ensure  => present,
    content => template('cdougan_websphere_mdm_pim/jvmrestart.sh.erb'),
    owner   => $was_user,
    group   => $was_group,
    mode    => '0740',
  }

  #  service {"wasserver":
  #  enable => true,
  #  require => File["/etc/init.d/wasserver"],
  #}
  exec {'refresh systemd after removal of wasserver':
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }
}
