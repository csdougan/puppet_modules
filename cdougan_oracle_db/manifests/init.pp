#Header
class cdougan_oracle_db (
  $setup_lvm          = undef,
  $dbname             = undef,
  $environment_number = undef,
  $dbversion          = undef,
  $environment_layer  = undef,
  $ora_vg_name        = undef,
  $env_vg_name        = undef,
  $fra_vg_name        = undef,
  $redo_vg_name       = undef,
  $ora_disk           = undef,
  $env_disk           = undef,
  $fra_disk           = undef,
  $redo_disk          = undef,
  $opatch_version     = undef,
  $ddboost_password   = undef,
  $nexus_repo         = undef,
  $nexus_url          = undef,
  $oraenv_nproc_soft = undef,
  $oraenv_nproc_hard = undef,
  $oraenv_nofile_soft = undef,
  $oraenv_nofile_hard = undef,
  $oraenv_stack_soft = undef,
  $oraenv_stack_hard = undef,
) {
  Class['cdougan_oracle_db::os_setup::swap']
  -> Class['cdougan_oracle_db::os_setup::setup_users_groups']
  -> Class['cdougan_oracle_db::os_setup::remount_tmp']
  -> Class['cdougan_oracle_db::os_setup::set_sysctl']
  -> Class['cdougan_oracle_db::os_setup::pamd']
  -> Class['cdougan_oracle_db::os_setup::limits']
  -> Class['cdougan_oracle_db::os_setup::x11']
  -> Class['cdougan_oracle_db::os_setup::disable_thp']
  -> Class['cdougan_oracle_db::os_setup::set_sudo_config']
  -> Class['cdougan_oracle_db::os_setup::ora_inst_tab']
  -> Class['cdougan_oracle_db::os_setup::initd']
  -> Class['cdougan_oracle_db::os_setup::setup_filesystems']
  -> Class['cdougan_oracle_db::os_setup::install_prereqs']
  -> Class['cdougan_oracle_db::os_setup::deploy_scripts']
  -> Class['cdougan_oracle_db::db_install::get_packages']
  -> Class['cdougan_oracle_db::db_install::install']
  -> Class['cdougan_oracle_db::db_install::opatch']
  -> Class['cdougan_oracle_db::os_setup::ddboost']

  contain(
    'cdougan_oracle_db::os_setup::swap',
    'cdougan_oracle_db::os_setup::setup_users_groups',
    'cdougan_oracle_db::os_setup::remount_tmp',
    'cdougan_oracle_db::os_setup::set_sysctl',
    'cdougan_oracle_db::os_setup::pamd',
    'cdougan_oracle_db::os_setup::limits',
    'cdougan_oracle_db::os_setup::x11',
    'cdougan_oracle_db::os_setup::disable_thp',
    'cdougan_oracle_db::os_setup::set_sudo_config',
    'cdougan_oracle_db::os_setup::ora_inst_tab',
    'cdougan_oracle_db::os_setup::initd',
    'cdougan_oracle_db::os_setup::setup_filesystems',
    'cdougan_oracle_db::os_setup::install_prereqs',
    'cdougan_oracle_db::os_setup::deploy_scripts',
    'cdougan_oracle_db::db_install::get_packages',
    'cdougan_oracle_db::db_install::install',
    'cdougan_oracle_db::db_install::opatch',
    'cdougan_oracle_db::os_setup::ddboost')
}
