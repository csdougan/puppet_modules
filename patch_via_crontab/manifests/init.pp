class patch_via_crontab (
  $day_of_week = undef,
  $week_number = undef,
  $update_time = '00:00',
  $update_all_packages = false,
  $day_of_month = undef,
  $enabled = false,
  $reboot = false,
) {
  if $update_all_packages {
    $update_command = "yum update -y"
  } else {
    $update_command = "yum update-minimal --security -y"
  }
  if $reboot {
    $reboot_command = "&& reboot"
  } else {
    $reboot_command = ""
  }
  if $enabled {
    $cronfile_state = "present"
  } else {
    $cronfile_state = "absent"
  }
  $split_time=split($update_time,':')
  $update_hour=$split_time[0]
  $update_min=$split_time[1]
  if ($day_of_week != undef) {
    case $day_of_week {
    '1', '01', 'mon', 'Mon', 'monday', 'Monday': {$weekday_number=1}
    '2', '02', 'tue', 'Tue', 'tuesday', 'Tuesday': {$weekday_number=2}
    '3', '03', 'wed', 'Wed', 'wednesday', 'Wednesday': {$weekday_number=3}
    '4', '04', 'thu', 'Thu', 'thursday', 'Thursday': {$weekday_number=4}
    '5', '05', 'fri', 'Fri', 'friday', 'Friday': {$weekday_number=5}
    '6', '06', 'sat', 'Sat', 'saturday', 'Saturday': {$weekday_number=6}
    default : {$weekday_number=7}
  }
  if ($week_number != undef) {
    case $week_number {
      '1':      {$crontab_entry = "${update_min} ${update_hour} * * ${weekday_number} root [ $(date +\\%d) -le 07 ] && ${update_command} ${reboot_command}\n\n"}
      '2':      {$crontab_entry = "${update_min} ${update_hour} * * ${weekday_number} root [ $(date +\\%d) -le 14 ] &&  [ $(date +\\%d) -gt 07 ] && ${update_command} ${reboot_command}\n\n"}
      '3':      {$crontab_entry = "${update_min} ${update_hour} * * ${weekday_number} root [ $(date +\\%d) -le 21 ] &&  [ $(date +\\%d) -gt 14 ] && ${update_command} ${reboot_command}\n\n"}
      '4':      {$crontab_entry = "${update_min} ${update_hour} * * ${weekday_number} root [ $(date +\\%d) -le 28 ] &&  [ $(date +\\%d) -gt 21 ] && ${update_command} ${reboot_command}\n\n"}
      '5':      {$crontab_entry = "${update_min} ${update_hour} * * ${weekday_number} root [ $(date +\\%d) -le 31 ] &&  [ $(date +\\%d) -gt 28 ] && ${update_command} ${reboot_command}\n\n"}
      default : {$crontab_entry = "${update_min} ${update_hour} * * ${weekday_number} root [ $(date +\\%d) -le 07 ] && ${update_command} ${reboot_command}\n\n" }
    }
  } else {
      $weekday_number='*'
      if $day_of_month != undef {
        $crontab_entry = "${update_min} ${update_hour} ${day_of_month} * * root ${update_command} ${reboot_command}\n\n"
      }
    }
    file {"${name}_update_crontab":
      ensure    => $cronfile_state,
      path      => '/etc/cron.d/update_schedule.cron',
      owner     => 'root',
      group     => 'root',
      mode      => '0644',
      content   => "${crontab_entry}\n"
    }
  }
}
