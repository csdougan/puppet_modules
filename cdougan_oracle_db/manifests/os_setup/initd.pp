class cdougan_oracle_db::os_setup::initd () {
  file {'/etc/init.d/oracle':
    ensure => present,
    source => 'puppet:///modules/cdougan_oracle_db/etc/init.d/oracle',
    owner  => root,
    group  => root,
    mode   => '0750',
  }

  service {'oracle':
    enable  => true,
    require => File['/etc/init.d/oracle'],
  }
}
