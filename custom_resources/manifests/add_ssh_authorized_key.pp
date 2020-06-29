# Adds SSH Authorized key
define custom_resources::add_ssh_authorized_key(
  $ensure = present,
  $key    = undef,
  $type   = 'ssh-rsa'
) {
  if ! defined (File["/home/${title}/.ssh"]) {
    file { "/home/${title}/.ssh":
      ensure  => directory,
      owner   => $title,
      mode    => '0700',
      require => User[$title],
    }
  }
  ssh_authorized_key { "${title}@${::hostname}":
    ensure  => $ensure,
    key     => $key,
    type    => $type,
    user    => $title,
    require => [User[$title],File["/home/${title}/.ssh"]],
  }
}
