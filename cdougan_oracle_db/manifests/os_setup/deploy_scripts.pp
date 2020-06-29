class cdougan_oracle_db::os_setup::deploy_scripts ()
{
  include cdougan_oracle_db::params
  archive {'Oracle Scripts Package':
    path         => '/home/oracle/Oracle_Scripts_LINUX.tar',
    source       => 'http://abc-watm-artefactrepo.somehost.co.uk:8081/nexus/service/local/repositories/A0528-OracleDB-Release/content/linux/scripts/oracle/scripts-oracle.tar',
    extract      => true,
    extract_path => '/home/oracle',
    creates      => '/home/oracle/scripts',
    cleanup      => true,
    user         => 'oracle',
    group        => 'dba',
    notify       => Exec['set perms on Oracle Scripts package'],
  }

  exec {'set perms on Oracle Scripts package':
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    command     => 'chmod 770 /home/oracle; chmod 770 /home/oracle/sql; chmod -R 660 /home/oracle/sql/*; chmod -R 770 /home/oracle/scripts; chown -R oracle:dba /home/oracle/scripts; chown -R oracle:dba /home/oracle/sql',
    refreshonly => true,
    require     => Archive['Oracle Scripts Package'],
  }

  file {"/home/oracle/root.sh":
    ensure => present,
    mode   => '0770',
    owner  => 'oracle',
    group  => 'dba',
  }
}
