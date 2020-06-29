class cdougan_websphere_mdm_pim (
  $pim_server_type          = "core",
  $portal_user              = "director",
  $portal_group             = "mdm-apps",
  $portal_user_password     = "director",
  $was_user                 = "wasadmin",
  $was_group                = "wasadmin",
  $was_flavour              = "ND",
  $jdk_version              = "1.7.1",
  $profile_directory        = undef,
  $was_user_password        = "wasadmin",
  $nexus_url                = "http://abc-watm-artefactrepo.somehost.co.uk:8081/nexus/service/local/repositories",
  $nexus_reponame           = "A0520-WebSphere-Application-Server",
  $install_path             = "/opt/IBM",
  $portal_install_path      = "/opt",
  $portal_mdmdirector_dir    = "mdm-director",
  $portal_supplierportal_dir = "supplierportal",
  $portal_cdouganapps_dir   = "cdougan-apps",
  $portal_spmrestapi_dir     = "spm-rest-api",
  $portal_emailengine_dir    = "email-engine",
  $portal_mdmdirectorlv      = "mdmdirectorlv",
  $portal_supplierportallv   = "supplierportallv",
  $portal_cdouganappslv     = "cdouganappslv",
  $portal_spmrestapilv       = "spmrestapilv",
  $portal_emailenginelv      = "emailenginelv",
  $portal_installationlv     = "installationlv",
  $mdmdirector_lv_size         = "15G",
  $supplierportal_lv_size      = "5G",
  $cdouganapps_lv_size        = "5G",
  $spmrestapi_lv_size          = "5G",
  $emailengine_lv_size         = "5G",
  $portal_installation_lv_size = "5G",
  $was_features             = "core.feature,ejbdeploy,thinclient,embeddablecontainer,com.ibm.sdk.6_64bit",
  $was_dmgr_user            = "wasadmin",
  $was_dmgr_pwd             = "12cdouganpwd",
  $soap_password            = "12cdouganpwd",
  $ibm_filesystem           = "/opt/IBM",
  $profile_fs               = "/opt/IBM/WebSphere/AppServer/profiles",
  $websphere_fs             = "/opt/IBM/WebSphere",
  $mdm_fs                   = "/opt/IBM/MDMCE",
  $dumps_fs                 = "/dumps",
  $ws_vg                    = "datavg",
  $ws_lv                    = "webspherelv",
  $sd_lv                    = "softwarelv",
  $ibm_lv                   = "ibmlv",
  $was_profile_lv           = "profilelv",
  $mdmce_lv                 = "mdmcelv",
  $dumpslv                  = "dumpslv",
  $ibm_lv_size              = "5G",
  $profile_lv_size          = "4G",
  $mdm_lv_size              = "5G",
  $sd_lv_size               = "19G",
  $ws_lv_size               = "5G",
  $dumps_lv_size            = "2G",
  $pv_name                  = "/dev/sdb",
  $software_dir             = "Installation",
  $was_install_version      = "8.5.5.2",
  $was_fixpack_version      = "8.5.5.8",
  $application_layer        = undef,
  $app_layer_number         = undef,
  $was_profile_name         = "MPSL",
  $was_install_dmgr         = true,
  $run_db2_scripts          = true,
  $was_dmgr_hostname        = $::hostname,
  $was_instance_number      = "1",
  $im_version               = "1.8.3",
  $installation_done        = $::install_complete,
  $teardown                 = $::start_teardown,
  $pim_core_rpm_prereqs     = [ 'pam.x86_64',
                                'pam.i686',
                                'compat-libstdc++-33.i686',
                                'compat-libstdc++-33.x86_64',
                                'compat-db47.i686',
                                'compat-db47.x86_64',
                                'libstdc++.x86_64',
                                'libstdc++.i686',
                                'ksh.x86_64',
                                'gtk2.x86_64',
                                'libXmu.i686',
                                'libXp.i686',
                                'libXtst.i686',
                                'libXft.i686',
                                'libXmu.x86_64',
                                'libXp.x86_64',
                                'libXtst.x86_64',
                                'libXft.x86_64',
                                'elfutils.x86_64',
                                'elfutils-libs.x86_64'],
  $pim_portal_rpm_prereqs   = [ 'nodejs.x86_64',
                                'java-1.8.0-oracle.x86_64'],
  $nexus_group_name         = "IBM",
  $mdm_artifact_name        = "MDM-COLL",
  $mdm_version_number       = "11.5",
  $mdm_fixpack_version      = "6",
  $mdm_package_type         = "zip",
  $db2c_artifact_name       = "DB2_Client",
  $db2c_version_number      = "10.5.7",
  $db2c_package_type        = "tgz",
  $db2c_install_location    = "/opt/IBM/db2",
  $mdm_extract_dir          = "mdm115",
  $db2_product              = "RUNTIME_CLIENT",
  $db2_licence              = "ACCEPT",
  $db2_install_type         = "TYPICAL",
  $db2_encryption           = "YES",
  $setup_lvm                = true, 
  $install_db2              = true,
  $install_mdm              = true,
  $db2_database_user        = undef,
  $db2_database_password    = "install1234",
  $db2_database_hostname    = undef,
  $db2_database_port        = 50000,
  $db2_skip_connection_test = false,
  $db2_manual_user_data     = false,
  $db2_schema_name          = "MPSL",
) {  
  $db2_file                 = "${db2c_install_location}/V10.5"
  $db2cli                   = "${db2_file}/bin/db2"
  $mdm_package_url          = "${nexus_url}r=${nexus_reponame}&g=${nexus_group_name}&a=${mdm_artifact_name}&v=${mdm_version_number}&p={mdm_package_type}"
  $db2c_package_url         = "${nexus_url}r=${nexus_reponame}&g=${nexus_group_name}&a=${db2c_artifact_name}&v=${db2c_version_number}&p={db2c_package_type}"

  include ::archive
  $imcl                     = "${ibm_filesystem}/InstallationManager/eclipse/tools/imcl"
  $software_location        = "${install_path}/${software_dir}"
  $was_root_dir             = "${install_path}/WebSphere"
  $was_install_location     = "${was_root_dir}/AppServer"
  $mdm_extract_path         = "${software_location}/${mdm_extract_dir}"
  $ifs                      = split($interfaces,",")
  $primary_interface        = $ifs[0]

    if $operatingsystemmajrelease  == '6' {
        $fs_type                   = 'ext4'
      } else {
        $fs_type                   = 'xfs'
      }
  $websphere_filesystem          = "${ibm_filesystem}/WebSphere"

  case $application_layer {
    'SIT':   { $db2_app_layer = "N" }
    'PRF':   { $db2_app_layer = "P" }
    'PPR':   { $db2_app_layer = "O" }
    'PPD':   { $db2_app_layer = "O" }
    'PSP':   { $db2_app_layer = "F" }
    'PRD':   { $db2_app_layer = "L" }
    'PDR':   { $db2_app_layer = "L" }
    'EDU':   { $db2_app_layer = "E" }
    'DEV':   { $db2_app_layer = "D" }
    'SYST':  { $db2_app_layer = "S" }
    default: { $db2_app_layer = "S" }
  }

  $db2_database_name = "${was_profile_name}${db2_app_layer}${app_layer_number}D"
  $db2_node_name = "${was_profile_name}${db2_app_layer}${app_layer_number}I"

  if $profile_directory {
    $was_profile_dir     = $profile_directory
  } else {
    $was_profile_dir     = "${was_install_location}/profiles"
  }

  $full_was_profile_name = "${application_layer}${app_layer_number}WSPF-${was_profile_name}"
  $profile_path          = "${was_profile_dir}/${full_was_profile_name}"
  $template_path         = "${was_install_location}/profileTemplates/cell/default"
  $server_name           = "${application_layer}${app_layer_number}WSMB-${was_profile_name}"
  $cell_name             = "${application_layer}${app_layer_number}WSCE-${was_profile_name}"
  $node_name             = "${application_layer}${app_layer_number}WSND-${was_profile_name}${was_instance_number}"
  $dmgr_node_name        = "${application_layer}${app_layer_number}WSDM-${was_profile_name}${was_instance_number}"
  $dmgr_was_profile_name = "${application_layer}${app_layer_number}WSDM-${was_profile_name}"
  $dmgr_profile_path     = "${was_profile_dir}/${dmgr_was_profile_name}"
  $dmgr_template_path    = "${was_install_location}/profileTemplates/cell/dmgr"

  $mdmce_root_dir        = "${install_path}/MDMCE"
  $mdmce_bin_dir         = "${mdmce_root_dir}/bin"
  $mdmce_default_dir     = "${mdmce_root_dir}/etc/default"

  if $pim_server_type == "core" {
    include '::cdougan_websphere_mdm_pim::core::install'
  } else {
    include '::cdougan_websphere_mdm_pim::portal::install'
  }
    
}
