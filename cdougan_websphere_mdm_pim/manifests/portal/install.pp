class cdougan_websphere_mdm_pim::portal::install () inherits cdougan_websphere_mdm_pim {
  contain('cdougan_websphere_mdm_pim::portal::configure_os::users',
          'cdougan_websphere_mdm_pim::portal::configure_os::lvm',
          'cdougan_websphere_mdm_pim::portal::configure_os::install_packages',
          'cdougan_websphere_mdm_pim::common::db2_client')


  Class['cdougan_websphere_mdm_pim::portal::configure_os::users'] ->
  Class['cdougan_websphere_mdm_pim::portal::configure_os::lvm'] ->
  Class['cdougan_websphere_mdm_pim::portal::configure_os::install_packages'] ->
  Class['cdougan_websphere_mdm_pim::common::db2_client']
}
