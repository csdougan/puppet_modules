# Creates volume groups, and sets up any PVs that are required
# for it.  For Docker, this process is skipped as it doesnt work
# in a container
define custom_resources::rhel_volumegroup (
  $disks = undef
) {
  if ! $::dockerenv {
    physical_volume { $disks:
      ensure    => present,
      unless_vg => $title,
    }
    volume_group { $title:
      ensure           => present,
      physical_volumes => $disks,
      require          => Physical_volume[$disks],
      createonly       => true,
    }
  }
}

