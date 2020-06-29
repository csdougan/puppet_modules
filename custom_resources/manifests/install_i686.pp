define custom_resources::install_i686()
{
  $basename_array = split($name,'\.')
  $basename = $basename_array[0]
  exec {"yum update -y ${basename}.x86_64":
    path   => '/bin:/sbin:/usr/bin:/usr/sbin',
    unless => "rpm -q ${name}",
    onlyif => "rpm -q ${basename}.x86_64",
    before => Package[$name],
  }
  package {$name:
    ensure => installed,
  }
}
