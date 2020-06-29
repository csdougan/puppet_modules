define cdougan_users_groups::manage_usergroups (
	$ensure = present,
	$system = false,
	$gid = undef,
	) {
	group { $title:
		ensure	=> $ensure,
		system	=> $system,
		gid	=> $gid,
	}
}
