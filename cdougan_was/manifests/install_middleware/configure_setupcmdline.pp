class cdougan_was::install_middleware::configure_setupcmdline() inherits cdougan_was {
  file {"${was_install_location}/bin/setupCmdLine.sh":
    content => template('cdougan_was/setupCmdLine.sh-main.erb'),
    owner   => $was_user,
    group   => $was_group,
   }
}
