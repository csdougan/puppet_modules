class cdougan_was::install_middleware::install_was_release_version () inherits cdougan_was {
  cdougan_was::resources::was_install {"Install Was ${was_flavour} ${was_install_version}":
    was_install_path   => "${was_install_location}",
    imcl               => "${imcl}",
    nexus_path         => "${nexus_url}",
    nexus_repo         => "${nexus_reponame}",
    wasuser            => "${was_user}",
    wasgroup           => "${was_group}",
    was_version        => "${was_install_version}",
    was_edition        => "$was_flavour",
    software_dir       => "${software_location}",
    feature_list       => "${was_features}",
    before             => Exec["Set Permissions on ${install_path} post Was ${was_flavour} ${was_install_version} install"],
  }
  exec {"Set Permissions on ${install_path} post Was ${was_flavour} ${was_install_version} install":
    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
    command     => "chmod 755 -R ${install_path}; chown -R ${was_user}:${was_group} ${install_path}",
    unless      => "grep 'package id' ${was_install_location}/properties/version/installed.xml | grep \"${was_product_name}\"",
  }

}
