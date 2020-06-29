#Header
class cdougan_oracle_db::os_setup::setup_filesystems () {
  include cdougan_oracle_db::params
  $setup_lvm        = $cdougan_oracle_db::params::setup_lvm
  $environment_name = $cdougan_oracle_db::params::environment_name
  $dbname           = $cdougan_oracle_db::params::dbname
  $dbversion        = $cdougan_oracle_db::params::dbversion
  $fs_type          = $cdougan_oracle_db::params::fstype
  $concateddbver    = $cdougan_oracle_db::params::concateddbver
  $ora_disk         = $cdougan_oracle_db::params::ora_disk
  $env_disk         = $cdougan_oracle_db::params::env_disk
  $fra_disk         = $cdougan_oracle_db::params::fra_disk
  $redo_disk        = $cdougan_oracle_db::params::redo_disk

  if $setup_lvm
  {
    custom_resources::rhel_volumegroup {'oravg':
      disks => $ora_disk,
    }
    custom_resources::rhel_volumegroup {"${environment_name}vg":
      disks => $env_disk,
    }
    custom_resources::rhel_volumegroup {'fravg':
      disks => $fra_disk,
    }

    custom_resources::rhel_volumegroup {'redovg':
      disks => $redo_disk,
    }

    file {'/u01':
      ensure => directory,
      owner  => 'oracle',
      group  => 'dba',
      mode   => '0770',
    }

    file {'/u01/app':
      ensure => directory,
      owner  => 'oracle',
      group  => 'dba',
      mode   => '0770',
    }

    custom_resources::rhel_filesystem {'/u01/app/oraInventory':
      volume_group => 'oravg',
      lv_name      => 'orainvlv',
      owner        => 'oracle',
      group        => 'dba',
      mode         => 0770,
      size         => '1G',
      require      => [
        Custom_resources::Rhel_volumegroup['oravg'],
        File['/u01'],
        File['/u01/app']],
    }

    file {'/u01/app/oracle':
      ensure => directory,
      owner  => 'oracle',
      group  => 'dba',
      mode   => '0775',
    }

    custom_resources::rhel_filesystem {'/u01/app/oracle/agent12c':
      volume_group  => 'oravg',
      lv_name       => 'agent12clv',
      owner         => 'oracle',
      group         => 'dba',
      mode          => '0755',
      size          => '5G',
      require       => [
        Custom_resources::Rhel_volumegroup['oravg'],
        File['/u01'],
        File['/u01/app'],
        File['/u01/app/oracle']],
    }

    custom_resources::rhel_filesystem {"/u01/app/ora${environment_name}":
      volume_group => 'oravg',
      lv_name      =>  "ora${environment_name}lv",
      owner        => "ora${environment_name}",
      group        => "${environment_name}grp",
      mode         => '0755',
      size         => '2G',
      require      => [
        Custom_resources::Rhel_volumegroup['oravg'],
        File['/u01'],
        File['/u01/app']],
    }

    file {"/u01/app/ora${environment_name}/admin":
      ensure  => directory,
      owner   => "ora${environment_name}",
      group   => "${environment_name}grp",
      mode    => '0775',
      require => Custom_resources::Rhel_filesystem["/u01/app/ora${environment_name}"],
    }

    custom_resources::rhel_filesystem {"/u01/app/ora${environment_name}/admin/${dbname}${environment_name}":
      volume_group => 'oravg',
      lv_name      => 'adminlv',
      owner        => "ora${environment_name}",
      group        => "${environment_name}grp",
      mode         => '0755',
      size         => '3G',
      require      => [
        Custom_resources::Rhel_filesystem["/u01/app/ora${environment_name}"],
        Custom_resources::Rhel_volumegroup['oravg'],
        File["/u01/app/ora${environment_name}/admin"]],
    }

    file {"/u01/app/ora${environment_name}/product":
      ensure  => directory,
      owner   => "ora${environment_name}",
      group   => "${environment_name}grp",
      mode    => '0775',
      require => Custom_resources::Rhel_filesystem["/u01/app/ora${environment_name}"],
    }

    file {"/u01/app/ora${environment_name}/product/${dbversion}":
      ensure => directory,
      owner  => "ora${environment_name}",
      group  => "${environment_name}grp",
      mode   => '0775',
      require => File["/u01/app/ora${environment_name}/product"],
    }

    custom_resources::rhel_filesystem {"/u01/app/ora${environment_name}/product/${dbversion}/db":
      volume_group  => 'oravg',
      lv_name       =>  "${concateddbver}dblv",
      owner         => "ora${environment_name}",
      group         => "${environment_name}grp",
      mode          => '0755',
      size          => '15G',
      require       => [
        Custom_resources::Rhel_filesystem["/u01/app/ora${environment_name}"],
        Custom_resources::Rhel_volumegroup['oravg'],
        File["/u01/app/ora${environment_name}/product"],
        File["/u01/app/ora${environment_name}/product/${dbversion}"]],
    }

    file {"/u01/app/ora${environment_name}/diag":
      ensure  => directory,
      owner   => "ora${environment_name}",
      group   => "${environment_name}grp",
      mode    => '0775',
      require => Custom_resources::Rhel_filesystem["/u01/app/ora${environment_name}"],
    }

    file {"/u01/app/ora${environment_name}/diag/rdbms":
      ensure  => directory,
      owner   => "ora${environment_name}",
      group   => "${environment_name}grp",
      mode    => '0775',
      require => File["/u01/app/ora${environment_name}/diag"],
    }

    file {"/u01/app/ora${environment_name}/diag/rdbms/${dbname}${environment_name}":
      ensure  => directory,
      owner   => "ora${environment_name}",
      group   => "${environment_name}grp",
      mode    => '0775',
      require => File["/u01/app/ora${environment_name}/diag/rdbms"],
    }

    file {"/u01/app/ora${environment_name}/diag/rdbms/${dbname}${environment_name}/${dbname}${environment_name}":
      ensure  => directory,
      owner   => "ora${environment_name}",
      group   => "${environment_name}grp",
      mode    => '0775',
      require => File["/u01/app/ora${environment_name}/diag/rdbms/${dbname}${environment_name}"],
    }

    custom_resources::rhel_filesystem {"/u01/app/ora${environment_name}/diag/rdbms/${dbname}${environment_name}/${dbname}${environment_name}/trace":
      volume_group => 'oravg',
      lv_name      => 'tracelv',
      owner        => "ora${environment_name}",
      group        => "${environment_name}grp",
      mode         => '0755',
      size         => '2G',
      require      => [
        Custom_resources::Rhel_filesystem["/u01/app/ora${environment_name}"],
        Custom_resources::Rhel_volumegroup['oravg'],
        File["/u01/app/ora${environment_name}/diag/rdbms/${dbname}${environment_name}/${dbname}${environment_name}"]],
    }

    custom_resources::rhel_filesystem {"/u01/app/ora${environment_name}/diag/rdbms/${dbname}${environment_name}/${dbname}${environment_name}/cdump":
      volume_group  => 'oravg',
      lv_name       => 'cdumplv',
      owner         => "ora${environment_name}",
      group         => "${environment_name}grp",
      mode          => '0755',
      size          => '2G',
      require       => [
        Custom_resources::Rhel_filesystem["/u01/app/ora${environment_name}"],
        Custom_resources::Rhel_volumegroup['oravg'],
        File["/u01/app/ora${environment_name}/diag/rdbms/${dbname}${environment_name}/${dbname}${environment_name}"]],
    }

    file {'/u01/oradata':
      ensure => directory,
      owner  => "ora${environment_name}",
      group  => "${environment_name}grp",
      mode   => '0755',
    }

    file {"/u01/oradata/${dbname}${environment_name}":
      ensure  => directory,
      owner   => "ora${environment_name}",
      group   => "${environment_name}grp",
      mode    => '0755',
      require => File['/u01/oradata'],
    }

    custom_resources::rhel_filesystem {"/u01/oradata/${dbname}${environment_name}/fra":
      volume_group => 'fravg',
      lv_name      => 'fralv',
      owner        => "ora${environment_name}",
      group        => "${environment_name}grp",
      mode         => '0755',
      size         => '100%VG',
      require      => [
        Custom_resources::Rhel_volumegroup['fravg'],
        File["/u01/oradata/${dbname}${environment_name}"]],
    }

    custom_resources::rhel_filesystem {"/u01/oradata/${dbname}${environment_name}/data":
      volume_group  => "${environment_name}vg",
      lv_name       => 'datalv',
      owner         => "ora${environment_name}",
      group         => "${environment_name}grp",
      mode          => '0755',
      size          => '100%VG',
      require       => [
        Custom_resources::Rhel_volumegroup["${environment_name}vg"],
        File["/u01/oradata/${dbname}${environment_name}"]],
    }

    custom_resources::rhel_filesystem {"/u01/oradata/${dbname}${environment_name}/redoa":
      volume_group => 'redovg',
      lv_name      => 'redoalv',
      owner        => "ora${environment_name}",
      group        => "${environment_name}grp",
      mode         => '0755',
      size         => '50%VG',
      require      => [
        Custom_resources::Rhel_volumegroup['redovg'],
        File["/u01/oradata/${dbname}${environment_name}"]],
    }

    custom_resources::rhel_filesystem {"/u01/oradata/${dbname}${environment_name}/redob":
      volume_group  => 'redovg',
      lv_name       => 'redoblv',
      owner         => "ora${environment_name}",
      group         => "${environment_name}grp",
      mode          => '0755',
      size          => '50%VG',
      require       => [
        Custom_resources::Rhel_volumegroup['redovg'],
        File["/u01/oradata/${dbname}${environment_name}"]],
    }
  }
}
