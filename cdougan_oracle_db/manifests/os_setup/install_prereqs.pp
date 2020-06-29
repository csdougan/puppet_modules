class cdougan_oracle_db::os_setup::install_prereqs () {
  include cdougan_oracle_db::params
  $packagelist = $cdougan_oracle_db::params::packagelist
  $packagelist_i686 = $cdougan_oracle_db::params::packagelist_i686
  package {$packagelist:
    ensure => installed,
  }
  custom_resources::install_i686{$packagelist_i686:
    require => Package[$packagelist],
  }
}
