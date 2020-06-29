class cdougan_websphere_mdm_pim::core::install_mdm::unpack_mdmce (
) inherits cdougan_websphere_mdm_pim {
  file {$mdm_extract_path:
    ensure => directory,
    owner  => $was_user,
    group  => $was_group,
    mode   => 0750,
  }
  archive {"${software_location}/${mdm_artifact_name}-${mdm_version_number}.zip":
    source          => "${nexus_url}/${nexus_reponame}/content/${nexus_group_name}/${mdm_artifact_name}/${mdm_version_number}/${mdm_artifact_name}-${mdm_version_number}.zip",
    extract         => true,
    extract_path    => $mdm_extract_path,
    creates         => "${mdm_extract_path}/Collaboration.tar.gz",
    cleanup         => true,
    user            => $was_user,
    group           => $was_group,
    require         => File[$mdm_extract_path],
  }

  archive { "${mdm_extract_path}/Collaboration.tar.gz":
    path            => "${mdm_extract_path}/Collaboration.tar.gz",
    extract         => true,
    extract_path    => $mdm_extract_path,
    creates         => "${mdm_extract_path}/CollaborationServer/disk1/ad/repository.config",
    cleanup         => false,
    user            => $was_user,
    group           => $was_group,
    require         => Archive["${software_location}/${mdm_artifact_name}-${mdm_version_number}.zip"],
  }

}

