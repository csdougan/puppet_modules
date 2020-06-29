custom_resources::user_with_default_pwd {'craig':
  gid => 'test',
}

  custom_resources::rhel_filesystem {'/u01/app/oracle/something/somethingelse':
    volume_group  => 'rhel',
    lv_name       => 'testlv',
    owner         => 'craig',
    group         => 'test',
    size          => '2G',
    mode          => 0777,
    recurse_perms => true,
    recurse_depth => 4,
  }
