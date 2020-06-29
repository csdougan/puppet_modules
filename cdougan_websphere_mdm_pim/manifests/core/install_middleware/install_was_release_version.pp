class cdougan_websphere_mdm_pim::core::install_middleware::install_was_release_version () inherits cdougan_websphere_mdm_pim {

  exec {"Umount $profile_fs temporarily":
    path               => "/usr/bin:/bin:/usr/sbin:/sbin",
    command            => "umount ${profile_fs}; rm -rf ${profile_fs}",
    creates            => "${was_install_location}/bin",
    before             => Pit_websphere_mdm_pim::Resources::Was_install["Install Was ${was_flavour} ${was_install_version}"],
  }

  cdougan_websphere_mdm_pim::resources::was_install {"Install Was ${was_flavour} ${was_install_version}":
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
    notify             => Exec["Set Permissions on ${was_install_location} post Was ${was_flavour} ${was_install_version} install"],
  }
  
  exec {"Remount $profile_fs post-install":
    path               => "/usr/bin:/bin:/usr/sbin:/sbin",
    command            => "mkdir -p ${profile_fs}; mount ${profile_fs}",
    creates            => $profile_fs,
    require            => Pit_websphere_mdm_pim::Resources::Was_install["Install Was ${was_flavour} ${was_install_version}"],
  }
 
  exec {"Set Permissions on ${was_install_location} post Was ${was_flavour} ${was_install_version} install":
    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
    command     => "chmod 755 -R ${was_install_location}/*; chown -R ${was_user}:${was_group} ${was_install_location}/*",
    refreshonly => true,
  }
}
