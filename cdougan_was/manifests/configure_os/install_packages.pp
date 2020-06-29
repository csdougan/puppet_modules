class cdougan_was::configure_os::install_packages () inherits cdougan_was {
  ensure_packages ($was_rpm_prereqs, { ensure => 'installed' })
}
