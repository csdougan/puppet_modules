class cdougan_websphere_mdm_pim::core::configure_os::users() inherits cdougan_websphere_mdm_pim {
  group {$was_group:
    ensure            => present,
  }

  user {$was_user:
    ensure            => present,
    gid               => $was_group,
    require           => Group["${was_group}"],
    managehome        => true,
  }

  exec {"set_${was_user}_password":
    path              => '/bin:/usr/bin:/sbin:/usr/sbin',
    command           => "echo ${was_user_password} | passwd --stdin ${was_user}; chage -E -1 -M -1 ${was_user}",
    require           => User["${was_user}"],
    onlyif            => "/bin/grep -Eq '^${was_user}:[*!]!?:' /etc/shadow",
  }
}
