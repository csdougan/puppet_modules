  define cdougan_was::resources::create_profile_using_admin_agent(
    $array,
    $admin_user,
    $admin_pass,
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
  )
  {
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

    exec {"Create $full_was_profile_name profile for WebSphere AS":
      path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                   => "${was_install_location}/bin/manageprofiles.sh -create -profileName ${full_was_profile_name} -profilePath ${profile_path} -templatePath ${template_path} -portsFile ${software_location}/${full_was_profile_name}.portdef.props -serverName temporary_server -cellName ${cell_name} -nodeName ${node_name} -hostName ${::hostname}  -enableAdminSecurity true -adminUserName ${admin_user} -adminPassword ${admin_pass}",
      creates                   =>  "${profile_path}",
      user                      => $was_user,
      timeout                   => 1800,
      require                   => File["${software_location}/${full_was_profile_name}.portdef.props"],
      notify                    => Exec["Start Server for $full_was_profile_name"],
    }

    file {"${profile_path}/bin/setupCmdLine.sh":
      content => template('cdougan_was/setupCmdLine.sh.erb'),
      owner => $was_user,
      group => $was_group,
      require => Exec["Create ${full_was_profile_name} profile for WebSphere AS"],
   }

    file {"${was_profile_dir}/${full_was_profile_name}/bin":
      ensure => directory,
      mode   => 0750,
     require => Exec["Create ${full_was_profile_name} profile for WebSphere AS"],
    }

    file {"${was_profile_dir}/${full_was_profile_name}/properties":
      ensure => directory,
      mode   => 0750,
     require => Exec["Create ${full_was_profile_name} profile for WebSphere AS"],
    }

    exec {"Start Server for ${full_was_profile_name}":
      path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                   => "${was_profile_dir}/${full_was_profile_name}/bin/startServer.sh temporary_server",
      require                   => [Exec["Create ${full_was_profile_name} profile for WebSphere AS"],
                                    File["${profile_path}/bin/setupCmdLine.sh"]],
      refreshonly               => true,
      user                      => $was_user,
      timeout                   => 1800,
    }

    exec {"Create administrative agent profile for WebSphere AS":
      path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                   => "${was_install_location}/bin/manageprofiles.sh -create -profileName adminagent -profilePath ${was_profile_dir}/adminagent -templatePath ${admin_template_path} -serverType ADMIN_AGENT -nodeName adminagent -serverName ${server_name} -hostName ${::hostname} -enableAdminSecurity true -adminUserName ${admin_user} -adminPassword ${admin_pass}",
      creates                   =>  "${was_profile_dir}/${server_name}",
      user                      => $was_user,
      timeout                   => 1800,
      require                   => Exec["Start Server for $full_was_profile_name"],
      notify                    => Exec["Start adminagent"],
    }

    file {"${was_profile_dir}/adminagent/bin/setupCmdLine.sh":
      content => template('cdougan_was/setupCmdLine-adminagent.sh.erb'),
      owner => $was_user,
      group => $was_group,
      require => Exec["Create administrative agent profile for WebSphere AS"],
   }

    exec {"Start adminagent":
      path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                   => "${was_profile_dir}/adminagent/bin/startServer.sh ${server_name}",
      require                   => [Exec["Create ${full_was_profile_name} profile for WebSphere AS"],
                                    Exec["Create administrative agent profile for WebSphere AS"]],
      refreshonly               => true,
      user                      => $was_user,
      timeout                   => 1800,
      notify                    => Exec["Setup JVM ${server_name} for ${full_was_profile_name}"],
    }

    file {"${software_location}/setup-${server_name}-jvm.jf":
      content                   => template("cdougan_was/setup-${server_name}-jvm.jf.erb"),
      owner                     => $was_user,
      group                     => $was_group,
    }

    exec {"Setup JVM ${server_name} for ${full_was_profile_name}":
      path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                   => "${was_profile_dir}/adminagent/bin/wsadmin.sh -lang jython -f ${software_location}/setup-${server_name}-jvm.jf -username ${admin_user} -password ${admin_pass}",
      user                      => $was_user,
      timeout                   => 1800,
      refreshonly               => true,
      notify                    => Exec["Configure HTTP Access Logs for ${server_name}"],
      require                   => [File["${software_location}/setup-${server_name}-jvm.jf"],
                                    Exec["Start adminagent"]],
    }

    exec {"Configure HTTP Access Logs for ${server_name}":
      path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                   => "${was_profile_dir}/adminagent/bin/wsadmin.sh -username ${admin_user} -password ${admin_pass} -lang jython -f ${software_location}/configure_HTTP_accessLog.py ${server_name} enable",
      user                      => $was_user,
      timeout                   => 1800,
      refreshonly               => true,
      notify                    => Exec["Register profile with administrative agent"],
      require                   => [File["${software_location}/configure_HTTP_accessLog.py"],
                                    Exec["Setup JVM ${server_name} for ${full_was_profile_name}"]],
    }


    exec {"Register profile with administrative agent":
      path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                   => "${was_profile_dir}/adminagent/bin/registerNode.sh -profilePath ${profile_path} -host ${::hostname} -conntype SOAP -port 8877 -name ${admin_agent_name} -username ${admin_user} -password ${admin_pass}",
      user                      => $was_user,
      timeout                   => 1800,
      refreshonly               => true,
      require                   => [Exec["Start adminagent"],
                                    Exec["Setup JVM ${server_name} for ${full_was_profile_name}"]],
    }

    exec {"Stop adminagent as part of restart post-registration":
      path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                   => "${was_profile_dir}/adminagent/bin/stopServer.sh adminagent",
      require                   => Exec["Register profile with administrative agent"],
      refreshonly               => true,
      user                      => $was_user,
      timeout                   => 1800,
      notify                    => Exec["Start adminagent as part of restart post-registration"],
    }

    exec {"Start adminagent as part of restart post-registration":
      path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                   => "${was_profile_dir}/adminagent/bin/stopServer.sh adminagent",
      require                   => Exec["Stop adminagent as part of restart post-registration"],
      refreshonly               => true,
      user                      => $was_user,
      timeout                   => 1800,
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
      admin_user               => $admin_user,
      admin_pass               => $admin_pass,
      was_flavour              => "BASE",
      require                   => Exec["Start adminagent as part of restart post-registration"],
      notify                    => Exec["Delete temporary_server for ${full_was_profile_name}"],
      before                   => Exec["Delete temporary_server for ${full_was_profile_name}"],
    }

    exec {"Delete temporary_server for ${full_was_profile_name}":
      path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command                   => "${was_profile_dir}/${full_was_profile_name}/bin/wsadmin.sh -username ${admin_user} -password ${admin_pass} -lang jython -c \"AdminTask.deleteServer('[-serverName temporary_server -nodeName ${node_name}]');AdminConfig.save();\"",
      onlyif                    => "test -d ${was_profile_dir}/${full_was_profile_name}/servers/temporary_server",
      refreshonly               => true,
      user                      => $was_user,
      timeout                   => 1800,
    }
  }

