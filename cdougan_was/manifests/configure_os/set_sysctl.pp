class cdougan_was::configure_os::set_sysctl ( 
) inherits cdougan_was { 
  sysctl {'net.ipv4.icmp_echo_ignore_broadcasts':            ensure => 'present',  permanent => 'yes',  value => '0', }
  sysctl {"net.ipv4.conf.${primary_interface}.rp_filter":    ensure => 'present',  permanent => 'yes',  value => '0', }
  sysctl { 'net.core.rmem_default':	                     ensure => 'present',  permanent => 'yes',  value => '26214400', }
  sysctl { 'net.core.rmem_max':	                             ensure => 'present',  permanent => 'yes',  value => '26214400', }
  sysctl { 'net.core.wmem_default':	                     ensure => 'present',  permanent => 'yes',  value => '26214400', }
  sysctl { 'net.core.wmem_max':	                             ensure => 'present',  permanent => 'yes',  value => '26214400', }
}
 

