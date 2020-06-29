define custom_resources::set_swapsize (
) {
    exec {"swapoff logical volume":
      path    => '/usr/sbin:/usr/bin:/bin:/sbin',
      command => "swapoff -a",
      onlyif  => "test $(lvs --units g|grep swap|awk '{print \$NF}'|awk -F. '{print \$1}') -lt ${name}",
      notify  => Exec["extend swap logical volume by ${name}"],
    }
    exec {"extend swap logical volume by ${name}":
      path        => '/usr/sbin:/usr/bin:/bin:/sbin',
      command     => "lvextend -L ${name}G /dev/mapper/$(lvs|grep swap|awk '{print \$2}')-$(lvs|grep swap|awk '{print \$1}')",
      notify      => Exec["mkswap on logical volume"],
      refreshonly => true,
    }
    exec {"mkswap on logical volume":
      path        => '/usr/sbin:/usr/bin:/bin:/sbin',
      command     => "mkswap /dev/mapper/$(lvs|grep swap|awk '{print \$2}')-$(lvs|grep swap|awk '{print \$1}')",
      notify      => Exec["swapon logical volume"],
      refreshonly => true,
    }
    exec {"swapon logical volume":
      path        => '/usr/sbin:/usr/bin:/bin:/sbin',
      command     => "swapon -a",
      refreshonly => true,
    }
}
