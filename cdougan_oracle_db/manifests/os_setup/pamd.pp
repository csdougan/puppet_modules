class cdougan_oracle_db::os_setup::pamd () {
    exec {'add entry to pam login':
      path    => '/usr/bin:/usr/sbin:/bin:/sbin',
      command => 'echo "session    required     pam_limits.so" >> /etc/pam.d/login',
      unless  => 'grep session /etc/pam.d/login | grep required | grep pam_limits.so',
    }
}
