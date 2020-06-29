define cdougan_users_groups::manage_users(
  $ensure             = undef,
  $password           = undef,
  $default_password   = "password123",
  $managehome         = true,
  $shell              = '/bin/bash',
  $primary_group      = undef,
  $groups             = undef,
  $homedir            = undef,
  $system             = false,
  $purge_ssh_keys     = false,
  $expiry             = absent,
  $password_max_age   = "-1",
  $comment            = "",
  $nopasswd           = 'false',
) {
  if ($ensure == present) or ($ensure == "present") or ($ensure == "ad") {
    if ($primary_group != undef) {
      $u_primary_group  = $primary_group
    } else {
      $u_primary_group  = $title
    }
    exec {"create the ${u_primary_group} group so useradd for ${title} doesnt fail":
      path              => '/bin:/usr/bin:/sbin:/usr/sbin',
      command           => "groupadd ${u_primary_group}",
      unless            => "cat /etc/group | cut -d: -f1 | grep ^${u_primary_group}$",
      before            => User[$title],
    }

    if ($ensure == "ad" ) {
      file { "/home/${title}":
        ensure          => directory,
        owner           => $title,
        group           => $primary_group,
        require         => User[$title],
      }
      $u_ensure         = present
      $u_password       = undef
      $u_purge_ssh_keys = true
      $u_expiry         = '-1'
      $u_nopasswd       = true
      $u_home           = "/home/${title}"
    } else {
      if $homedir != undef {
        file { $homedir:
          ensure        => directory,
          owner         => $title,
          group         => $primary_group,
          require => User[$title],
        }
      } else {
        file { "/home/${title}":
          ensure        => directory,
          owner         => $title,
          group         => $primary_group,
          require       => User[$title],
        }
      }
      $u_ensure         = $ensure
      $u_password       = $password
      $u_purge_ssh_keys = $purge_ssh_keys
      $u_expiry         = $expiry
      $u_nopasswd       = $nopasswd
      $u_home           = $homedir
    }
  
    if  ($u_expiry == "-1") {
      $expiration       = "absent"
      $chage_command    = "chage -E -1 -M -1 -d -1"
      exec { "unexpire_account_${title}":
        command         => "/sbin/faillock --user ${title} --reset; /usr/bin/${chage_command} ${title}",
        path            => '/bin:/usr/bin:/sbin:/usr/sbin',
        onlyif          => "/usr/bin/chage -l ${title} | /bin/grep 'password must be changed'",
        require         => User[$title],
      }
    } else  {
      $expiration       = $u_expiry
      $chage_command    = "chage -d 0"
    }

    user { $title:
      ensure                  => $u_ensure,
      managehome              => $managehome,
      shell                   => $shell,
      home                    => $u_home,
      groups                  => $groups,
      gid                     => $u_primary_group,
      system                  => $system,
      comment                 => $comment,
      password                => $password,
      purge_ssh_keys          => $u_purge_ssh_keys,
      expiry                  => "$expiration",
      password_max_age        => "$password_max_age",
    }

    if ($u_nopasswd == "false") {
      if $password == undef {
        exec { "set_password_for_${title}":
          command             => "/bin/echo ${default_password} | /usr/bin/passwd ${title} --stdin; /sbin/faillock --user ${title} --reset; /usr/bin/${chage_command} ${title}",
          onlyif              => "/bin/grep -Eq '^${title}:([!].*!?:|:)' /etc/shadow",
          path                => '/bin:/usr/bin:/sbin:/usr/sbin',
          require             => User[$title],
        }
      }
    } else {
      exec { "clear_password_for_${title}":
        command               => "/usr/bin/passwd -d ${title}; /sbin/faillock --user ${title} --reset; /usr/bin/${chage_command} ${title}",
        unless                => "/bin/grep -Eq '^${title}:([!].*!?:|:)' /etc/shadow",
        path                  => '/bin:/usr/bin:/sbin:/usr/sbin',
        require               => User[$title],
      }
    }
  } else {
    if ( $ensure == absent ) or ( $ensure == "absent" ) {
      user { $title:
        ensure                => absent,
      }
    } else {
      if ( $password != undef ) {
        exec {"set password for ${title} only if they exist.  Dont manage the user resource here":
          command             => "usermod -p '${password}' ${title}",
          onlyif              => "/bin/grep ^${title}: /etc/passwd",
          unless              => "/bin/grep ^${title}: /etc/shadow|/bin/grep '${password}'",
          path                => '/bin:/usr/bin:/sbin:/usr/sbin',
        }
      }
    } 
  }
}
