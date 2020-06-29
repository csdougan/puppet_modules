define cdougan_was::resources::create_jvms(
  $array,
  $environment_layer,
  $environment_number,
  $full_was_profile_name,
  $was_profile_dir,
  $software_location,
  $was_profile_name,
  $was_flavour,
  $was_user,
  $was_group,
  $dmgr_user="wasuser",
  $dmgr_pwd="wasuser",
  $admin_user,
  $admin_pass,
)
{
  $length = inline_template('<%= @array.length %>')
  $index = inline_template('<%= @array.index(@name) %>')

  if $name == "default" {
    $server_name = "${environment_layer}${environment_number}WSMB-${was_profile_name}"
  } else {
    $server_name = "${environment_layer}${environment_number}WSMB-${was_profile_name}${name}"
  }
  $profile_path = "${was_profile_dir}/${full_was_profile_name}"

  file {"${software_location}/create-${server_name}-jvm.jf":
    content                   => template('cdougan_was/createjvm.jf.erb'),
    owner                     => $was_user,
    group                     => $was_group,
  } 

  file {"${software_location}/setup-${server_name}-jvm.jf":
    content                   => template('cdougan_was/setupjvm.jf.erb'),
    owner                     => $was_user,
    group                     => $was_group,
  } 

  file {"${software_location}/start-${server_name}-jvm.jf":
    content                   => template('cdougan_was/startjvm.jf.erb'),
    owner                     => $was_user,
    group                     => $was_group,
  } 

  if $was_flavour == "ND" {
    $authentication_string = "-user ${dmgr_user} -password ${dmgr_pwd}"
  } else {
    $authentication_string = "-user ${admin_user} -password ${admin_pass}"
  }

  exec {"Create JVM ${server_name} for ${full_was_profile_name}":
    path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                   => "${was_profile_dir}/${full_was_profile_name}/bin/wsadmin.sh -lang jython -f ${software_location}/create-${server_name}-jvm.jf  ${authentication_string} > ${software_location}/logs/create-${server_name}.log ", 
    user                      => $was_user,
    timeout                   => 1800,
    creates                   => "${was_profile_dir}/${full_was_profile_name}/servers/${server_name}",
    notify                    => Exec["Start JVM ${server_name} for ${full_was_profile_name}"],
    require                   => File["${software_location}/create-${server_name}-jvm.jf"],
  }

  exec {"Wait until JVM ${server_name} for ${full_was_profile_name} is created":
    path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                   => "bash -c 'while [[ ! -e ${was_profile_dir}/${full_was_profile_name}/servers/${server_name} ]]; do sleep 5; done'", 
    user                      => $was_user,
    timeout                   => 1800,
    creates                   => "${was_profile_dir}/${full_was_profile_name}/servers/${server_name}",
    require                   => Exec["Create JVM ${server_name} for ${full_was_profile_name}"],
    before                    => Exec["Start JVM ${server_name} for ${full_was_profile_name}"],
  }

  exec {"Start JVM ${server_name} for ${full_was_profile_name}":
    path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                   => "${was_profile_dir}/${full_was_profile_name}/bin/startServer.sh ${server_name}", 
    user                      => $was_user,
    timeout                   => 1800,
    refreshonly               => true,
    notify                    => Exec["Setup JVM ${server_name} for ${full_was_profile_name}"],
    require                   => File["${software_location}/start-${server_name}-jvm.jf"],
  }
  exec {"Setup JVM ${server_name} for ${full_was_profile_name}":
    path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                   => "${was_profile_dir}/${full_was_profile_name}/bin/wsadmin.sh -lang jython -f ${software_location}/setup-${server_name}-jvm.jf ${authentication_string}", 
    user                      => $was_user,
    timeout                   => 1800,
    refreshonly               => true,
    before                    => Exec["Restart Server ${server_name} to pick up log file changes"],
    require                   => [File["${software_location}/setup-${server_name}-jvm.jf"],
                                 Exec["Start JVM ${server_name} for ${full_was_profile_name}"]],
  }
  exec {"Configure HTTP Access Logs for ${server_name}":
    path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                   => "${was_profile_dir}/${full_was_profile_name}/bin/wsadmin.sh ${authentication_string} -lang jython -f ${software_location}/configure_HTTP_accessLog.py ${server_name} enable > ${software_location}/logs/configure_HTTP_access_for_${server_name}.log",
    user                      => $was_user,
    timeout                   => 1800,
    creates                   => "${software_location}/logs/configure_HTTP_access_for_${server_name}.log",
    notify                    => Exec["Stop ${server_name} so it can be restarted"],
    require                   => [File["${software_location}/configure_HTTP_accessLog.py"],
                                  Exec["Setup JVM ${server_name} for ${full_was_profile_name}"]],
  }
  exec {"Stop ${server_name} so it can be restarted":
    path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                   => "${was_profile_dir}/${full_was_profile_name}/bin/stopServer.sh ${server_name} ${authentication_string}",
    require                   => [Exec["Setup JVM ${server_name} for ${full_was_profile_name}"],
                                  Exec["Configure HTTP Access Logs for ${server_name}"]],
    refreshonly               => true,
    user                      => $was_user,
    notify                    => Exec["Restart Server ${server_name} to pick up log file changes"],
    timeout                   => 1800,
    before                    => Exec["Restart Server ${server_name} to pick up log file changes"],
  }

  exec {"Restart Server ${server_name} to pick up log file changes":
    path                      => '/bin:/usr/bin:/sbin:/usr/sbin',
    command                   => "${was_profile_dir}/${full_was_profile_name}/bin/startServer.sh ${server_name}",
    refreshonly               => true,
    user                      => $was_user,
    timeout                   => 1800,
  }
}

