class cdougan_was::install_middleware::install_was_ifit() inherits cdougan_was {
  if $install_ifit == true {
    cdougan_was::resources::was_ifit_install {"Install WAS IFIT ${was_ifit_version}":
      was_install_path   => "${was_install_location}",
      imcl               => "${imcl}",
      nexus_path         => "${nexus_url}",
      nexus_repo         => "${nexus_reponame}",
      wasuser            => "${was_user}",
      wasgroup           => "${was_group}",
      ifit_version       => "${was_ifit_version}",
      fixpack_version    => "${was_fixpack_version}",
      software_dir       => "${software_location}",
      notify             => Exec["Set Permissions on ${install_path} post Was IFIT install"],
      before             => Exec["Set Permissions on ${install_path} post Was IFIT install"],
    }
    exec {"Set Permissions on ${install_path} post Was IFIT install":
      path        => "/usr/bin:/bin:/usr/sbin:/sbin",
      command     => "chmod 755 -R ${install_path}; chown -R ${was_user}:${was_group} ${install_path}",
      refreshonly => true,
    }
  }
}
