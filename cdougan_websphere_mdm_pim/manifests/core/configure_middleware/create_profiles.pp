class cdougan_websphere_mdm_pim::core::configure_middleware::create_profiles () inherits cdougan_websphere_mdm_pim {

  if $was_dmgr_user                          == undef {
    $dmgr_user                                  = 'user123'
  } else {
    $dmgr_user                                  = $was_dmgr_user
  }
  if $was_dmgr_pwd                           == undef {
    $dmgr_pwd                                   = 'password123'
  } else {
    $dmgr_pwd                                   = $was_dmgr_pwd
  }
  if $was_flavour      == 'ND' {
    exec {"Create Deployment Manager Profile ${dmgr_was_profile_name} for Websphere ${was_flavour}":
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => "${was_install_location}/bin/manageprofiles.sh -create -profileName ${dmgr_was_profile_name} -adminUserName ${dmgr_user} -adminPassword ${dmgr_pwd} -enableAdminSecurity true -cellName ${cell_name} -nodeName ${dmgr_node_name} -personalCertDN \"cn=${::hostname} ou=${cell_name} ou=${dmgr_node_name} o=IBM c=US \" -profilePath ${dmgr_profile_path} -nodeProfilePath ${profile_path} -appServerNodeName ${node_name} -enableService false -hostname ${::hostname} -personalCertValidityPeriod 15 -signingCertValidityPeriod 15 -keyStorePassword ${dmgr_pwd} -templatePath ${dmgr_template_path}",
      creates => $dmgr_profile_path,
      user    => $was_user,
      timeout => 1800,
    }
    exec {" Create Service for Deployment Manager profile ${dmgr_was_profile_name} for Websphere ${was_flavour}":
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "${was_install_location}/bin/wasservice.sh -add ${dmgr_node_name} -serverName dmgr -userid ${was_user} -profilePath ${dmgr_profile_path} -logRoot /opt/IBM/WebSphere/AppServer/profiles/${dmgr_was_profile_name}/logs/${dmgr_node_name} -restart true -startType automatic",
    creates => "/etc/init.d/${dmgr_node_name}_was.init",
    }

    exec {"Create ${was_profile_name} profile for WebSphere ${was_flavour} when dmgr is installed":
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => "${was_install_location}/bin/manageprofiles.sh -create -adminUserName ${dmgr_user} -adminPassword ${dmgr_pwd} -enableAdminSecurity true -cellName ${cell_name} -nodeName ${dmgr_node_name} -personalCertDN \"cn=${::hostname} ou=${cell_name} ou=${dmgr_node_name} o=IBM c=US \" -profilePath ${profile_path} -dmgrProfilePath ${dmgr_profile_path} -profileName ${full_was_profile_name} -appServerNodeName ${node_name} -enableService false -signingCertDN \" cn=${::hostname} ou=Root Certificate ou=${cell_name} ou=${dmgr_node_name} o=IBM c=US\" -hostName ${::hostname} -personalCertValidityPeriod 15 -signingCertValidityPeriod 15 -keyStorePassword ${dmgr_pwd} -templatePath ${template_path} -portsFile ${dmgr_profile_path}/properties/portdef.props -nodePortsFile ${dmgr_profile_path}/properties/nodeportdef.props",
      creates => $profile_path,
      user    => $was_user,
      timeout => 1800,
      require => Exec["Create Deployment Manager Profile ${dmgr_was_profile_name} for Websphere ${was_flavour}"],
    }
    exec {" Create Service for ${was_profile_name} for Websphere ${was_flavour}":
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "${was_install_location}/bin/wasservice.sh -add ${server_name} -serverName ${server_name} -userid ${was_user} -profilePath ${profile_path} -logRoot ${profile_path}/logs/${server_name} -restart true -startType automatic",
    creates => "/etc/init.d/${server_name}_was.init",
    }
  } else {
    notify {"Unsupported Websphere Version : $::{was_flavour}":}
  }
}
