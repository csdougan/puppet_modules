class cdougan_db2_client::ad_user_config () {
  $db2_client_users = hiera_hash('db2_client_users', undef)
  if $db2_client_users != undef {
    create_resources(cdougan_users_groups::manage_users, $db2_client_users)
  }
}
