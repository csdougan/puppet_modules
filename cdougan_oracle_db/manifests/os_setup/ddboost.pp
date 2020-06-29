class cdougan_oracle_db::os_setup::ddboost () {
  include cdougan_oracle_db::params

  $ddboost_user = $cdougan_oracle_db::params::ddboost_user
  $ddboost_host = $cdougan_oracle_db::params::ddboost_host
  $ddboost_path = $cdougan_oracle_db::params::ddboost_path
  $ddboost_password = $cdougan_oracle_db::params::ddboost_password

  package {'emcdbappagent.x86_64':
    ensure => present,
    before => File['/opt/ddbda/config/oracle_ddbda.cfg'],
  }
  file {'/opt/ddbda/config/oracle_ddbda.cfg':
    ensure  => present,
    content => template('cdougan_oracle_db/oracle_ddbda.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['emcdbappagent.x86_64'],
  }
  file {'/opt/ddbda/config/setup_ddboost.sh':
    ensure  => present,
    content => template('cdougan_oracle_db/setup_ddboost.erb'),
    owner   => root,
    group   => root,
    mode    => '0700',
    require => File['/opt/ddbda/config/oracle_ddbda.cfg'],
}

  exec {'/opt/ddbda/config/setup_ddboost.sh':
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => '/opt/ddbda/config/setup_ddboost.sh',
    unless  => 'grep "has been registered in the lockbox" /opt/ddbda/logs/ddbmadmin.messages.log',
    onlyif  => "ping -t 1 -c 2 ${ddboost_host}",
    require => [
      File['/opt/ddbda/config/setup_ddboost.sh'],
      File['/opt/ddbda/config/oracle_ddbda.cfg'],
      Package['emcdbappagent.x86_64']],
  }
}
