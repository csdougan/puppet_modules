#Sets up a user with a default password
define custom_resources::user_with_default_pwd (
  $default_password = 'password123',
  $ensure = present,
  $gid    = undef,
  $groups = [],
  $password_max_age = '-1',
  $expiration       = 'absent'
) {
  if ! $gid {
    $primary_group = $title
  } else {
    $primary_group = $gid
  }
  if ! $groups {
    $additional_groups = $primary_group
  } else {
    $additional_groups = $groups
  }
  ensure_resource(group,$primary_group,{'ensure' => 'present'})
  ensure_resource(group,$additional_groups,{'ensure' => 'present'})
  user {$title:
    ensure           => $ensure,
    gid              => $primary_group,
    groups           => $additional_groups,
    password_max_age => $password_max_age,
    expiry           => $expiration,
    managehome       => true,
    require          => [Group[$gid],Group[$groups]],
  }
  exec { "set_password_for_${title}":
    command =>
      "/bin/echo ${default_password} | /usr/bin/passwd ${title} --stdin",
    onlyif  =>
      "/bin/grep -Eq '^${title}:([!].*!?:|:)' /etc/shadow",
    path    =>
      '/bin:/usr/bin:/sbin:/usr/sbin',
    require => User[$title],
  }
}

