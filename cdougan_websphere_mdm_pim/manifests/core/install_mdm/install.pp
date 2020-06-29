class cdougan_websphere_mdm_pim::core::install_mdm::install () inherits cdougan_websphere_mdm_pim {
  file {"${software_location}/MDMCE_silent_install.rsp":
    content     => template('cdougan_websphere_mdm_pim/MDMCE_silent_install.erb'),
    owner       => $was_user,
    group       => $was_group,
    mode        => 0644,
  }

  if $install_mdm {  
    exec {"Install MDMCE":
      path        => "/usr/bin:/usr/sbin:/bin:/sbin",
      command     => "/bin/bash -c 'source ${install_path}/pim_profile; ${imcl} -acceptLicense -silent -input ${software_location}/MDMCE_silent_install.rsp -log ${software_location}/logs/ibm_mdmce_install.log'; chown -R ${was_user}:${was_group} ${was_install_location}; chown -R ${was_user}:${was_group} ${software_location}/logs", 
      require     => File["${software_location}/MDMCE_silent_install.rsp"],
      creates     => "${software_location}/logs/ibm_mdmce_install.log",
      timeout     => 1800,
      notify      => Exec["Set Permissions Post MDMCE Install"], 
       }

    exec {"Set Permissions Post MDMCE Install":
      path        => "/usr/bin:/usr/sbin:/bin:/sbin",
      command     => "chown -R ${was_user}:${was_user} ${was_root_dir}; chmod -R g+rwx ${was_root_dir}; chown -R ${was_user}:${was_user} ${mdmce_root_dir}; chmod -R g+rwx ${mdmce_root_dir} > ${software_location}/logs/set_permissions_post_mdmce_install.log",
      refreshonly => true,
      creates     => "${software_location}/logs/set_permissions_post_mdmce_install.log",
      timeout     => 1800,
      require     => Exec["Install MDMCE"],
    }
  }
}
