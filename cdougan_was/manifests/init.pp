class cdougan_was (
  $was_user            = 'wasuser',
  $install_ifit        = false,
  $was_group           = 'was',
  $admin_user          = 'wasadmin',
  $admin_pass          = 'abc123',
  $ws_lv_size          = '3G',
  $sd_lv_size          = '20G',
  $im_lv_size          = '5G',
  $dumps_lv_size       = '4G',
  $logs_lv_size        = '4G',
  $profile_lv_size     = '10G',
  $dumps_lv            = "wasdumpslv",
  $logs_lv             = "waslogslv",
  $profile_lv          = "wasprofilelv",
  $was_flavour         = 'BASE',
  $jdk_version         = "1.8",
  $was_user_password   = hiera('was_password',"abc123"),
  $nexus_url           = hiera('nexus_url'),
  $nexus_reponame      = hiera('was_nexus_repo'),
  $install_path        = hiera('was_install_path'),
  $was_features        = hiera('was_features'),
  $was_dmgr_user       = hiera('was_dmgr_username'),
  $was_dmgr_pwd        = hiera('was_dmgr_password'),
  $soap_password       = hiera('was_dmgr_password'),
  $im_filesystem       = hiera('was_install_manager_filesystem'),
  $ws_vg               = hiera('was_volume_group'),
  $ws_lv               = hiera('was_logical_volume'),
  $sd_lv               = hiera('was_software_logical_volume'),
  $im_lv               = hiera('was_install_manager_logical_volume'),
  $pv_name             = hiera('was_physical_disk'),
  $software_dir        = hiera('was_software_dir'),
  $was_fixpack_version = '8.5.5.12',
  $was_ifit_version    = 10863,
  $environment_layer   = hiera('environment_layer'),
  $environment_number    = hiera('environment_number'),
  $was_profile_name    = hiera('was_profile_name'),
  $was_install_dmgr    = hiera('was_dmgr_install'),
  $was_dmgr_hostname   = hiera('was_dmgr_hostname'),
  $was_instance_number = hiera('was_instance_number'),
  $server_names        = "default",
  $use_adminagent      = true,
  $im_version          = hiera('was_install_manager_version'),
  $app_http_port       = "9080",
  $app_https_port      = "9443",
  $admin_http_port     = "9060",
  $admin_https_port    = "9043",
  $bootstrap_port      = "2809",
  $soap_port           = "8880",
  $ipc_port            = "9633",
  $sas_ssl_port        = "9401",
  $csiv2_server_port   = "9403",
  $csiv2_mutual_port   = "9402",
  $orb_port            = "9100",
  $dcs_port            = "9353",
  $sib_port            = "7276",
  $sib_secure_port     = "7286",
  $sib_mq_port         = "5558",
  $sib_mq_secure_port  = "5578",
  $sip_default_port    = "5060",
  $sip_default_secure  = "5061",
  $overlay_udp_port    = "11003",
  $overlay_tcp_port    = "11004",
  $dumps_location      = "/dumps",

  $nexus_group_name      = "IBM",
  $setup_lvm             = true,
  $use_instance_number_in_app_and_server_names = true,

) {  
   if $operatingsystemmajrelease == '6' {
     $compat_db_rpms = ['compat-db', 'compat-db.i686']
   } else {
     $compat_db_rpms = ['compat-db47', 'compat-db47.i686']
   }
  $other_rpms     = ['pam.x86_64',
                             'compat-libstdc++-33.i686',
                             'compat-libstdc++-33.x86_64',
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
                             'elfutils-libs.x86_64']
  $was_rpm_prereqs = split(inline_template("<%= (compat_db_rpms+other_rpms).join(',') %>"),',')
  include ::archive
  $imcl                = "${im_filesystem}/InstallationManager/eclipse/tools/imcl"
  $software_location   = "${install_path}/${software_dir}"
  $was_root_dir        = "${install_path}/WebSphere"
  $was_install_location = "${was_root_dir}/AppServer"
  $profile_directory   = "${was_root_dir}/profiles"
  $log_directory        = "${was_root_dir}/logs"
  $ifs                   = split($interfaces,",")
  $primary_interface     = $ifs[0]

  if $profile_directory {
    $was_profile_dir = $profile_directory
  } else {
    $was_profile_dir = "${was_install_location}/profiles"
  }
  #$full_was_profile_name = "${environment_layer}${environment_number}WSPF-${was_profile_name}${was_app_name}"
  #$profile_path          = "${was_profile_dir}/${full_was_profile_name}"
  if $was_flavour == "ND" {
    $was_install_version = '8.5.5.2'
    $template_path       = "${was_install_location}/profileTemplates/cell/default"
  } else {
    $was_install_version = '8.5.5.0'
    $template_path       = "${was_install_location}/profileTemplates/default"
    $admin_template_path = "${was_install_location}/profileTemplates/management"
  }
  #$server_name           = "${environment_layer}${environment_number}WSMB-${was_profile_name}${was_app_name}${was_instance_number}"
  $cell_name             = "${environment_layer}${environment_number}WSCE-${was_profile_name}"
  $node_name             = "${environment_layer}${environment_number}WSND-${was_profile_name}${was_instance_number}"
  $dmgr_node_name        = "${environment_layer}${environment_number}WSDM-${was_profile_name}${was_instance_number}"
  $dmgr_was_profile_name = "${environment_layer}${environment_number}WSDM-${was_profile_name}"
  $dmgr_profile_path     = "${was_profile_dir}/${dmgr_was_profile_name}"
  $dmgr_template_path    = "${was_install_location}/profileTemplates/cell/dmgr"


  $was_version_array   = split($was_fixpack_version, '[.]')

  if size($was_version_array) > 2 {
    $was_product_name = "com.ibm.websphere.${was_flavour}.v${was_version_array[0]}${was_version_array[1]}"
  } else {
    $was_product_name = "com.ibm.websphere.${was_flavour}.v${was_version_array[0]}"
  }
  $minor_ver_length=inline_template("<%= @was_version_array[3].length %>")
  case $minor_ver_length {
    0: { $padding="000"}
    1: { $padding="00" }
    2: { $padding="0" }
    default: { $padding="" }
  }
  $detailed_was_version="${was_version_array[0]}.${was_version_array[1]}.${was_version_array[2]}${padding}${was_version_array[3]}"

  $jdk_version_array = split($jdk_version, '[.]')
  if size($jdk_version_array) > 2 {
    $jdk_product_name = "com.ibm.websphere.IBMJAVA.v${jdk_version_array[1]}${jdk_version_array[2]}"
  } else {
    $jdk_product_name = "com.ibm.websphere.IBMJAVA.v${jdk_version_array[1]}0"
  }

  include cdougan_was::end_to_end_install
}
