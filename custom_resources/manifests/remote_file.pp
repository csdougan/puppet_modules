define custom_resources::remote_file(
        $uri = undef,
        $timeout = 300,
        $owner = $id,
        $group = $gid,
        $mode = 0644,
        $ensure = present,
	$path = $name,

        ) {
exec {"download $uri":
	path	=> ['/bin','/sbin','/usr/bin','/usr/sbin'],
	onlyif	=> "test \$(/usr/bin/wget --spider ${uri} 2>&1 | /bin/grep ^Length|/bin/awk '{print \$2}') != \$(/usr/bin/stat ${path}| /bin/grep 'Size:' | /bin/awk '{print \$2}')",
        command => "/usr/bin/wget -O $path ${uri}", 
        require => File["$name"],
        timeout => $timeout,
}

file {"${name}":
	path	=> $path,
        ensure  => $ensure,
        owner   => "$owner",
        group   => "$group",
        mode    => "$mode",
	replace	=> false,
        notify 	=> Exec["download $uri"],
}

}

