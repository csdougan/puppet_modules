class cdougan_websphere_mdm_pim::core::install_middleware::install_manager () inherits cdougan_websphere_mdm_pim {
  $install_manager_version    = $im_version
  $install_manager_filesystem = $ibm_filesystem
  $nexus_path                 = $nexus_url
  $nexus_repo                 = $nexus_reponame
  $websphere_user             = $was_user
  $websphere_group            = $was_group
  $source_dir                 = "${software_location}/IBM-IM-${im_version}"


  class { 'ibm_installation_manager':
    deploy_source => true,
    source_dir    => $source_dir,
    source        => "${nexus_path}/${nexus_repo}/content/IBM/InstallationManager/${install_manager_version}/InstallationManager-${install_manager_version}.zip",
    #    notify        => Exec['Change Permissions on the Install Manager directory'],
  }
  #exec {'Change Permissions on the Install Manager directory':
  #  path          => "/bin:/usr/bin:/sbin:/usr/sbin",
  #  command       => "chmod 755 $install_manager_filesystem -R; chown -R root:root $install_manager_filesystem",
  #  refreshonly   => true,
  #  require       => Class['ibm_installation_manager'],
  #}

  file {'/etc/profile.d/imcl.sh':
    ensure        => present,
    content       => 'export PATH=$PATH:/opt/IBM/InstallationManager/eclipse/tools',
    require       => Class['ibm_installation_manager'],
  }
  contain 'ibm_installation_manager'
}


