  define cdougan_was::resources::create_was_nd_profile(
    $array,
    $jvm_app_http_port,
    $jvm_app_https_port,
    $jvm_admin_http_port,
    $jvm_admin_https_port,
    $environment_layer,
    $environment_number,
    $was_profile_dir,
    $was_profile_name,
    $was_instance_number,
    $was_install_location,
    $template_path,
    $admin_template_path,
    $software_location,
    $cell_name,
    $node_name,
    $bootstrap_port,
    $soap_port,
    $ipc_port,
    $sas_ssl_port,
    $csiv2_server_port,
    $csiv2_mutual_port,
    $orb_port,
    $dcs_port,
    $sib_port,
    $sib_secure_port,
    $sib_mq_port,
    $sib_mq_secure_port,
    $sip_default_port,
    $sip_default_secure,
    $overlay_udp_port,
    $overlay_tcp_port,
    $was_user,
    $was_group,
    $dmgr_was_profile_name,
    $dmgr_user,
    $dmgr_pwd,
    $dmgr_node_name,
    $dmgr_profile_path,
    $dmgr_template_path,
  )
  {
    $was_flavour="ND"
    $bs_addr=$bootstrap_port
    $sc_addr=$soap_port
    $ipc_addr=$ipc_port
    $sas_addr=$sas_ssl_port
    $csi_server=$csiv2_server_port
    $csi_mutual=$csiv2_mutual_port
    $orb_addr=$orb_port
    $dcs_addr=$dcs_port
    $sib_addr=$sib_port
    $sib_secure=$sib_secure_port
    $sib_mq_addr=$sib_mq_port
    $sib_mq_secure=$sib_mq_secure_port
    $sip_addr=$sip_default_port
    $sip_secure=$sip_default_secure
    $udp_addr=$overlay_udp_port
    $tcp_addr=$overlay_tcp_port

    $full_was_profile_name = $name
    $profile_path          = "${was_profile_dir}/${full_was_profile_name}"
    $admin_agent_name      = "${full_was_profile_name}-${::hostname}"
    $server_name           = "adminagent"  
    file {"${software_location}/${full_was_profile_name}.portdef.props":
      content => template('cdougan_was/portdef_adminagent.props.erb'),
      owner => $was_user,
      group => $was_group,
    }

    exec {"Create Deployment Manager Profile $dmgr_was_profile_name for Websphere ${was_flavour}":
      path                  => '/bin:/usr/bin:/sbin:/usr/sbin',
      command               => "${was_install_location}/bin/manageprofiles.sh -create -profileName ${dmgr_was_profile_name} -adminUserName ${dmgr_user} -adminPassword ${dmgr_pwd} -enableAdminSecurity true -cellName ${cell_name} -nodeName ${dmgr_node_name} -personalCertDN \"cn=${::hostname} ou=${cell_name} ou=${dmgr_node_name} o=IBM c=US \" -profilePath ${dmgr_profile_path} -nodeProfilePath ${profile_path} -appServerNodeName ${node_name} -enableService false -hostname ${::hostname} -personalCertValidityPeriod 15 -signingCertValidityPeriod 15 -keyStorePassword ${dmgr_pwd} -templatePath ${dmgr_template_path}",
      creates               => "${dmgr_profile_path}",
      user                  => "${was_user}",
      timeout              => 1800,
    }
    exec {"Create $was_profile_name profile for WebSphere ${was_flavour} when dmgr is installed":
      path                  => '/bin:/usr/bin:/sbin:/usr/sbin',
      command               => "${was_install_location}/bin/manageprofiles.sh -create -adminUserName ${dmgr_user} -adminPassword ${dmgr_pwd} -enableAdminSecurity true -cellName ${cell_name} -nodeName ${dmgr_node_name} -personalCertDN \"cn=${::hostname} ou=${cell_name} ou=${dmgr_node_name} o=IBM c=US \" -profilePath ${profile_path} -dmgrProfilePath ${dmgr_profile_path} -profileName ${full_was_profile_name} -appServerNodeName ${node_name} -enableService false -signingCertDN \" cn=${::hostname} ou=Root Certificate ou=${cell_name} ou=${dmgr_node_name} o=IBM c=US\" -hostName ${::hostname} -personalCertValidityPeriod 15 -signingCertValidityPeriod 15 -keyStorePassword ${dmgr_pwd} -templatePath ${template_path} -portsFile ${dmgr_profile_path}/properties/portdef.props -nodePortsFile ${dmgr_profile_path}/properties/nodeportdef.props",
      creates               => "${profile_path}",
      user                  => "${was_user}",
      timeout              => 1800,
      require               => Exec["Create Deployment Manager Profile $dmgr_was_profile_name for Websphere ${was_flavour}"],
    }
    exec {"Start DMGR":
      path                  => '/bin:/usr/bin:/sbin:/usr/sbin',
      command               => "${was_install_location}/bin/startManager.sh",
      user                  => "${was_user}",
      timeout               => 1800,
      refreshonly           => true,
      subscribe             => Exec["Create $was_profile_name profile for WebSphere ${was_flavour} when dmgr is installed"],
   }
   exec {"Start Node":
     path                  => '/bin:/usr/bin:/sbin:/usr/sbin',
     command               => "${profile_path}/bin/startNode.sh",
     user                  => "${was_user}",
     timeout               => 1800,
     refreshonly           => true,
     subscribe             => Exec["Start DMGR"],
   }

    file {"${profile_path}/bin/setupCmdLine.sh":
      content => template('cdougan_was/setupCmdLine.sh.erb'),
      owner => $was_user,
      group => $was_group,
      require => Exec["Create $was_profile_name profile for WebSphere ${was_flavour} when dmgr is installed"],
   }

    cdougan_was::resources::create_jvms {$array:
      array                     => $array,
      environment_layer        => $environment_layer,
      environment_number         => $environment_number,
      full_was_profile_name    => $full_was_profile_name,
      was_profile_dir          => $was_profile_dir,
      software_location        => $software_location,
      was_user                 => $was_user,
      was_group                => $was_group,
      was_profile_name         => $was_profile_name,
      was_flavour              => $was_flavour,
      dmgr_user                => $dmgr_user,
      dmgr_pwd                 => $dmgr_pwd,
      require                  => [Exec["Start Node"],
                                   File["${profile_path}/bin/setupCmdLine.sh"]],
    }
  }

