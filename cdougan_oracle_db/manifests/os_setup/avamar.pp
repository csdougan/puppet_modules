class cdougan_oracle_db::os_setup::avamar() {
  if 'abcd' in $::hostname {
    $avamarip = '1.2.3.4'
  } else {
    $avamarip = '1.2.5.6'
  }

  package {'AvamarClient.x86_64':
    ensure  => present,
  }
  package {'AvamarRMAN.x86_64':
    ensure  => present,
    require => Package['AvamarClient.x86_64'],
  }

  file {'/usr/local/avamar/bin/avregister-modified':
    ensure  => present,
    content => template('cdougan_oracle_db/avregister.erb'),
    owner   => root,
    group   => root,
    mode    => '0750',
    notify  => Exec['register avamar'],
  }

  exec {'register avamar':
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    command     => '/usr/local/avamar/bin/avregister-modified',
    require     => [Package['AvamarRMAN.x86_64'],File['/usr/local/avamar/bin/avregister-modified']],
    refreshonly => true,
  }
}
