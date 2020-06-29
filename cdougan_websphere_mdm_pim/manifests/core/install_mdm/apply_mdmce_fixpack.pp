class cdougan_websphere_mdm_pim::core::install_mdm::apply_mdmce_fixpack (
) inherits cdougan_websphere_mdm_pim {

  exec {"Confirm MDMCE Fixpack is installed":
    onlyif          => "grep '${mdm_version_number}.0.${mdm_fixpack_version}' ${mdmce_root_dir}/README.TXT",
    command         => "echo 'MDMCE Fixpack is installed' > ${software_location}/logs/Fixpack_is_installed.log",
    creates         => "${software_location}/logs/Fixpack_is_installed.log",
    path            => "/bin:/sbin:/usr/bin:/usr/sbin",
    before          =>  Archive["${software_location}/${mdm_artifact_name}-${mdm_version_number}.${mdm_fixpack_version}.zip"],
  }

  archive {"${software_location}/${mdm_artifact_name}-${mdm_version_number}.${mdm_fixpack_version}.zip":
    source          => "${nexus_url}/${nexus_reponame}/content/${nexus_group_name}/${mdm_artifact_name}/${mdm_version_number}.${mdm_fixpack_version}/${mdm_artifact_name}-${mdm_version_number}.${mdm_fixpack_version}.zip",
    extract         => true,
    extract_path    => $mdmce_root_dir,
    creates         => "${software_location}/logs/Fixpack_is_installed.log",
    cleanup         => true,
    user            => $was_user,
    group           => $was_group,
    notify          => Exec["Set up MDMCE FixPack"],
    require         => File[$mdm_extract_path],
  }
  
  exec {"Set up MDMCE FixPack":
    path            => "/bin:/sbin:/usr/bin:/usr/sbin",
    command         => "bash -c 'source ${install_path}/pim_profile; cd ${mdmce_root_dir} && ./setup.sh --overwrite' > ${software_location}/logs/setup_mdm_fixpack.log",
    creates         => "${software_location}/logs/setup_mdm_fixpack.log",
    user            => $was_user,
    refreshonly     => true,
    require         => Archive["${software_location}/${mdm_artifact_name}-${mdm_version_number}.${mdm_fixpack_version}.zip"],
    notify          => Exec["Configure MDMCE Fixpack Env"],
    timeout         => 1800,
  }

  exec {"Configure MDMCE Fixpack Env":
    path            => "/bin:/sbin:/usr/bin:/usr/sbin",
    command         => "bash -c 'source ${install_path}/pim_profile; ${mdmce_root_dir}/bin/configureEnv.sh --overwrite' > ${software_location}/logs/configure_env_for_mdm_fixpack.log",
    creates         => "${software_location}/logs/configure_env_for_mdm_fixpack.log",
    user            => $was_user,
    refreshonly     => true,
    notify          => Exec["Install MDMCE Fixpack WAR"],
    require         => Exec["Set up MDMCE FixPack"],
    timeout         => 1800,
  }

  exec {"Install MDMCE Fixpack WAR":
    path            => "/bin:/sbin:/usr/bin:/usr/sbin",
    command         => "bash -c 'source ${install_path}/pim_profile; cd ${mdmce_root_dir}/bin/websphere && ./install_war.sh --silent --security --wsadminUsername ${was_dmgr_user} --wsadminPwd ${was_dmgr_pwd}' > ${software_location}/logs/install_war_mdm_fixpack.log",
    creates         => "${software_location}/logs/install_war_mdm_fixpack.log",
    user            => $was_user,
    refreshonly     => true,
    require         => Exec["Configure MDMCE Fixpack Env"],
    notify          => Exec["Migrate MDMCE to Fixpack"],
    timeout         => 1800,
  }

  file {"${mdmce_root_dir}/bin/migration/migrateToInstalledFP.sh":
    owner           => root,
    group           => root,
    mode            => 0755,
    require         => Exec["Install MDMCE Fixpack WAR"],
    source          => "puppet:///modules/cdougan_websphere_mdm_pim/migrateToInstalledFP.sh",
  }

  exec {"Migrate MDMCE to Fixpack":
    path            => "/bin:/sbin:/usr/bin:/usr/sbin",
    command         => "bash -c 'source ${install_path}/pim_profile; cd ${mdmce_root_dir}/bin/migration && ./migrateToInstalledFP.sh --fromversion=BASE --dbpassword=${db2_database_password} --silent' > ${software_location}/logs/migrate_mdm_fixpack.log",
    creates         => "${software_location}/logs/migrate_mdm_fixpack.log",
    user            => $was_user,
    refreshonly     => true,
    require         => [Exec["Configure MDMCE Fixpack Env"],
                        File["${mdmce_root_dir}/bin/migration/migrateToInstalledFP.sh"]],
    timeout         => 1800,
  }

}

