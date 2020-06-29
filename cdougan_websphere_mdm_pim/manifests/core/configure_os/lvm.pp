class cdougan_websphere_mdm_pim::core::configure_os::lvm() inherits cdougan_websphere_mdm_pim {
  if $setup_lvm {
			include ::lvm

		custom_resources::rhel_volumegroup {$ws_vg:
					disks => $pv_name,
		}

		custom_resources::rhel_filesystem {$dumps_fs:
			volume_group => $ws_vg,
			lv_name      => $dumpslv,
			owner        => $was_user,
			group        => $was_group,
			fstype       => $fs_type,
			size         => $dumps_lv_size,
			require      => Custom_resources::Rhel_volumegroup[$ws_vg],
		}

		custom_resources::rhel_filesystem {$ibm_filesystem:
			volume_group => $ws_vg,
			lv_name      => $ibm_lv,
			owner        => $was_user,
			group        => $was_group,
			fstype       => $fs_type,
			size         => $ibm_lv_size,
			require      => Custom_resources::Rhel_volumegroup[$ws_vg],
		}

		custom_resources::rhel_filesystem {"${ibm_filesystem}/MDMCE":
			volume_group => $ws_vg,
			lv_name      => $mdmce_lv,
			owner        => $was_user,
			group        => $was_group,
			fstype       => $fs_type,
			size         => $mdm_lv_size,
			require      => [Custom_resources::Rhel_volumegroup[$ws_vg],
			                 Custom_resources::Rhel_filesystem[$ibm_filesystem]],
		}

		custom_resources::rhel_filesystem {"${ibm_filesystem}/WebSphere":
			volume_group => $ws_vg,
			lv_name      => $ws_lv,
			owner        => $was_user,
			group        => $was_group,
			fstype       => $fs_type,
			size         => $ws_lv_size,
			require      => [Custom_resources::Rhel_volumegroup[$ws_vg],
			                 Custom_resources::Rhel_filesystem[$ibm_filesystem]],
		}

		custom_resources::rhel_filesystem {"${ibm_filesystem}/${software_dir}":
			volume_group => $ws_vg,
			lv_name      => $sd_lv,
			owner        => $was_user,
			group        => $was_group,
			fstype       => $fs_type,
			size         => $sd_lv_size,
			require      => [Custom_resources::Rhel_volumegroup[$ws_vg],
			                 Custom_resources::Rhel_filesystem[$ibm_filesystem]],
		}

		file {"${ibm_filesystem}/WebSphere/AppServer":
			ensure                       => directory,
			owner                        => $was_user, 
			group                        => $was_group,
			require                      => Custom_resources::Rhel_filesystem["${ibm_filesystem}/WebSphere"],
		} 

		custom_resources::rhel_filesystem {$profile_fs:
			volume_group => $ws_vg,
			lv_name      => $was_profile_lv,
			owner        => $was_user,
			group        => $was_group,
			fstype       => $fs_type,
			size         => $profile_lv_size,
			require      => [Custom_resources::Rhel_volumegroup[$ws_vg],
                       File["${ibm_filesystem}/WebSphere/AppServer"]],
		}

		file {"${ibm_filesystem}/InstallationManager":
			ensure                       => directory,
			owner                        => root, 
			group                        => root,
			require                      => Custom_resources::Rhel_filesystem[$ibm_filesystem],
		 }
		
#  file {"${ibm_filesystem}/IMShared":
#    ensure                       => directory,
#    owner                        => root, 
#    group                        => root,
#    require                      => Mount[$ibm_filesystem],
#  }

		file {"$ibm_filesystem/$software_dir/logs":
			ensure                       => directory,
			owner                        => "${was_user}",
			group                        => "${was_group}",
#   recurse                      => true,
			require                      => Custom_resources::Rhel_filesystem["$ibm_filesystem/${software_dir}"],
		}
	}
}
