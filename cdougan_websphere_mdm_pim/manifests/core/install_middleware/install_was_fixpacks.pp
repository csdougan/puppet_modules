class cdougan_websphere_mdm_pim::core::install_middleware::install_was_fixpacks() inherits cdougan_websphere_mdm_pim {
  cdougan_websphere_mdm_pim::resources::was_fix_install {"Install WAS ${was_flavour} FixPack ${was_fixpack_version}":
    was_install_path   => "${was_install_location}",
    imcl               => "${imcl}",
    nexus_path         => "${nexus_url}",
    nexus_repo         => "${nexus_reponame}",
    wasuser            => "${was_user}",
    wasgroup           => "${was_group}",
    was_version        => "${was_fixpack_version}",
    software_dir       => "${software_location}",
    was_edition        => "ND",
    feature_list       => undef,
    notify             => Exec["Set Permissions on ${was_install_location} post Was ${was_flavour} fixpack ${was_fixpack_version} install"],
  }
  exec {"Set Permissions on ${was_install_location} post Was ${was_flavour} fixpack ${was_fixpack_version} install":
    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
    command     => "chmod 755 -R ${was_install_location}/*; chown -R ${was_user}:${was_group} ${was_install_location}/*",
    refreshonly => true,
  }
}
