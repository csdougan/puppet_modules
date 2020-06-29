custom_resources::user_with_default_pwd {'testuser':
  gid => 'testgroup',
}

custom_resources::rhel_volumegroup{'testvg':
  disks => '"/dev/sdb',
}

  custom_resources::rhel_filesystem {'/testmount':
    volume_group => 'testvg',
    lv_name      => 'testlv',
    owner        => 'root',
    group        => 'root',
    size         => '2G',
  }
