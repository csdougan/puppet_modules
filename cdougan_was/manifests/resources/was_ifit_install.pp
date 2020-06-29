define cdougan_was::resources::was_ifit_install (  
  $imcl                = undef,
  $nexus_path          = undef,
  $nexus_repo          = undef,
  $wasuser             = undef,
  $wasgroup            = undef,
  $fixpack_version     = undef,
  $ifit_version        = undef,
  $software_dir        = undef,
  $was_install_path    = undef,

) {
  $was_extract_path    = "${software_dir}/WAS-IFIT-${ifit_version}"
  $archive_file        = "IFIT-${ifit_version}.zip"
  $nexus_was_path      = "${nexus_path}/${nexus_repo}/content/IBM/WAS/IFIT/"
  $log_dir             = "${software_dir}/logs"

  file {"${was_extract_path}":
    ensure          => directory,
    owner           => "${wasuser}",
    group           => "${wasgroup}",
  }

  archive { "${archive_file}":
    path            => "${software_dir}/${archive_file}",
    source          => "${nexus_was_path}/${ifit_version}/${archive_file}",
    extract         => true,
    extract_path    => "${was_extract_path}",
    creates         => "/var/ibm/InstallationManager/installRegistry/metadata/Fixes",
    cleanup         => true,
    user            => "${wasuser}",
    group           => "${wasgroup}",
    require         => File["${was_extract_path}"],
  }
   
  exec {"install_was IFIT ${ifit_version}":
  	command		      => "${imcl} install ${fixpack_version}-WS-WAS-IFIT${ifit_version} -repositories ${was_extract_path} -installationDirectory ${was_install_path} -acceptLicense -log ${log_dir}/was_${was_version}_ifit_install.log; chown -R ${wasuser}:${wasgroup} ${was_install_path}",
    path            => '/bin:/usr/bin:/sbin:/usr/sbin',
    creates         => ["/var/ibm/InstallationManager/installRegistry/metadata/Fixes","${log_dir}/was_ifit_${ifit_version}_install.log"],
    timeout         => 1800,
    require         => Archive["${archive_file}"],
  }
}

