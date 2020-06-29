class cdougan_websphere_mdm_pim::portal::configure_os::install_packages () inherits cdougan_websphere_mdm_pim {
  package { $pim_portal_rpm_prereqs:
    ensure => installed,
  }
}
