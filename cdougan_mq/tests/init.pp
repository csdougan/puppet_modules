class {"cdougan_mq":
  environment_layer           => "SIT",
  environment_number          => "4",
  single_character_layer_id   => "N",
  application_indentifer      => "WPOS",
  application_instance_number => "1",
  application_purpose         => "Z2SH",
  was_user                    => "wasuser",
  mq_outbound_topic_string    => "ESITOPIC",
  queue_names                 => "ESI_INPUT",
  mq_software_pv_name => "/dev/sdb1",
  mq_log_pv_name => "/dev/sdb2",
  mq_qmgr_pv_name => "/dev/sdb3",

}

