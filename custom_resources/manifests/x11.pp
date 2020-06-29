define custom_resources::x11(
) {
  if $title == "disable" {
    $enable_x11 = false
  } else {
    $enable_x11 = true
  }
  $x11_rpm_prereqs = ['xorg-x11-fonts-Type1',
                      'xorg-x11-server-common',
                      'xorg-x11-apps',
                      'xorg-x11-xkb-utils',
                      'xorg-x11-server-Xorg',
                      'xorg-x11-font-utils',
                      'xorg-x11-xauth']

  ensure_resource('service','sshd',{'ensure' => 'running', 'enable' => 'true'})
  
  if $enable_x11 {
    $x11_setting = "yes"
    $rpm_setting = "installed"
  } else {
    $x11_setting = "no"
    $rpm_setting = "absent"
  }

  package { $x11_rpm_prereqs:
    ensure => $rpm_setting,
  }

  ini_setting {'X11Forwarding':
    ensure => present,
    path => '/etc/ssh/sshd_config',
    key_val_separator => ' ',
    setting => 'X11Forwarding',
    value => $x11_setting,
    notify => Service['sshd'],
    require => Package[$x11_rpm_prereqs],
  }

  ini_setting {'X11DisplayOffset':
    ensure => present,
    path => '/etc/ssh/sshd_config',
    key_val_separator => ' ',
    setting => 'X11DisplayOffset',
    value => '10',
    notify => Service['sshd'],
    require => Package[$x11_rpm_prereqs],
  }

  ini_setting {'X11UseLocalhost':
    ensure => present,
    path => '/etc/ssh/sshd_config',
    key_val_separator => ' ',
    setting => 'X11UseLocalhost',
    value => $x11_setting,
    notify => Service['sshd'],
    require => Package[$x11_rpm_prereqs],
  }

  ini_setting {'AllowTcpForwarding':
    ensure => present,
    path => '/etc/ssh/sshd_config',
    key_val_separator => ' ',
    setting => 'AllowTcpForwarding',
    value => $x11_setting,
    notify => Service['sshd'],
    require => Package[$x11_rpm_prereqs],
  }

  ini_setting {'PermitRootLogin':
    ensure => present,
    path => '/etc/ssh/sshd_config',
    key_val_separator => ' ',
    setting => 'PermitRootLogin',
    value => 'no',
    notify => Service['sshd'],
    require => Package[$x11_rpm_prereqs],
  }
}
