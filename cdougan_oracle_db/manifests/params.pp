class cdougan_oracle_db::params () {

  $setup_lvm               = $cdougan_oracle_db::setup_lvm ? {
    undef   => true,
    default => $cdougan_oracle_db::setup_lvm,
  }
  $dbname                  = downcase($cdougan_oracle_db::dbname)
  $environment_number      = $cdougan_oracle_db::environment_number
  $dbversion               = $cdougan_oracle_db::dbversion
  $environment_layer       = $cdougan_oracle_db::environment_layer
  $layer                   = downcase($environment_layer)
  $upcase_dbname           = upcase($dbname)
  $environment_name        = "${layer}${environment_number}"
  $upcase_environment_name = upcase($environment_name)
  $concateddbver           = (regsubst($dbversion, '\.', '', 'G'))
  $oracle_sid              = "${dbname}${environment_name}"
  $oracle_home_name        = "${concateddbver}_${upcase_dbname}${upcase_environment_name}_DBHOME"
  $module_file_path        = "puppet:///modules/${module_name}"
  $ora_vg_name             = $cdougan_oracle_db::ora_vg_name ? {
    undef   => 'oravg',
    default => $cdougan_oracle_db::ora_vg_name,
  }
  $env_vg_name             = $cdougan_oracle_db::env_vg_name ? {
    undef   => "${environemnt_name}vg",
    default => $cdougan_oracle_db::env_vg_name,
  }
  $fra_vg_name             = $cdougan_oracle_db::fra_vg_name ? {
    undef   => 'fravg',
    default => $cdougan_oracle_db::fra_vg_name,
  }
  $redo_vg_name            = $cdougan_oracle_db::redo_vg_name ? {
    undef   => 'redovg',
    default => $cdougan_oracle_db::redo_vg_name,
  }
  $ora_disk                = $cdougan_oracle_db::ora_disk ? {
    undef   => '/dev/sdb',
    default => $cdougan_oracle_db::ora_disk,
  }
  $env_disk                = $cdougan_oracle_db::env_disk ? {
    undef   => '/dev/sdc',
    default => $cdougan_oracle_db::env_disk,
  }
  $fra_disk                = $cdougan_oracle_db::fra_disk ? {
    undef   => '/dev/sdd',
    default => $cdougan_oracle_db::fra_disk,
  }
  $redo_disk               = $cdougan_oracle_db::redo_disk ? {
    undef   => '/dev/sde',
    default => $cdougan_oracle_db::redo_disk,
  }
  $nexus_url               = $cdougan_oracle_db::nexus_url ? {
    undef   => 'http://abc-watm-artefactrepo.somehost.co.uk:8081/nexus/service/local/repositories',
    default => $cdougan_oracle_db::nexus_url,
  }
  $nexus_repo              = $cdougan_oracle_db::nexus_repo ? {
    undef   => 'A0528-OracleDB-Release',
    default => $cdougan_oracle_db::nexus_repo,
  }
  $ddboost_password        = $cdougan_oracle_db::ddboost_password ? {
    undef   => 'Turkey123!!!',
    default => $cdougan_oracle_db::ddboost_password,
  }

  $packagelist             = [
    'binutils',
    'compat-libstdc++-33.x86_64',
    'compat-libcap1.x86_64',
    'gcc.x86_64',
    'gcc-c++.x86_64',
    'glibc.x86_64',
    'glibc-devel.x86_64',
    'ksh.x86_64',
    'libaio.x86_64',
    'libaio-devel.x86_64',
    'libgcc.x86_64',
    'libstdc++.x86_64',
    'libstdc++-devel.x86_64',
    'libxcb.x86_64',
    'libX11.x86_64',
    'libXau.x86_64',
    'libXi.x86_64',
    'libXtst.x86_64',
    'make.x86_64',
    'net-tools',
    'nfs-utils',
    'smartmontools',
    'sysstat.x86_64',
    'psmisc.x86_64',
    'unzip.x86_64',
    'zip.x86_64',
    'xorg-x11-xauth.x86_64',
    'xorg-x11-apps.x86_64',
    'xterm.x86_64',
    'unixODBC.x86_64',
    'unixODBC-devel.x86_64',
    'dejavu-serif-fonts',
    'xorg-x11-server-Xorg.x86_64']

    $packagelist_i686 = [
    'compat-libstdc++-33.i686',
    'glibc.i686',
    'glibc-devel.i686',
    'unixODBC.i686',
    'unixODBC-devel.i686',
    'libgcc.i686',
    'libaio.i686',
    'libaio-devel.i686',
    'libstdc++.i686',
    'libstdc++-devel.i686',
    'libxcb.i686',
    'libXtst.i686',
    'libX11.i686',
    'libXau.i686',
    'libXi.i686']

  $ostype = 'linux'
  $nexus_oracle_db_path = "${nexus_url}/${nexus_repo}/content/${ostype}/db/${concateddbver}/"
  if ($dbversion == '12.2.0.1') {
    $install_archive_file_one = "db-${concateddbver}.zip"
    $install_archive_file_two = undef
  } elsif ($dbversion == '12.1.0.2')  {
    $install_archive_file_one = "db-${concateddbver}-1of2.zip"
    $install_archive_file_two = "db-${concateddbver}-2of2.zip"
  } else {
    $install_archive_file_one = "db-${concateddbver}-1of7.zip"
    $install_archive_file_two = "db-${concateddbver}-2of7.zip"
  }
  if $operatingsystemmajrelease == '6' {
    $fs_type = 'ext4'
  } else {
    $fs_type = 'xfs'
  }

  if $cdougan_oracle_db::opatch_version == undef {
    $a = split($dbversion,'.')
    if $a[0] == '11' {
      $opatch_version = '11.2.0.3.16'
    } else {
      $opatch_version = '12.2.0.1.9'
    }
  } else {
    $opatch_version = $cdougan_oracle_db::opatch_version
  }
  $nexus_oracle_opatch_path = "${nexus_url}/${nexus_repo}/content/${ostype}/opatch/${opatch_version}/"
  $opatch_archive_file = "opatch-${opatch_version}.zip"

  $ip_octets=split($::ipaddress,'\.')
  if $ip_octets[1] == '14' {
    $ddboost_host='1.1.8.3'
    $ddboost_path='/ORA'
  } elsif $ip_octets[1] == '36' {
    $ddboost_host = '1.4.0.3'
    $ddboost_path='/ORA'
  } elsif $ip_octets[1] == '12' {
    $ddboost_host = '1.2.8.3'
    $ddboost_path = '/ORA_DR'
  } elsif $ip_octets[1] == '132'{
    $ddboost_host = '1.3.0.2'
    $ddboost_path = '/ORA_DR'
  } elsif $ip_octets[1] == '134' {
    $ddboost_host = '1.1.0.2'
    $ddboost_path='/ORA_NON-PROD'
  } elsif $ip_octets[1] == '135' {
    $ddboost_host = '1.3.0.2'
    $ddboost_path='/ORA_NON-PROD'
  } elsif $ip_octets[1] == '13' {
    $ddboost_host='1.1.8.1'
    $ddboost_path='/ORA_NON-PROD'
  } else {
    $ddboost_host='1.1.8.1'
    $ddboost_path='/ORA_NON-PROD'
  }
  $hostname_array=split($::hostname,'-')
  $server_id=$hostname_array[1]
  $ddboost_user='oracle_ddboost'
  #  $ddboost_path="/${server_id}_ora_${oracle_sid}"

  if ($::memorysize_mb <= 8196) {
    $desired_swap_size = 8
  } elsif ($::memorysize_mb > 8196) and ($::memorysize_mb <= 16384) {
    $float_swap_size = ($::memorysize_mb / 1024)
    $desired_swap_size = inline_template('<%= @float_swap_size.to_i %>')
  } else {
    $desired_swap_size = 16
  }
  
  $oraenv_nproc_soft = $cdougan_oracle_db::oraenv_nproc_soft? { 
    undef   => '2047',
    default => $cdougan_oracle_db::oraenv_nproc_soft
  }
  
  $oraenv_nproc_hard = $cdougan_oracle_db::oraenv_nproc_hard? { 
    undef   => '16384',
    default => $cdougan_oracle_db::oraenv_nproc_hard
  }
  
  $oraenv_nofile_soft = $cdougan_oracle_db::oraenv_nofile_soft? { 
    undef   => '1024',
    default => $cdougan_oracle_db::oraenv_nofile_soft
  }
  
  $oraenv_nofile_hard = $cdougan_oracle_db::oraenv_nofile_hard? { 
    undef   => '65536',
    default => $cdougan_oracle_db::oraenv_nofile_hard
  }
  $oraenv_stack_soft = $cdougan_oracle_db::oraenv_stack_soft? { 
    undef   => '10240',
    default => $cdougan_oracle_db::oraenv_stack_soft
  }
  
  $oraenv_stack_hard = $cdougan_oracle_db::oraenv_stack_hard? { 
    undef   => '10240',
    default => $cdougan_oracle_db::oraenv_stack_hard
  }

}
