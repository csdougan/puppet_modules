class cdougan_websphere_mdm_pim::core::install_mdm::post_install_changes () inherits cdougan_websphere_mdm_pim {
  if $install_mdm {  
    file {"${mdmce_default_dir}/log.xml":
      content     => template('cdougan_websphere_mdm_pim/log.xml.erb'),
      owner       => $was_user,
      group       => $was_group,
      mode        => 0775,
    }

    file {"${mdmce_default_dir}/docstore_mount.xml":
      source      => "puppet:///modules/cdougan_websphere_mdm_pim/docstore_mount.xml",
      owner       => $was_user,
      group       => $was_group,
      mode        => 0775,
    }

    file {"${mdmce_default_dir}/common.properties":
      content     => template('cdougan_websphere_mdm_pim/common.properties.erb'),
      owner       => $was_user,
      group       => $was_group,
      mode        => 0775,
    }

    file {"${mdmce_default_dir}/mdm-cache-config.properties":
      source      => "puppet:///modules/cdougan_websphere_mdm_pim/mdm-cache-config.properties",
      owner       => $was_user,
      group       => $was_group,
      mode        => 0775,
    }
  
    file {"${dmgr_profile_path}/config/cells/${cell_name}/nodes/${dmgr_node_name}/servers/dmgr/server.xml":
      source      => "puppet:///modules/cdougan_websphere_mdm_pim/dmgr-server.xml",
      owner       => $was_user,
      group       => $was_group,
      mode        => 0775,
      require     => [Exec["Install MDMCE"],Exec["Set Permissions Post MDMCE Install"],File["${mdmce_default_dir}/mdm-cache-config.properties"],File["${mdmce_default_dir}/common.properties"],File["${mdmce_default_dir}/docstore_mount.xml"],File["${mdmce_default_dir}/log.xml"]],
      notify      => Exec["Start Dmgr after applying MDM post-install configuration changes"],
    }

    exec {"Start Dmgr after applying MDM post-install configuration changes":
      path        => "/usr/bin:/usr/sbin:/bin:/sbin",
      command     => "${dmgr_profile_path}/bin/startManager.sh && echo 'started dmgr post install config changed' > ${software_location}/logs/restarted_dmgr_post_config.log",
      user        => $was_user,
      refreshonly => true,
      creates     => "${software_location}/logs/restarted_dmgr_post_config.log",
      require     => [File["${dmgr_profile_path}/config/cells/${cell_name}/nodes/${dmgr_node_name}/servers/dmgr/server.xml"],
                      File["${mdmce_default_dir}/mdm-cache-config.properties"],
                      File["${mdmce_default_dir}/common.properties"],
                      File["${mdmce_default_dir}/docstore_mount.xml"],
                      File["${mdmce_default_dir}/log.xml"]],
      timeout     => 1800,
      notify      => Exec["Start Node Agent after applying MDM post-install configuration changes"],
    }

    exec {"Start Node Agent after applying MDM post-install configuration changes":
      path        => "/usr/bin:/usr/sbin:/bin:/sbin",
      command     => "${profile_path}/bin/startNode.sh && echo 'started node post config changed' > ${software_location}/logs/restarted_node_post_config.log",
      user        => $was_user,
      refreshonly => true,
      creates     => "${software_location}/logs/restarted_node_post_config.log",
      require     => Exec["Start Dmgr after applying MDM post-install configuration changes"],
      timeout     => 1800,
      notify      => [Exec["${software_location}/deploy_sequences.sh"],Exec["Set Permissions on MDM to ${was_user} post install"]],
    }

    file {"${software_location}/deploy_sequences.sh":
      content      => template('cdougan_websphere_mdm_pim/deploy_sequences.sh.erb'),
      owner        => $was_user,
      group       => $was_group,
      mode        => 0755,
    }

    if $run_db2_scripts {
      exec {"${software_location}/deploy_sequences.sh":
        path        => "/bin:/sbin:/usr/bin:/usr/sbin",
        command     => "bash -c \"source ${install_path}/pim_profile; ${software_location}/deploy_sequences.sh\" > ${software_location}/logs/deploy_sequences.log",
        creates     => "${software_location}/logs/deploy_sequences.log",
        user        => $was_user,
        refreshonly => true,
        timeout     => 1800,
        notify      => Exec["Create Company MyOrg in MDMCE"],
        require     => [Exec["Start Node Agent after applying MDM post-install configuration changes"],File["${software_location}/deploy_sequences.sh"]],  
      }
    }

    exec {"Set Permissions on MDM to ${was_user} post install":
      path        => "/bin:/sbin:/usr/bin:/usr/sbin",
      command     => "chown -R ${was_user}:${was_group} ${install_path}/MDMCE; chmod -R 775 ${install_path}/MDMCE > ${software_location}/logs/set_perms_on_MDM_to_was_user_post_install.log",
      creates     => "${software_location}/logs/set_perms_on_MDM_to_was_user_post_install.log",
      refreshonly => true,
      require     => Exec["${software_location}/deploy_sequences.sh"],
      timeout     => 1800,
    }

    if $run_db2_scripts {
      exec {"Create Company MyOrg in MDMCE":
        path        => "/bin:/sbin:/usr/bin:/usr/sbin",
        command     => "bash -c 'source ${install_path}/pim_profile; ${mdmce_bin_dir}/db/create_cmp.sh --code=cdougan --silent' > ${software_location}/logs/create_cmp.log",
        refreshonly => true,
        creates     => "${software_location}/logs/create_cmp.log",
        user        => $was_user,
        require     => Exec["Set Permissions on MDM to ${was_user} post install"],
        timeout     => 1800,
        before      => Exec["Start MDMCE Post config changes"], 
      }
    }

    exec {"Start MDMCE Post config changes":
      path        => "/bin:/sbin:/usr/bin:/usr/sbin",
      command     => "/bin/bash -c 'source ${install_path}/pim_profile; ${mdmce_bin_dir}/go/start_local.sh' && echo 'restarted post config changes' > ${software_location}/logs/restarted_post_config.log",
      creates     => "${software_location}/logs/restarted_post_config.log",
      require     => Exec["Set Permissions on MDM to ${was_user} post install"],
      timeout     => 1800,
      user        => $was_user,
    }
  }
}
