define cdougan_db2_client::update_x64() {
  exec {"Update ${name}.x86_64":
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => "yum update -y ${name}.x86_64",
    unless  => "rpm -qa | grep '^${name}-' | grep 'i686'",
  }
}

