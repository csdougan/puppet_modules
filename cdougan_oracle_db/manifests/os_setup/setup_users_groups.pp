class cdougan_oracle_db::os_setup::setup_users_groups () {
  include cdougan_oracle_db::params
  $environment_name = $cdougan_oracle_db::params::environment_name
  $oracle_sid = $cdougan_oracle_db::params::oracle_sid

  if ($environment_name != undef)
  {
    group {'dba':
      ensure           => present,
    }

    group {"${environment_name}grp":
      ensure           => present,
    }

    user {'oracle':
      ensure           => present,
      gid              => 'dba',
      comment          => 'Oracle User',
      groups           => "${environment_name}grp",
      expiry           => absent,
      password_max_age => -1,
      notify           => Exec['Set Initial Oracle Password'],
      require          => [
        Group["${environment_name}grp"],
        Group['dba']],
    }

    group {'oracle':
      ensure  => absent,
      require => User['oracle'],
    }


    exec {'Set Initial Oracle Password':
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      command     => 'echo oracle | passwd --stdin oracle',
      subscribe   => User['oracle'],
      refreshonly => true,
    }

    file {'/home/oracle':
      ensure  => directory,
      owner   => 'oracle',
      group   => 'dba',
      require => User['oracle'],
    }

    file {'/home/oracle/.bash_profile':
      content => template("${module_name}/oracle_bash_profile.erb"),
      mode    => '0644',
      owner   => 'oracle',
      group   => 'dba',
      require => File['/home/oracle'],
    }

    file {"/home/ora${environment_name}/.bash_profile":
      content => template("${module_name}/oralayer_bash_profile.erb"),
      mode    => '0644',
      owner   => "ora${environment_name}",
      group   => "${environment_name}grp",
      require => File["/home/ora${environment_name}"],
    }

    file {"/home/ora${environment_name}":
      ensure  => directory,
      owner   => "ora${environment_name}",
      group   => "${environment_name}grp",
      require => [
        File['/home/oracle'],
        User["ora${environment_name}"]],
    }

    user {"ora${environment_name}":
      ensure           => present,
      gid              => "${environment_name}grp",
      comment          => "Ora${environment_name} User",
      groups           => 'dba',
      password_max_age => -1,
      notify           => Exec["Set Initial Ora${environment_name} Password"],
      require          => [
        Group["${environment_name}grp"],
        Group['dba']],
    }

    exec {"Set Initial Ora${environment_name} Password":
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      command     => "echo ora${environment_name} | passwd --stdin ora${environment_name}",
      subscribe   => User["ora${environment_name}"],
      refreshonly => true,
    }
  }
}
