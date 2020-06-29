class cdougan_websphere_mdm_pim::core::configure_os::environment_settings () inherits cdougan_websphere_mdm_pim {
  file {'/etc/profile.d/was.sh':
    ensure            => present,
    source            => "puppet:///modules/cdougan_websphere_mdm_pim/was.sh",
    owner             => root,
    group             => root,
    mode              => 0755,
  }
}
