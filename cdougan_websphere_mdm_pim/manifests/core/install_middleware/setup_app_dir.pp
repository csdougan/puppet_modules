class cdougan_websphere_mdm_pim::core::install_middleware::setup_app_dir () inherits cdougan_websphere_mdm_pim {

  exec {"Create WAS ${was_install_location} Dir":
    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
    command     => "mkdir -p ${was_install_location}",
    creates     => $was_install_location,
    notify      => Exec["Set Permissions on ${was_install_location} pre WAS Install"],
  }
  exec {"Set Permissions on ${was_install_location} pre WAS Install":
    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
    command     => "chmod 755 -R ${was_install_location}; chown -R ${was_user}:${was_group} ${was_install_location}",
    refreshonly => true,
    require     => Exec["Create WAS ${was_install_location} Dir"],
    notify      => Exec["Create ${software_location} and set Permissions if filesystem doesnt exist already"],
  }
  exec {"Create ${software_location} and set Permissions if filesystem doesnt exist already":
    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
    command     => "mkdir -p ${software_location}; chown ${was_user}:${was_group} ${software_location}; chmod 755 ${software_location}",
    creates     => $software_location,
    refreshonly => true,
    require     => Exec["Set Permissions on ${was_install_location} pre WAS Install"],
  }
}
