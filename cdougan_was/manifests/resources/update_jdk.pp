define cdougan_was::resources::update_jdk (  
  $wasuser           = undef,
  $wasgroup          = undef,
  $jdk_version       = undef,
  $imcl              = undef,
  $nexus_path        = undef,
  $nexus_repo        = undef,
  $was_install_path  = undef,
  $software_dir      = undef,
) {
  $was_bin_path      = "${was_install_path}/bin"
  $nexus_java_path   = "${nexus_path}/${nexus_repo}/content/IBM/WAS/JAVA"
  $jdk_extract_path  = "${software_dir}/JAVA-${jdk_version}"
  $log_dir           = "${software_dir}/logs"
  $archive_file      = "JAVA-${jdk_version}.zip"

  $jdk_version_array = split($jdk_version, '[.]')
  if size($jdk_version_array) > 2 {
    $jdk_product_name = "com.ibm.websphere.IBMJAVA.v${jdk_version_array[1]}${jdk_version_array[2]}"
  } else {
    $jdk_product_name = "com.ibm.websphere.IBMJAVA.v${jdk_version_array[1]}0"
  }
  # Base Config
  include '::archive'
  file {"${jdk_extract_path}":
    ensure        => directory,
    owner         => "${wasuser}",
    group         => "${wasgroup}",
  }

  archive { "${archive_file}":
    path          => "${software_dir}/${archive_file}",
    source        => "${nexus_java_path}/${jdk_version}/${archive_file}",
    extract       => true,
    extract_path  => "${jdk_extract_path}",
    creates       => "${jdk_extract_path}/disk1",
    cleanup       => true,
    user          => "${wasuser}",
    group         => "${wasgroup}",
    require       => File["${jdk_extract_path}"],
  }

  exec {"install_ibm_jdk_update":
    command       => "${imcl} install ${jdk_product_name} -repositories ${jdk_extract_path} -installationDirectory ${was_install_path} -log ${log_dir}/ibm_jdk_${jdk_version}_install.log; chown -R ${wasuser}:${wasgroup} ${was_install_path}",
    path          => '/bin:/usr/bin:/sbin:/usr/sbin',
    creates       => "${log_dir}/ibm_jdk_${jdk_version}_install.log",
    timeout       => 1800,
    require       => Archive["${archive_file}"],
  }

  exec {"set_command_default_jdk":
    command           => "${was_bin_path}/managesdk.sh -setCommandDefault -sdkname ${jdk_version}_64 > ${log_dir}/set_command_default_jdk.log",
    path              => "/bin:/usr/bin:/sbin:/usr/sbin",
    creates           => "${log_dir}/set_command_default_jdk.log",
    timeout           => 1800,
    require           => Exec['install_ibm_jdk_update'],
  }

  exec {"set_profile_default_jdk":
    command           => "${was_bin_path}/managesdk.sh -setNewProfileDefault -sdkname ${jdk_version}_64 > ${log_dir}/set_profile_default_jdk.log",
    path              => "/bin:/usr/bin:/sbin:/usr/sbin",
    creates           => "${log_dir}/set_profile_default_jdk.log",
    timeout           => 1800,
    require           => Exec['set_command_default_jdk'],
  }
}

