class cdougan_oracle_db::os_setup::set_sysctl () {
  sysctl { 'kernel.shmmni':                  ensure => 'present',  permanent => 'yes',  value => '4096', }
  sysctl { 'kernel.sem':                  ensure => 'present',  permanent => 'yes',  value => '250 32000 100 128', }
  sysctl { 'fs.file-max':                  ensure => 'present',  permanent => 'yes',  value => '6815744', }
  sysctl { 'fs.aio-max-nr':                  ensure => 'present',  permanent => 'yes',  value => '1048576', }
  sysctl { 'net.ipv4.ip_local_port_range':  ensure => 'present',  permanent => 'yes',  value => '9000 65535', }
  sysctl { 'net.core.rmem_default':          ensure => 'present',  permanent => 'yes',  value => '262144', }
  sysctl { 'net.core.rmem_max':                  ensure => 'present',  permanent => 'yes',  value => '4194304', }
  sysctl { 'net.core.wmem_default':          ensure => 'present',  permanent => 'yes',  value => '262144', }
  sysctl { 'net.core.wmem_max':                  ensure => 'present',  permanent => 'yes',  value => '1048576', }
  sysctl { 'kernel.shmmax':                 ensure => 'present',  permanent => 'yes',  value => $::shmmax, }
  sysctl { 'kernel.shmall':                 ensure => 'present',  permanent => 'yes',  value => $::shmall, }
  sysctl { 'kernel.panic_on_oops':          ensure => 'present',  permanent => 'yes',  value => '1', }
}

