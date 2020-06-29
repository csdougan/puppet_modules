class cdougan_was::install_middleware::setup_app_dir () inherits cdougan_was {

  exec {"Create WAS ${was_install_location} Dir":
    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
    command     => "mkdir -p ${was_install_location}",
    creates     => $was_install_location,
    notify      => Exec["Set Permissions on ${install_path} pre WAS Install"],
    unless      => "grep 'package id' ${was_install_path}/properties/version/installed.xml | grep \"${was_product_name}\"",
  }
  exec {"Set Permissions on ${install_path} pre WAS Install":
    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
    command     => "chmod 755 -R ${install_path}; chown -R ${was_user}:${was_group} ${install_path}",
    refreshonly => true,
    require     => Exec["Create WAS ${was_install_location} Dir"],
    notify      => Exec["Create ${software_location} and set Permissions if filesystem doesnt exist already"],
    unless      => "grep 'package id' ${was_install_path}/properties/version/installed.xml | grep \"${was_product_name}\"",
  }
  exec {"Create ${software_location} and set Permissions if filesystem doesnt exist already":
    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
    command     => "mkdir -p ${software_location}; chown ${was_user}:${was_group} ${software_location}; chmod 755 ${software_location}",
    creates     => $software_location,
    refreshonly => true,
    require     => Exec["Set Permissions on ${install_path} pre WAS Install"],
    unless      => "grep 'package id' ${was_install_path}/properties/version/installed.xml | grep \"${was_product_name}\"",
  }
}
