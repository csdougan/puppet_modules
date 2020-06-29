class cdougan_oracle_db::db_install::opatch() {
  include cdougan_oracle_db::params
  $opatch_version           = $cdougan_oracle_db::params::opatch_version
  $environment_name         = $cdougan_oracle_db::params::environment_name
  $dbversion                = $cdougan_oracle_db::params::dbversion
  $opatch_archive_file      = $cdougan_oracle_db::params::opatch_archive_file
  $nexus_oracle_opatch_path = $cdougan_oracle_db::params::nexus_oracle_opatch_path

  file {'/tmp/OPatch_old':
    ensure => directory,
    owner => "ora${environment_name}",
    group => "${environment_name}grp",
  }
    
  exec {"Back up existing Opatch Directory":
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => "mv /u01/app/ora${environment_name}/product/${dbversion}/db/OPatch /tmp/OPatch_old/OPatch_pre_${opatch_version}",
    unless  => "test \"$(cat /u01/app/ora${environment_name}/product/${dbversion}/db/OPatch/version.txt|awk -F: '{print $2}')\" == \"${opatch_version}\"",
    creates => "/tmp/OPatch_old/OPatch_pre_${opatch_version}",
    require => File['/tmp/OPatch_old'],
  }

  archive { $opatch_archive_file:
    path         => "/tmp/${opatch_archive_file}",
    source       => "${nexus_oracle_opatch_path}${opatch_archive_file}",
    extract      => true,
    extract_path => "/u01/app/ora${environment_name}/product/${dbversion}/db",
    creates      => "/u01/app/ora${environment_name}/product/${dbversion}/db/OPatch",
    cleanup      => true,
    user         => "ora${environment_name}",
    group        => "${environment_name}grp",
    require      => Exec["Back up existing Opatch Directory"],
  }

}



