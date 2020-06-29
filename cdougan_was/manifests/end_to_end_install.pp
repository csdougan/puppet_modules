class cdougan_was::end_to_end_install () inherits cdougan_was {
  contain('cdougan_was::configure_os::x11',
          'cdougan_was::configure_os::environment_settings',
          'cdougan_was::configure_os::users',
          'cdougan_was::configure_os::install_packages',
          'cdougan_was::configure_os::limits',
          'cdougan_was::configure_os::set_sysctl',
          'cdougan_was::configure_os::lvm',
          'cdougan_was::configure_os::was_service',
          'cdougan_was::install_middleware::setup_app_dir',
          'cdougan_was::install_middleware::install_manager',
          'cdougan_was::install_middleware::install_was_release_version',
          'cdougan_was::install_middleware::install_was_fixpacks',
          'cdougan_was::install_middleware::install_was_ifit',
          'cdougan_was::install_middleware::configure_setupcmdline',
          'cdougan_was::install_middleware::install_jdk',
          'cdougan_was::configure_middleware::create_profile')
#          'cdougan_was::configure_middleware::set_soap_properties',

  Class['cdougan_was::configure_os::x11'] ->
  Class['cdougan_was::configure_os::environment_settings'] ->
  Class['cdougan_was::configure_os::users'] ->
  Class['cdougan_was::configure_os::install_packages'] ->
  Class['cdougan_was::configure_os::limits'] ->
  Class['cdougan_was::configure_os::set_sysctl'] ->
  Class['cdougan_was::configure_os::lvm'] ->
  Class['cdougan_was::configure_os::was_service'] ->
  Class['cdougan_was::install_middleware::setup_app_dir'] ->
  Class['cdougan_was::install_middleware::install_manager'] ->
  Class['cdougan_was::install_middleware::install_was_release_version'] ->
  Class['cdougan_was::install_middleware::install_was_fixpacks'] ->
  Class['cdougan_was::install_middleware::install_was_ifit'] ->
  Class['cdougan_was::install_middleware::configure_setupcmdline'] ->
  Class['cdougan_was::install_middleware::install_jdk'] ->
  Class['cdougan_was::configure_middleware::create_profile']
#  Class['cdougan_was::configure_middleware::set_soap_properties'] ->
}
