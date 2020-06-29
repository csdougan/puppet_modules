class cdougan_nginx ( $nginx_version  = "18" ) {
	package {"rh-nginx${nginx_version}":
                ensure          => present,
        }
        
	file {"/etc/profile.d/nginx${nginx_version}":
                ensure          => link,
                target          => "/opt/rh/rh-nginx${nginx_version}/enable",
                require         => Package["rh-nginx${nginx_version}"],
        }

        file {"/etc/nginx":
                ensure          => link,
                target          => "/etc/opt/rh/rh-nginx${nginx_version}/nginx",
                require         => Package["rh-nginx${nginx_version}"],
        }

	file {"/etc/init.d/nginx":
		ensure		=> link,
		target		=> "/etc/init.d/rh-nginx${nginx_version}-nginx",
		require		=> Package["rh-nginx${nginx_version}"],
	}

        service {"rh-nginx${nginx_version}-nginx":
                ensure          => running,
                enable          => true,
                require         => [File["/etc/nginx"],File["/etc/profile.d/nginx${nginx_version}"]],
        }
}
