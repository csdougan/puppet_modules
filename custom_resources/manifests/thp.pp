define custom_resources::thp()
  {
  exec { "set transparent_hugepage_enabled to ${name}":
    command => "/bin/echo ${name} > /sys/kernel/mm/transparent_hugepage/enabled",
    unless  => "/bin/grep -c \"\\[${name}\\]\" /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null",
  }

  exec { "set transparent_hugepage_defrag to ${name}":
    command => "/bin/echo ${name} > /sys/kernel/mm/transparent_hugepage/defrag",
    unless  => "/bin/grep -c \"\\[${name}\\]\" /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null",
  }
}
