class cdougan_oracle_db::os_setup::ora_inst_tab () {
  include cdougan_oracle_db::params
  $environment_name = $cdougan_oracle_db::params::environment_name

  file {'/etc/oraInst.loc':
    ensure  => present,
    content => "inventory_loc=/u01/app/oraInventory\ninst_group=${environment_name}grp\n",
    owner   => oracle,
    group   => dba,
    mode    => '0660',
    }

  file {'/etc/oratab':
    ensure => present,
    owner  => "ora${environment_name}",
    group  => "${environment_name}grp",
    mode   => '0664',
  }

  exec {'enable oracle crontab':
    path    => '/usr/bin:/usr/sbin:/sbin:/bin',
    command => 'echo oracle >> /etc/cron.allow',
    unless  => 'grep ^oracle$ /etc/cron.allow',
  }
  exec {"enable ora${environment_name} crontab":
    path    => '/usr/bin:/usr/sbin:/sbin:/bin',
    command => "echo ora${environment_name} >> /etc/cron.allow",
    unless  => "grep ^ora${environment_name} /etc/cron.allow",
  }
  exec {'enable root crontab':
    path    => '/usr/bin:/usr/sbin:/sbin:/bin',
    command => 'echo root >> /etc/cron.allow',
    unless  => 'grep ^root$ /etc/cron.allow',
  }
}
