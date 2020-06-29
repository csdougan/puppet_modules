class cdougan_websphere_mdm_pim::core::install_mdm::stop_servers_post_install () inherits cdougan_websphere_mdm_pim {
  if $install_mdm {  
    exec {"Stop MDMCE post install":
      path        => "/usr/bin:/usr/sbin:/bin:/sbin",
      command     => "/bin/bash -c 'source ${install_path}/pim_profile; ${mdmce_bin_dir}/go/stop_local.sh' > ${software_location}/logs/stop_mdmce_post_install.log",
      creates     => "${software_location}/logs/stop_mdmce_post_install.log",
      timeout     => 1800,
      notify      => Exec["Stop DMGR post MDM install"],
    }

    exec {"Stop DMGR post MDM install":
      path        => "/usr/bin:/usr/sbin:/bin:/sbin",
      command     => "${dmgr_profile_path}/bin/stopManager.sh > ${software_location}/logs/stop_dmgr_post_mdm_install.log",
      refreshonly => true,
      creates     => "${software_location}/logs/stop_dmgr_post_mdm_install.log",
      require     => Exec["Stop MDMCE post install"],
      timeout     => 1800,
      notify      => Exec["Stop Node post MDM install"],
    }

    exec {"Stop Node post MDM install":
      path        => "/usr/bin:/usr/sbin:/bin:/sbin",
      command     => "${profile_path}/bin/stopNode.sh > ${software_location}/logs/stop_node_post_mdm_install.log",
      refreshonly => true,
      creates     => "${software_location}/logs/stop_node_post_mdm_install.log",
      require     => Exec["Stop DMGR post MDM install"],
      timeout     => 1800,
    }

  }
}
