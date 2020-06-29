class cdougan_websphere_mdm_pim::portal::configure_os::lvm () inherits cdougan_websphere_mdm_pim {
	if $setup_lvm {
		include ::lvm
		custom_resources::rhel_volumegroup {$ws_vg:
			disks => $pv_name,
		}
		custom_resources::rhel_filesystem {"${portal_install_path}/${portal_mdmdirector_dir}":
			volume_group => $ws_vg,
			lv_name      => $portal_mdmdirectorlv,
			owner        => $portal_user,
			group        => $portal_group,
			fstype       => $fs_type,
			size         => $mdmdirector_lv_size,
			require      => Custom_resources::Rhel_volumegroup[$ws_vg],
		}

		custom_resources::rhel_filesystem {"${portal_install_path}/${portal_supplierportal_dir}":
			volume_group => $ws_vg,
			lv_name      => $portal_supplierportallv,
			owner        => $portal_user,
			group        => $portal_group,
			fstype       => $fs_type,
			size         => $supplierportal_lv_size,
			require      => Custom_resources::Rhel_volumegroup[$ws_vg],
		}
		custom_resources::rhel_filesystem {"${portal_install_path}/${portal_cdouganapps_dir}":
			volume_group => $ws_vg,
			lv_name      => $portal_cdouganappslv,
			owner        => $portal_user,
			group        => $portal_group,
			fstype       => $fs_type,
			size         => $cdouganapps_lv_size,
			require      => Custom_resources::Rhel_volumegroup[$ws_vg],
		}

		custom_resources::rhel_filesystem {"${portal_install_path}/${portal_spmrestapi_dir}":
			volume_group => $ws_vg,
			lv_name      => $portal_spmrestapilv,
			owner        => $portal_user,
			group        => $portal_group,
			fstype       => $fs_type,
			size         => $spmrestapi_lv_size,
			require      => Custom_resources::Rhel_volumegroup[$ws_vg],
		}

		custom_resources::rhel_filesystem {"${portal_install_path}/${portal_emailengine_dir}":
			volume_group => $ws_vg,
			lv_name      => $portal_emailenginelv,
			owner        => $portal_user,
			group        => $portal_group,
			fstype       => $fs_type,
			size         => $emailengine_lv_size,
			require      => Custom_resources::Rhel_volumegroup[$ws_vg],
		}

		custom_resources::rhel_filesystem {"${portal_install_path}/${software_dir}":
			volume_group => $ws_vg,
		  lv_name      => $portal_installationlv,
		  owner        => $portal_user,
		  group        => $portal_group,
		  fstype       => $fs_type,
		  size         => $portal_installation_lv_size,
		  require      => Custom_resources::Rhel_volumegroup[$ws_vg],
		}

    custom_resources::rhel_filesystem {$ibm_filesystem:
      volume_group => $ws_vg,
      lv_name      => $ibm_lv,
      owner        => $portal_user,
      group        => $portal_group,
      fstype       => $fs_type,
      size         => '1G',
      require      => Custom_resources::Rhel_volumegroup[$ws_vg],
    }


    custom_resources::rhel_filesystem {"${ibm_filesystem}/${software_dir}":
      volume_group => $ws_vg,
      lv_name      => $sd_lv,
      owner        => $portal_user,
      group        => $portal_group,
      fstype       => $fs_type,
      size         => '1G',
      require      => [Custom_resources::Rhel_volumegroup[$ws_vg],
                       Custom_resources::Rhel_filesystem[$ibm_filesystem]],
    }
  }
}
