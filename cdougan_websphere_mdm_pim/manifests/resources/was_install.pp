define cdougan_websphere_mdm_pim::resources::was_install (  
  $imcl                = undef,
  $nexus_path          = undef,
  $nexus_repo          = undef,
  $wasuser             = undef,
  $wasgroup            = undef,
  $was_version         = undef,
  $was_edition         = undef,
  $software_dir        = undef,
  $was_install_path    = undef,
  $feature_list        = undef,

) {
  $was_extract_path    = "${software_dir}/WAS-${was_version}"
  $archive_file        = "${was_edition}-${was_version}.zip"
  $nexus_was_path      = "${nexus_path}/${nexus_repo}/content/IBM/WAS/${was_edition}/"
  $log_dir             = "${software_dir}/logs"
  $was_version_array   = split($was_version, '[.]')

  if $feature_list != undef {
    $was_features = ",${feature_list}"
  } else {
    $was_features = ""
  } 

  if size($was_version_array) > 2 {
    $was_product_name = "com.ibm.websphere.${was_edition}.v${was_version_array[0]}${was_version_array[1]}"
  } else {
    $was_product_name = "com.ibm.websphere.${was_edition}.v${was_version_array[0]}"
  }

  file {"${was_extract_path}":
    ensure          => directory,
    owner           => "${wasuser}",
    group           => "${wasgroup}",
  }

  archive { "${archive_file}":
    path            => "${software_dir}/${archive_file}",
    source          => "${nexus_was_path}/${was_version}/${archive_file}",
    extract         => true,
    extract_path    => "${was_extract_path}",
    creates         => "${was_extract_path}/repository.config",
    cleanup         => true,
    user            => "${wasuser}",
    group           => "${wasgroup}",
    require         => File["${was_extract_path}"],
  }

  exec {"install_was ${was_product_name} ${was_version}":
  	command		      => "${imcl} install ${was_product_name}${was_features} -repositories ${was_extract_path} -installationDirectory ${was_install_path} -acceptLicense -log ${log_dir}/was_${was_version}_fixpack_install.log; chown -R ${wasuser}:${wasgroup} ${was_install_path}",
    path            => '/bin:/usr/bin:/sbin:/usr/sbin',
    creates         => "${log_dir}/was_${was_version}_fixpack_install.log",
    timeout         => 1800,
    require         => Archive["${archive_file}"],
  }
}

