# Class: cdougan_ansible_playbook
# ===========================
#
# Full description of class cdougan_ansible_playbook here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'cdougan_ansible_playbook':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2018 Your name here, unless otherwise noted.
#
class cdougan_ansible_playbook(
  $ansible_user     = 'ans1pga1service',
  $ansible_group    = 'ansible',
)
{
    group{$ansible_group:
      ensure           => present,
    }

    user{$ansible_user:
      ensure           => present,
      expiry           => absent,
      password         => undef,
      purge_ssh_keys   => true,
      password_max_age => -1,
      comment          => 'Account for Running Ansible pulls locally via Puppet',
      system           => false,
      managehome       => true,
      shell            => '/bin/bash',
      home             => "/home/${ansible_user}",
      gid              => $ansible_group,
      require          => Group[$ansible_group],
    }

    file{'/etc/sudoers.d/ansible':
      ensure           => present,
      content          => "%${ansible_group}      ALL=(ALL) NOPASSWD: ALL",
      owner            => 'root',
      group            => 'root',
      mode             => '0644',
    }

    file{"/home/${ansible_user}/.ssh":
      ensure  => directory,
      owner   => $ansible_user,
      group   => $ansible_group,
      mode    => '0700',
      require => User[$ansible_user],
    }

    file{"/home/${ansible_user}/.ssh/id_rsa":
      ensure  => present,
      owner   => $ansible_user,
      source  => 'puppet:///modules/cdougan_ansible_playbook/id_rsa',
      group   => $ansible_group,
      mode    => '0600',
      require => User[$ansible_user],
    }

    file{"/home/${ansible_user}/.ssh/id_rsa.pub":
      ensure  => present,
      owner   => $ansible_user,
      source  => 'puppet:///modules/cdougan_ansible_playbook/id_rsa.pub',
      group   => $ansible_group,
      mode    => '0644',
      require => User[$ansible_user],
    }

    file{"/home/${ansible_user}/.ssh/known_hosts":
      ensure  => present,
      owner   => $ansible_user,
      source  => 'puppet:///modules/cdougan_ansible_playbook/id_rsa.pub',
      group   => $ansible_group,
      mode    => '0644',
      require => User[$ansible_user],
    }

    file{"/home/${ansible_user}/.ssh/config":
      ensure  => present,
      owner   => $ansible_user,
      source  => 'puppet:///modules/cdougan_ansible_playbook/config',
      group   => $ansible_group,
      mode    => '0644',
      require => User[$ansible_user],
    }
    exec{'yum remove -y git perl-Git':
      path   => '/bin:/sbin:/usr/bin:/usr/sbin',
      unless => 'rpm -qa | grep git2u',
      before => Package['git2u','ansible'],
    }
    package{['git2u','ansible']:
      ensure  => present,
    }
}
