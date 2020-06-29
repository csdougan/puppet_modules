class cdougan_was::configure_os::users () inherits cdougan_was { 
  group {$was_group:
    ensure            => present,
  }

  user {$was_user:
    ensure            => present,
    gid               => $wasgroup,
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
