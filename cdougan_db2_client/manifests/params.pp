class cdougan_db2_client::params () {
  include cdougan_db2_client

  $db2_major_version    = $cdougan_db2_client::db2_major_version ? {
    undef   => '10.5',
    default => $cdougan_db2_client::db2_major_version,
  }
  $db2_fp_version    = $cdougan_db2_client::db2_fp_version ? {
    undef   => '7',
    default => $cdougan_db2_client::db2_fp_version,
  }
  $install_db2_client    = $cdougan_db2_client::install_db2_client ? {
    undef   => true,
    default => $cdougan_db2_client::install_db2_client,
  }
  $install_path          = $cdougan_db2_client::install_path ? {
    undef   => '/opt/IBM',
    default => $cdougan_db2_client::install_path,
  }
  $db2c_install_location = $cdougan_db2_client::db2c_install_location ? {
    undef   => "${install_path}/db2",
    default => $cdougan_db2_client::db2c_install_location,
  }
  $software_location     = $cdougan_db2_client::software_location ? {
    undef   => "${install_path}/Installation",
    default => $cdougan_db2_client::software_location,
  }
  $nexus_url             = $cdougan_db2_client::nexus_url ? {
    undef   => 'http://abc-watm-artefactrepo.somehost.co.uk:8081/nexus/service/local/repositories',
    default => $cdougan_db2_client::nexus_url,
  }
  $nexus_reponame        = $cdougan_db2_client::nexus_reponame ? {
    undef   => 'A0520-WebSphere-Application-Server',
    default => $cdougan_db2_client::nexus_reponame,
  }
  $nexus_group_name      = $cdougan_db2_client::nexus_group_name ? {
    undef   => 'IBM',
    default => $cdougan_db2_client::nexus_group_name,
  }
  $db2c_artifact_name    = $cdougan_db2_client::db2c_artifact_name ? {
    undef   => 'DB2_Client',
    default => $cdougan_db2_client::db2c_artifact_name,
  }
  $db2c_version_number   = $cdougan_db2_client::db2c_version_number ? {
    undef   => '10.5.7',
    default => $cdougan_db2_client::db2c_version_number,
  }
  $db2c_package_type     = $cdougan_db2_client::db2c_package_type ? {
    undef   => 'tgz',
    default => $cdougan_db2_client::db2c_package_type,
  }
  $db2_file              = $cdougan_db2_client::db2_file ? {
    undef   => "${db2c_install_location}/V${db2_major_version}",
    default => $cdougan_db2_client::db2_file,
  }
  $db2_client_user       = $cdougan_db2_client::db2_client_user ? {
    undef   => 'db2inst1',
    default => $cdougan_db2_client::db2_client_user,
  }
  $db2_admin_group       = $cdougan_db2_client::db2_admin_group ? {
    undef   => 'db2dba',
    default => $cdougan_db2_client::db2_admin_group,
  }
  $db2_product           = $cdougan_db2_client::db2_product ? {
    undef   => 'RUNTIME_CLIENT',
    default => $cdougan_db2_client::db2_product,
  }
  $db2_licence           = $cdougan_db2_client::db2_licence ? {
    undef   => 'ACCEPT',
    default => $cdougan_db2_client::db2_licence,
  }
  $db2_install_type      = $cdougan_db2_client::db2_install_type ? {
    undef   => 'TYPICAL',
    default => $cdougan_db2_client::db2_install_type,
  }
  $db2_encryption        = $cdougan_db2_client::db2_encryption ? {
    undef   => 'YES',
    default => $cdougan_db2_client::db2_encryption,
  }
  $db2_cli               = $cdougan_db2_client::db2_cli ? {
    undef   => "${db2_file}/bin/db2",
    default => $cdougan_db2_client::db2_cli,
  }
  $install_group         = $cdougan_db2_client::install_group ? {
    undef   => 'platform',
    default => $cdougan_db2_client::install_group,
  }
  $rpm_packages_x64 = $cdougan_db2_client::rpm_packages ? {
    undef   => ['pam','libstdc++'],
    default => $cdougan_db2_client::rpm_packages
  }
  $rpm_packages_i686 = $cdougan_db2_client::rpm_packages ? {
    undef   => ['pam.i686','libstdc++.i686'],
    default => $cdougan_db2_client::rpm_packages
  }

  $db2_response_file  = "v${db2_major_version}fp${db2_fp_version}_rtcl.rsp"

  $db2c_package_url         = "${nexus_url}r=${nexus_reponame}&g=${nexus_group_name}&a=${db2c_artifact_name}&v=${db2c_version_number}&p=${db2c_package_type}"
}
