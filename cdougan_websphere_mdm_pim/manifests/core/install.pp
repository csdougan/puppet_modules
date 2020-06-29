class cdougan_websphere_mdm_pim::core::install () inherits cdougan_websphere_mdm_pim {
  contain('cdougan_websphere_mdm_pim::core::configure_os::x11',
          'cdougan_websphere_mdm_pim::core::configure_os::environment_settings',
          'cdougan_websphere_mdm_pim::core::configure_os::users',
          'cdougan_websphere_mdm_pim::core::configure_os::install_packages',
          'cdougan_websphere_mdm_pim::core::configure_os::limits',
          'cdougan_websphere_mdm_pim::core::configure_os::set_sysctl',
          'cdougan_websphere_mdm_pim::core::configure_os::lvm',
          'cdougan_websphere_mdm_pim::core::configure_os::was_service',
          'cdougan_websphere_mdm_pim::core::install_middleware::install_manager',
          'cdougan_websphere_mdm_pim::core::install_middleware::install_was_release_version',
          'cdougan_websphere_mdm_pim::core::install_middleware::install_was_fixpacks',
          'cdougan_websphere_mdm_pim::core::install_middleware::install_jdk',
          'cdougan_websphere_mdm_pim::core::configure_middleware::create_profiles',
          'cdougan_websphere_mdm_pim::core::configure_middleware::set_soap_properties',
          'cdougan_websphere_mdm_pim::core::configure_middleware::profile_changes',
          'cdougan_websphere_mdm_pim::core::configure_middleware::delete_default_server',
          'cdougan_websphere_mdm_pim::common::db2_client',
          'cdougan_websphere_mdm_pim::core::install_mdm::unpack_mdmce',
          'cdougan_websphere_mdm_pim::core::install_mdm::install',
          'cdougan_websphere_mdm_pim::core::install_mdm::apply_mdmce_fixpack',
          'cdougan_websphere_mdm_pim::core::install_mdm::stop_servers_post_install',
          'cdougan_websphere_mdm_pim::core::install_mdm::post_install_changes')

  Class['cdougan_websphere_mdm_pim::core::configure_os::x11'] ->
  Class['cdougan_websphere_mdm_pim::core::configure_os::environment_settings'] ->
  Class['cdougan_websphere_mdm_pim::core::configure_os::users'] ->
  Class['cdougan_websphere_mdm_pim::core::configure_os::install_packages'] ->
  Class['cdougan_websphere_mdm_pim::core::configure_os::limits'] ->
  Class['cdougan_websphere_mdm_pim::core::configure_os::set_sysctl'] ->
  Class['cdougan_websphere_mdm_pim::core::configure_os::lvm'] ->
  Class['cdougan_websphere_mdm_pim::core::configure_os::was_service'] ->
  Class['cdougan_websphere_mdm_pim::core::install_middleware::install_manager'] ->
  Class['cdougan_websphere_mdm_pim::core::install_middleware::install_was_release_version'] ->
  Class['cdougan_websphere_mdm_pim::core::install_middleware::install_was_fixpacks']->
  Class['cdougan_websphere_mdm_pim::core::install_middleware::install_jdk'] ->
  Class['cdougan_websphere_mdm_pim::core::configure_middleware::create_profiles'] ->
  Class['cdougan_websphere_mdm_pim::core::configure_middleware::set_soap_properties'] ->
  Class['cdougan_websphere_mdm_pim::core::configure_middleware::profile_changes'] ->
  Class['cdougan_websphere_mdm_pim::core::configure_middleware::delete_default_server'] ->
  Class['cdougan_websphere_mdm_pim::common::db2_client'] ->
  Class['cdougan_websphere_mdm_pim::core::install_mdm::unpack_mdmce'] ->
  Class['cdougan_websphere_mdm_pim::core::install_mdm::install'] ->
  Class['cdougan_websphere_mdm_pim::core::install_mdm::apply_mdmce_fixpack'] ->
  Class['cdougan_websphere_mdm_pim::core::install_mdm::stop_servers_post_install'] ->
  Class['cdougan_websphere_mdm_pim::core::install_mdm::post_install_changes'] 
}
