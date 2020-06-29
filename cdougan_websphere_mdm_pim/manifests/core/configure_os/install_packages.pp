class cdougan_websphere_mdm_pim::core::configure_os::install_packages () inherits cdougan_websphere_mdm_pim {
  package { $pim_core_rpm_prereqs:
    ensure => installed,
  }
}
