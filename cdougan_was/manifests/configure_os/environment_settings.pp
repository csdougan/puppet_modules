class cdougan_was::configure_os::environment_settings () inherits cdougan_was {
  file {'/etc/profile.d/was.sh':
    ensure            => present,
    source            => "puppet:///modules/cdougan_was/was.sh",
    owner             => root,
    group             => root,
    mode              => 0755,
  }
  ensure_resource('file','/var/log/messages',{'mode' => '0644'})
}
