class cdougan_was::configure_os::x11 () inherits cdougan_was
{
    $x11_rpm_prereqs = ['xorg-x11-fonts-Type1',
                        'xorg-x11-server-common',
                        'xorg-x11-apps',
                        'xorg-x11-xkb-utils',
                        'xorg-x11-server-Xorg',
                        'xorg-x11-font-utils',
                        'xorg-x11-xauth']

    package { $x11_rpm_prereqs:
      ensure => installed,
    }

    ini_setting {'X11Forwarding':
      ensure => present,
      path => '/etc/ssh/sshd_config',
      key_val_separator => ' ',
      setting => 'X11Forwarding',
      value => 'yes',
      notify => Exec['restart sshd after x11 changes'],
    }

    ini_setting {'X11DisplayOffset':
      ensure => present,
      path => '/etc/ssh/sshd_config',
      key_val_separator => ' ',
      setting => 'X11DisplayOffset',
      value => '10',
      notify => Exec['restart sshd after x11 changes'],
    }

    ini_setting {'X11UseLocalhost':
      ensure => present,
      path => '/etc/ssh/sshd_config',
      key_val_separator => ' ',
      setting => 'X11UseLocalhost',
      value => 'yes',
      notify => Exec['restart sshd after x11 changes'],
    }

    ini_setting {'AllowTcpForwarding':
      ensure => present,
      path => '/etc/ssh/sshd_config',
      key_val_separator => ' ',
      setting => 'AllowTcpForwarding',
      value => 'yes',
      notify => Exec['restart sshd after x11 changes'],
    }

    ini_setting {'PermitRootLogin':
      ensure => present,
      path => '/etc/ssh/sshd_config',
      key_val_separator => ' ',
      setting => 'PermitRootLogin',
      value => 'no',
      notify => Exec['restart sshd after x11 changes'],
    }

    exec {'restart sshd after x11 changes':
      path => '/usr/sbin:/usr/bin:/bin:/sbin',
      command => 'service sshd restart',
      refreshonly => 'true',
    }

}
