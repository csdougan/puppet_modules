class {"cdougan_websphere_mdm_pim": 
  application_layer        => "SYST",
  pim_server_type          => "core",
  app_layer_number         => "1",
  was_profile_name         => "MPSL",
  was_instance_number      => "1",
  db2_database_user        => "mpslsds1",
  db2_database_password    => "somepassword",
  db2_database_hostname    => "somehost.co.uk",
  db2_skip_connection_test => false,
  db2_manual_user_data     => false,
  install_mdm              => true,
  install_db2              => true,
  setup_lvm                => true,
  pv_name                  => "/dev/sdb",
}
