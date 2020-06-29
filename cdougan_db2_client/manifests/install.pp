# Install DB2 Client
class cdougan_db2_client::install () {
  include cdougan_db2_client::params
  $install_db2_client    = $cdougan_db2_client::params::install_db2_client
  $db2c_install_location = $cdougan_db2_client::params::db2c_install_location
  $software_location     = $cdougan_db2_client::params::software_location
  $nexus_url             = $cdougan_db2_client::params::nexus_url
  $nexus_reponame        = $cdougan_db2_client::params::nexus_reponame
  $nexus_group_name      = $cdougan_db2_client::params::nexus_group_name
  $db2c_artifact_name    = $cdougan_db2_client::params::db2c_artifact_name
  $db2c_version_number   = $cdougan_db2_client::params::db2c_version_number
  $db2c_package_type     = $cdougan_db2_client::params::db2c_package_type
  $db2_file              = $cdougan_db2_client::params::db2_file
  $db2_client_user       = $cdougan_db2_client::params::db2_client_user
  $install_path          = $cdougan_db2_client::params::install_path
  $db2_product           = $cdougan_db2_client::params::db2_product
  $db2_licence           = $cdougan_db2_client::params::db2_licence
  $db2_install_type      = $cdougan_db2_client::params::db2_install_type
  $db2_encryption        = $cdougan_db2_client::params::db2_encryption
  $db2_cli               = $cdougan_db2_client::params::db2_cli
  $db2_response_file     = $cdougan_db2_client::params::db2_response_file
  $db2c_package_url      = $cdougan_db2_client::params::db2c_package_url
  $db2_major_version     = $cdougan_db2_client::params::db2_major_version
  $db2_fp_version        = $cdougan_db2_client::params::db2_fp_version
  $install_group         = $cdougan_db2_client::params::install_group
  $rpm_packages_i686     = $cdougan_db2_client::params::rpm_packages_i686
  $rpm_packages_x64      = $cdougan_db2_client::params::rpm_packages_x64

  exec {'Remount /tmp':
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    command     => 'mount -o remount,rw,exec,suid /tmp > /etc/.remounted_tmp',
    creates     => "/etc/.remounted_tmp",
  }


  ensure_resource('package',$rpm_packages_x64, {'ensure' => 'installed'})
  cdougan_db2_client::update_x64{$rpm_packages_x64:
    require => Package[$rpm_packages_x64],
  }
  ensure_resource('package',$rpm_packages_i686, {'ensure' => 'installed', require => Pit_db2_client::Update_x64[$rpm_packages_x64]})
  ensure_resource('mount', '/tmp', {'options' => 'defaults'})
  ensure_resource('mount', '/home', {'options' => 'defaults'})
  
  exec {"mkdir -p ${install_path}":
    path   => '/bin:/sbin:/usr/bin:/usr/sbin',
    unless => "test -e ${install_path}",
  }

  exec {"mkdir -p ${software_location}":
    path   => '/bin:/sbin:/usr/bin:/usr/sbin',
    unless => "test -e ${software_location}",
  }

  exec {"mkdir -p ${software_location}/logs":
    path   => '/bin:/sbin:/usr/bin:/usr/sbin',
    unless => "test -e ${software_location}/logs",
  }

  exec {'Remount /home':
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    command     => 'mount -o remount,rw,exec,suid /home > /etc/.remounted_home',
    creates     => "/etc/.remounted_home",
  }

  if $install_db2_client {

    file {"/home/${db2_client_user}/.bash_profile":
      content => template('cdougan_db2_client/bash_profile.erb'),
      owner   => $db2_client_user,
      mode    => '0644',
      require => User[$db2_client_user],
    }

    file {$db2c_install_location:
      ensure  => directory,
      mode    => '0755',
      owner   => $db2_client_user,
      group   => $install_group,
      require => [
        User[$db2_client_user],
        Exec["mkdir -p ${install_path}"],
      ],
    }

    file {"${software_location}/DB2":
      ensure  => directory,
      owner   => $db2_client_user,
      group   => $install_group,
      require => [
        File[$db2c_install_location],
        Exec ["mkdir -p ${software_location}"],
      ],
    }

    file{"${software_location}/DB2/${db2_response_file}":
      source  => "puppet:///modules/cdougan_db2_client/${db2_response_file}",
      owner   => $db2_client_user,
      group   => $install_group,
      require => [
        File[$db2c_install_location],
        File["${software_location}/DB2"]
      ],
    }

    archive {"${software_location}/${db2c_artifact_name}.${db2c_package_type}":
      source       => "${nexus_url}/${nexus_reponame}/content/${nexus_group_name}/${db2c_artifact_name}/${db2c_version_number}/${db2c_artifact_name}-${db2c_version_number}.tgz",
      #source       => $db2c_package_url,
      extract      => true,
      cleanup      => true,
      extract_path => $db2c_install_location,
      creates      => "${db2c_install_location}/rtcl/db2_install",
      user         => $db2_client_user,
      group        => $install_group, 
      require      => File["${software_location}/DB2/${db2_response_file}"],
    }
    
    file {"${db2c_install_location}/tmp":
      ensure  => directory,
      owner   => $db2_client_user,
      group   => $install_group,
      mode    => '0777',
      require => [File[$db2c_install_location],Archive["${software_location}/${db2c_artifact_name}.${db2c_package_type}"]],
    }

    file {$db2_file:
      ensure  => directory,
      owner   => $db2_client_user,
      group   => $install_group,
      mode    => '0775',
      require => File[$db2c_install_location],
    }

    exec {'Install DB2 Client':
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      environment => "DB2TMPDIR=/${db2c_install_location}/tmp",
      command     => "cd ${db2c_install_location}/rtcl && ./db2setup -r ${software_location}/DB2/${db2_response_file}  > ${software_location}/logs/install_db2_client.log",
      user        => root,
      require     => [
        File["${db2c_install_location}/tmp"],
        Exec["mkdir -p ${install_path}"],
        Exec["mkdir -p ${software_location}"],
        Exec["mkdir -p ${software_location}/logs"],
        Archive["${software_location}/${db2c_artifact_name}.${db2c_package_type}"],
        File["${software_location}/DB2/${db2_response_file}"],
        User[$db2_client_user],
        Exec['Remount /tmp'],
        Pit_db2_client::Update_x64[$rpm_packages_x64],
        Package[$rpm_packages_x64],
        Package[$rpm_packages_i686],
        Exec['Remount /home']],
      onlyif      => "test -e ${software_location}/logs",
      creates     => "${db2c_install_location}/V${db2_major_version}/install",
    }

    exec {'Create DB2 Client Instance':
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      command     => "bash -c 'cd ${db2_file}/instance; ./db2icrt -s client ${db2_client_user}' > ${software_location}/logs/create_db2_client_instance.log",
      require     => [Exec['Install DB2 Client'],
                      File["/home/${db2_client_user}/.bash_profile"]],
      creates     => "/home/${db2_client_user}/sqllib",
      user        => root,
      notify      => Exec['Set DB2 Client DIAGSIZE'],
    }

    exec {'Set DB2 Client DIAGSIZE':
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      command     => "bash -c 'cd ~${db2_client_user}; source ~${db2_client_user}/.bash_profile; ${db2_file}/bin/db2 \"update dbm cfg using DIAGSIZE 50\"'",
      refreshonly => true,
      user        => $db2_client_user,
      require     => Exec['Create DB2 Client Instance'],
    }
  }
}
