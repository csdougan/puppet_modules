class cdougan_was::configure_os::was_service () inherits cdougan_was {
  file {"/etc/init.d/wasserver":
    ensure  => present,
    source  => "puppet:///modules/${module_name}/wasserver",
    owner   => root,
    group   => root,
    mode    => 0744,
  }

  file {"/usr/local/bin/jvmrestart.sh":
    ensure  => present,
    source  => "puppet:///modules/${module_name}/jvmrestart.sh",
    owner   => $was_user,
    group   => $was_group,
    mode    => 0740,
  }

  service {"wasserver":
    enable => true,
    require => File["/etc/init.d/wasserver"],
  }
}
