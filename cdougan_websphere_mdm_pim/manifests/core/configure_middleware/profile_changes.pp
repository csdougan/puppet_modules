class cdougan_websphere_mdm_pim::core::configure_middleware::profile_changes() inherits cdougan_websphere_mdm_pim {
  file {"${install_path}/pim_profile":
    ensure => present,
    content => template('cdougan_websphere_mdm_pim/pim_profile'),
    owner => $was_user,
    group => $was_group,
    mode => 0750,
  }

  exec {"Add Pim Profile to ${was_user} bashrc":
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    command => "echo \". ${install_path}/pim_profile\n\" >> ~${was_user}/.bashrc",
    unless => "grep ${install_path}/pim_profile ~${was_user}/.bashrc",
    require => File["${install_path}/pim_profile"],
  }

  exec {"Add Pim Profile to root bashrc":
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    command => "echo \". ${install_path}/pim_profile\n\" >> ~root/.bashrc",
    unless => "grep ${install_path}/pim_profile ~root/.bashrc",
    require => File["${install_path}/pim_profile"],
  }
}
