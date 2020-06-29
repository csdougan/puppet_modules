class cdougan_websphere_mdm_pim::core::install_middleware::install_jdk () inherits cdougan_websphere_mdm_pim {
  cdougan_websphere_mdm_pim::resources::update_jdk {"Update JDK to ${jdk_version}":
    was_install_path   => "${was_install_location}",
    imcl               => "${imcl}",
    nexus_path         => "${nexus_url}",
    nexus_repo         => "${nexus_reponame}",
    jdk_version        => "${jdk_version}",
    software_dir       => "${software_location}",
    wasuser            => "${was_user}",
    wasgroup           => "${was_group}",
    notify             => Exec["Set Permissions on ${was_install_location} post JDK ${jdk_version} install"],
  }
  exec {"Set Permissions on ${was_install_location} post JDK ${jdk_version} install":
    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
    command     => "chmod 755 -R ${was_install_location}/*; chown -R ${was_user}:${was_group} ${was_install_location}/*",
    refreshonly => true,
  }
}
