class cdougan_tomcat (
$version	= "present"
) {
if $operatingsystemmajrelease == '6' {
  $tomcatname="tomcat6"
  $conf_file="tomcat6.conf"
  $user_file="tomcat-users6.xml"
} else {
  $tomcatname="tomcat"
  $conf_file="tomcat7.conf"
  $user_file="tomcat-users7.xml"
}

package {"${tomcatname}":
	ensure => 'latest',
}

package {"${tomcatname}-admin-webapps":
  ensure => 'latest',
  require => Package["${tomcatname}"],
}

service {"${tomcatname}":
  ensure  => 'running',
  require => Package["${tomcatname}"],
}

file {"/etc/${tomcatname}/${tomcatname}.conf":
  ensure  => present,
  source  => "puppet:///modules/cdougan_tomcat/${conf_file}",
  owner   => root,
  group   => tomcat,
  mode    => "0664",
  require => Package["${tomcatname}"],
}

file {"/etc/${tomcatname}/tomcat-users.xml":
  ensure  => present,
  source  => "puppet:///modules/cdougan_tomcat/${user_file}",
  owner   => root,
  group   => tomcat,
  mode    => "0664",
  require => Package["${tomcatname}"],
}

file {"/etc/${tomcatname}/jmxremote.access":
  ensure  => present,
  source  => "puppet:///modules/cdougan_tomcat/jmxremote.access",
  owner   => tomcat,
  group   => tomcat,
  mode    => "0600",
  require => [Package["${tomcatname}"],File["/etc/${tomcatname}/${tomcatname}.conf"]],
}

file {"/etc/${tomcatname}/jmxremote.password":
  ensure  => present,
  source  => "puppet:///modules/cdougan_tomcat/jmxremote.password",
  owner   => tomcat,
  group   => tomcat,
  mode    => "0600",
  require => [Package["${tomcatname}"],File["/etc/${tomcatname}/${tomcatname}.conf"],File["/etc/${tomcatname}/jmxremote.access"]],
  notify  => Service["${tomcatname}"],
}
}
