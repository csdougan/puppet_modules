class cdougan_was::install_middleware::install_jdk () inherits cdougan_was {
  cdougan_was::resources::update_jdk {"Update JDK to ${jdk_version}":
    was_install_path   => "${was_install_location}",
    imcl               => "${imcl}",
    nexus_path         => "${nexus_url}",
    nexus_repo         => "${nexus_reponame}",
    jdk_version        => "${jdk_version}",
    software_dir       => "${software_location}",
    wasuser            => "${was_user}",
    wasgroup           => "${was_group}",
    notify             => Exec["Set Permissions on ${install_path} post JDK ${jdk_version} install"],
  }
  exec {"Set Permissions on ${install_path} post JDK ${jdk_version} install":
    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
    command     => "chmod 755 -R ${install_path}; chown -R ${was_user}:${was_group} ${install_path}",
    refreshonly => true,
    unless      => "grep 'package id' ${was_install_location}/properties/version/installed.xml | grep \"${jdk_product_name}\"",
  }
}
