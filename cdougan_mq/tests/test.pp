  $mq_server_version = "8.0.0.2"
  $mq_fixpack_version = "8.0.0.3"

  $mq_version_array = split($mq_server_version,'\.')
  $mq_maj_ver = $mq_version_array[0]
  $mq_min_ver = $mq_version_array[1]
  $mq_mic_ver = $mq_version_array[2]
  $mq_fp_ver  = $mq_version_array[3]
  $mq_rpm_version = "${mq_maj_ver}.${mq_min_ver}.${mq_mic_ver}-${mq_fp_ver}"
notify {"$mq_version_array":}
