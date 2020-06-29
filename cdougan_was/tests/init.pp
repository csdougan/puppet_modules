class {"cdougan_was":
  setup_lvm            => true,
  server_names            => "ofWDeliver1,ofWDeliver2,ofWDeliver3,ofReporting1,ofWebServices1,ofIntegration1",
  environment_layer    => "SIT",
  environment_number     => "1",
  was_flavour          => "ND",
  was_profile_name     => "WROF",
  was_instance_number  => "1",
}
