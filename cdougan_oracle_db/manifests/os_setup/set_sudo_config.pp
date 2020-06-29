class cdougan_oracle_db::os_setup::set_sudo_config () {
  include cdougan_oracle_db::params
  $environment_name = $cdougan_oracle_db::params::environment_name

    file {'/etc/sudoers.d/oracle':
      ensure  => present,
      content => "ora${environment_name}\tALL=(ALL)\tNOPASSWD: ALL\noracle\tALL=(ALL)\tNOPASSWD: ALL\nora${environment_name}\tALL=(oracle)\tNOPASSWD: ALL\noracle\tALL=(ora${environment_name})\tNOPASSWD: ALL\noracle\tALL = (root)\tNOPASSWD: /bin/su - ora*\n",
      mode    => '0440',
    }
}
