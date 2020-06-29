class cdougan_oracle_db::db_install::install() {
  include cdougan_oracle_db::params
  $dbversion        = $cdougan_oracle_db::params::dbversion
  $environment_name = $cdougan_oracle_db::params::environment_name

    oradb::installdb{ $dbversion:
      version           => $dbversion,
      file              => 'oracle_install',
      database_type     => 'EE',
      ora_inventory_dir => '/u01/app',
      oracle_base       => "/u01/app/ora${environment_name}",
      oracle_home       => "/u01/app/ora${environment_name}/product/${dbversion}/db",
      bash_profile      => true,
      user              => "ora${environment_name}",
      group             => "${environment_name}grp",
      group_install     => "${environment_name}grp",
      group_oper        => "${environment_name}grp",
      download_dir      => '/tmp',
      zip_extract       => false,
    }
}
