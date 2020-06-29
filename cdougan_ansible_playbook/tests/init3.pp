class{'cdougan_ansible_playbook':}

cdougan_ansible_playbook::run{"Install DB2":
    playbook   => 'db2.yml',
    url        => 'ssh://git@abc-wscm-sourcerepo.somehost.co.uk:7999/aap/ansible-db2.git',
    extra_vars => '{"envid":"x","schemaid":"l","envnum":"1","default_user_pwd":"install1234","newdisk":"false"}',
    require    => Class['cdougan_ansible_playbook'],
    branch     => "development",
    inventory  => "local_inventory",
}
