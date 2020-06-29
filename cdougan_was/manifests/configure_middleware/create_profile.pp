class cdougan_was::configure_middleware::create_profile () inherits cdougan_was {
  $serverlist=split($server_names,",")
  $numofservers = inline_template('<%= @serverlist.length %>')

  $full_was_profile_name = "${environment_layer}${environment_number}WSPF-${was_profile_name}"

  file {"${software_location}/configure_HTTP_accessLog.py":
    ensure  => present,
    source  => "puppet:///modules/cdougan_was/configure_HTTP_accessLog.py",
    owner   => $was_user,
    group   => $was_group,
  }

  file {"${software_location}/addJVMproperty.py":
    ensure  => present,
    source  => "puppet:///modules/cdougan_was/addJVMproperty.py",
    owner   => $was_user,
    group   => $was_group,
  }

  if "${was_dmgr_user}"                          == undef {
    $dmgr_user                                  = "user123"
  } else {
    $dmgr_user                                  = "${was_dmgr_user}"
  }
  if "${was_dmgr_pwd}"                           == undef {
    $dmgr_pwd                                   = "password123"
  } else {
    $dmgr_pwd                                   = "${was_dmgr_pwd}"
  }
  if $was_profile_name {
    if $was_instance_number {
      if $was_flavour {
        if $environment_layer {
          if $environment_number {
            if $was_profile_dir {
              if $was_install_location {
                if $::hostname {
                  if "${was_flavour}"           == "BASE" {
                      cdougan_was::resources::create_profile_using_admin_agent {$full_was_profile_name:
                        array                 => $serverlist,
                        environment_layer     => $environment_layer,
                        environment_number    => $environment_number,
                        was_profile_dir       => $was_profile_dir,
                        was_profile_name      => $was_profile_name,
                        software_location     => $software_location,
                        was_user              => $was_user,
                        was_group             => $was_group,
                        jvm_app_http_port     => $app_http_port,
                        jvm_app_https_port    => $app_https_port,
                        jvm_admin_http_port   => $admin_http_port,
                        jvm_admin_https_port  => $admin_https_port,
                        was_instance_number   => $was_instance_number,
                        was_install_location  => $was_install_location,
                        template_path         => $template_path,
                        admin_template_path   => $admin_template_path,
                        cell_name             => $cell_name,
                        node_name             => $node_name,
                        bootstrap_port        => $bootstrap_port,
                        soap_port             => $soap_port,
                        admin_user            => $admin_user,
                        admin_pass            => $admin_pass,
                        ipc_port              => $ipc_port,
                        sas_ssl_port          => $sas_ssl_port,
                        csiv2_server_port     => $csiv2_server_port,
                        csiv2_mutual_port     => $csiv2_mutual_port,
                        orb_port              => $orb_port,
                        dcs_port              => $dcs_port,
                        sib_port              => $sib_port,
                        sib_secure_port       => $sib_secure_port,
                        sib_mq_port           => $sib_mq_port,
                        sib_mq_secure_port    => $sib_mq_secure_port,
                        sip_default_port      => $sip_default_port,
                        sip_default_secure    => $sip_default_secure,
                        overlay_udp_port      => $overlay_udp_port,
                        overlay_tcp_port      => $overlay_tcp_port,
                      }
                  } elsif "${was_flavour}"      == "ND" {
                    if $was_install_dmgr  {
                      cdougan_was::resources::create_was_nd_profile {$full_was_profile_name:
                        array                 => $serverlist,
                        environment_layer     => $environment_layer,
                        environment_number    => $environment_number,
                        was_profile_dir       => $was_profile_dir,
                        was_profile_name      => $was_profile_name,
                        software_location     => $software_location,
                        was_user              => $was_user,
                        was_group             => $was_group,
                        jvm_app_http_port     => $app_http_port,
                        jvm_app_https_port    => $app_https_port,
                        jvm_admin_http_port   => $admin_http_port,
                        jvm_admin_https_port  => $admin_https_port,
                        was_instance_number   => $was_instance_number,
                        was_install_location  => $was_install_location,
                        template_path         => $template_path,
                        admin_template_path   => $admin_template_path,
                        cell_name             => $cell_name,
                        node_name             => $node_name,
                        bootstrap_port        => $bootstrap_port,
                        soap_port             => $soap_port,
                        ipc_port              => $ipc_port,
                        sas_ssl_port          => $sas_ssl_port,
                        csiv2_server_port     => $csiv2_server_port,
                        csiv2_mutual_port     => $csiv2_mutual_port,
                        orb_port              => $orb_port,
                        dcs_port              => $dcs_port,
                        sib_port              => $sib_port,
                        sib_secure_port       => $sib_secure_port,
                        sib_mq_port           => $sib_mq_port,
                        sib_mq_secure_port    => $sib_mq_secure_port,
                        sip_default_port      => $sip_default_port,
                        sip_default_secure    => $sip_default_secure,
                        overlay_udp_port      => $overlay_udp_port,
                        overlay_tcp_port      => $overlay_tcp_port,
                        dmgr_was_profile_name => $dmgr_was_profile_name,
                        dmgr_user             => $dmgr_user,
                        dmgr_pwd              => $dmgr_pwd,
                        dmgr_node_name        => $dmgr_node_name,
                        dmgr_profile_path     => $dmgr_profile_path,
                        dmgr_template_path    => $dmgr_template_path,
                      }
                    } else {
                      exec {"Create $was_profile_name profile for WebSphere ${was_flavour} with no dmgr installed":
                        path                => '/bin:/usr/bin:/sbin:/usr/sbin',
                        command             => "${was_install_location}/bin/manageprofiles.sh -create -profileName ${full_was_profile_name} -profilePath ${profile_path} -appServerNodeName ${node_name} -cellName ${cell_name} -nodeName ${node_name} -hostName ${::hostname} -templatePath ${template_path}",
                        creates             => "${profile_path}",
                        timeout             => 1800,
                        user                => "${was_user}",
                    }
                    if $was_dmgr_hostname {
                      exec {"Federate Note ${node_name} to  ${was_dmgr_hostname}":
                        path                => '/bin:/usr/bin:/sbin:/usr/sbin',
                        command             => "${profile_path}/bin/addNode.sh ${was_dmgr_hostname}",
                        creates             => "${profile_path}/logs/nodeagent",
                        timeout             => 1800,
                        require             => Exec["Create $was_profile_name profile for WebSphere ${was_flavour} with no dmgr installed"],
                      }  
                    }
                  }
                  }else {
                    notify {"Unsupported Websphere Version : $::{was_flavour}":}
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
