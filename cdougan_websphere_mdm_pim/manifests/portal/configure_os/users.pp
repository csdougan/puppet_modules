class cdougan_websphere_mdm_pim::portal::configure_os::users () inherits cdougan_websphere_mdm_pim { 
  group {$portal_group:
    ensure            => present,
  }

  user {$portal_user:
    ensure            => present,
    gid               => $portal_group,
    require           => Group["${portal_group}"],
    managehome        => true,
  }

  exec {"set_${portal_user}_password":
    path              => '/bin:/usr/bin:/sbin:/usr/sbin',
    command           => "echo ${portal_user_password} | passwd --stdin ${portal_user}; chage -E -1 -M -1 ${portal_user}",
    require           => User["${portal_user}"],
    onlyif            => "/bin/grep -Eq '^${portal_user}:[*!]!?:' /etc/shadow",
  }
}
