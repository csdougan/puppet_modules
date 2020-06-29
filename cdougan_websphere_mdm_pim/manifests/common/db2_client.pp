class cdougan_websphere_mdm_pim::common::db2_client ()
inherits cdougan_websphere_mdm_pim {
if $install_db2 {

  class {'cdougan_db2_client':
    software_location => $software_location,
    install_path      => $install_path,
    nexus_url         => $nexus_url,
    notify            => Exec['Set up DB2 Node'],
  }

  file {"${software_location}/setup_db2_node.sh":
    content     => template('cdougan_websphere_mdm_pim/setup_db2_node.erb'),
    owner       => root,
    group       => root,
    mode        => 0755,
  }

  exec {"Set up DB2 Node":
    path        => "/bin:/sbin:/usr/bin:/usr/sbin",
    command     => "${software_location}/setup_db2_node.sh",
    require     => [Class['cdougan_db2_client'],
                    File["${software_location}/setup_db2_node.sh"]],
    refreshonly => true,
  }
}
}
