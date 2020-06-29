class cdougan_db2_client::local_user_config () {
  include cdougan_db2_client::params

  $db2_client_user       = $cdougan_db2_client::params::db2_client_user
  $db2_admin_group       = $cdougan_db2_client::params::db2_admin_group
  $install_group       = $cdougan_db2_client::params::install_group

  file {"/etc/sudoers.d/${db2_admin_group}":
    content => template('cdougan_db2_client/db2_sudoers.erb'),
    owner   => root,
    group   => root,
    mode    => 0600,
  }

  user {$db2_client_user:
    ensure     => present,
    gid        => $install_group,
    managehome => true,
    expiry     => absent,
  }

  group {$db2_admin_group:
    ensure => present,
  }
  if !defined(Group[$install_group]) {
    group{$install_group: 
      ensure => 'present'
    }
  }

}
