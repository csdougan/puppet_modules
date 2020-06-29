class cdougan_websphere_mdm_pim::core::configure_middleware::delete_default_server () inherits cdougan_websphere_mdm_pim {
  exec {"Set permissions on log directory before removing default server":
    path         => '/bin:/usr/bin:/sbin:/usr/sbin',
    command      => "chown -R ${was_user}:${was_group} ${software_location}/logs",
    creates      => "${software_location}/logs/delete_default_server.log",
  }

  exec {"Delete default Server server1 under Profile ${full_was_profile_name}":
    path         => '/bin:/usr/bin:/sbin:/usr/sbin',
    command      => "${profile_path}/bin/wsadmin.sh -lang jython -c \"AdminTask.deleteServer('[-serverName server1 -nodeName ${node_name}]');AdminConfig.save();\";echo \"deleted server1\"> ${software_location}/logs/delete_default_server.log",
    creates      => "${software_location}/logs/delete_default_server.log",
    user         => "${was_user}",
    timeout      => 1800,
    require      => Exec["Set permissions on log directory before removing default server"],
  }
  
}
 
