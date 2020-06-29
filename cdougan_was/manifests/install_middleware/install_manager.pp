class cdougan_was::install_middleware::install_manager () inherits cdougan_was {
  $install_manager_version    = $im_version
  $install_manager_filesystem = $im_filesystem
  $nexus_path                 = $nexus_url
  $nexus_repo                 = $nexus_reponame
  $websphere_user             = $was_user
  $websphere_group            = $was_group
  $source_dir                 = "${software_location}/IBM-IM-${im_version}"

  class { 'ibm_installation_manager':
    deploy_source => true,
    source_dir    => $source_dir,
    source        => "${nexus_path}/${nexus_repo}/content/IBM/InstallationManager/${install_manager_version}/InstallationManager-${install_manager_version}.zip",
  }

  file {'/etc/profile.d/imcl.sh':
    ensure        => present,
    content       => 'export PATH=$PATH:/opt/IBM/InstallationManager/eclipse/tools',
    require       => Class['ibm_installation_manager'],
  }
  contain 'ibm_installation_manager'

}


