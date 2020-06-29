class cdougan_oracle_db::db_install::get_packages() {
  include cdougan_oracle_db::params
  $install_archive_file_one = $cdougan_oracle_db::params::install_archive_file_one
  $install_archive_file_two = $cdougan_oracle_db::params::install_archive_file_two
  $dbversion                = $cdougan_oracle_db::params::dbversion
  $oracle_home_name         = $cdougan_oracle_db::params::oracle_home_name
  $nexus_oracle_db_path     = $cdougan_oracle_db::params::nexus_oracle_db_path
  $nexus_oracle_opatch_path = $cdougan_oracle_db::params::nexus_oracle_opatch_path

  file {'/tmp/oracle_install':
    ensure => directory,
    mode   => '0777',
    owner  => 'oracle',
    group  => 'dba',
  }

  archive { $install_archive_file_one:
    path         => "/tmp/${install_archive_file_one}",
    source       => "${nexus_oracle_db_path}${install_archive_file_one}",
    extract      => true,
    extract_path => '/tmp/oracle_install',
    creates      => '/tmp/oracle_install/database/runInstaller',
    cleanup      => true,
    user         => 'oracle',
    group        => 'dba',
    before       => Exec['Set DEFAULT_HOME_NAME'],
    require      => File['/tmp/oracle_install'],
  }
  if $install_archive_file_two {
    archive { $install_archive_file_two:
      path         => "/tmp/${install_archive_file_two}",
      source       => "${nexus_oracle_db_path}${install_archive_file_two}",
      extract      => true,
      extract_path => '/tmp/oracle_install',
      creates      => "/tmp/oracle_install/database/stage/Components/oracle.ctx/${dbversion}.0/1/DataFiles/filegroup15.12.1.jar",
      cleanup      => true,
      user         => 'oracle',
      group        => 'dba',
      before       => Exec['Set DEFAULT_HOME_NAME'],
      require      => [
        File['/tmp/oracle_install'],
        Archive[$install_archive_file_one]],
    }
  }

  exec {'Set DEFAULT_HOME_NAME':
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    command     =>  "sed -i 's/DEFAULT_HOME_NAME.*/DEFAULT_HOME_NAME=${oracle_home_name}/g' /tmp/oracle_install/database/install/oraparam.ini",
    unless      => "grep ${oracle_home_name} /tmp/oracle_install/database/install/oraparam.ini",
  }

}
