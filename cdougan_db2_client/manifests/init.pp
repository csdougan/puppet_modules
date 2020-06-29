# Install DB2 Client
class cdougan_db2_client (
  $install_db2_client    = undef,
  $db2c_install_location = undef,
  $software_location     = undef,
  $nexus_url             = undef,
  $nexus_reponame        = undef,
  $nexus_group_name      = undef,
  $db2c_artifact_name    = undef,
  $db2c_version_number   = undef,
  $db2c_package_type     = undef,
  $db2_file              = undef,
  $db2_client_user       = undef,
  $install_path          = undef,
  $db2_product           = undef,
  $db2_licence           = undef,
  $db2_install_type      = undef,
  $db2_encryption        = undef,
  $db2_cli               = undef,
  $install_group         = undef,
  $rpm_packages          = undef,

) {

    class {'::cdougan_db2_client::local_user_config':
    }
    class {'::cdougan_db2_client::ad_user_config':
    }
    class {'::cdougan_db2_client::install':
      require => Class['::cdougan_db2_client::local_user_config']
    }
}
