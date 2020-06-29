class cdougan_users_groups {
  	$user_accounts = hiera_hash('users', undef)
  	if $user_accounts != undef {
    		create_resources(cdougan_users_groups::manage_users, $user_accounts)
  	}
	
	$groups = hiera_hash('usergroups', undef)
        if $groups != undef {
                create_resources(cdougan_users_groups::manage_usergroups, $groups)
        }

}
