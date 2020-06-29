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
define cdougan_ansible_playbook::run(
  $playbook         = undef,
  $inventory        = undef,
  $url              = undef,
  $connection       = 'local',
  $host             = 'localhost,',
  $ansible_user     = 'ans1pga1service',
  $verbose_level    = 0,
  $logfile          = undef,
  $checkout_dir     = undef,
  $check_mode       = false,
  $ansible_group    = 'ansible',
  $destination      = undef,
  $extra_vars       = undef,
  $branch           = undef,
)
{
    if $destination == undef {
      $rs = split($url, '/')
      $rs2 = split($rs[-1], '\.')
      $destdir = $rs2[0]
    } else {
      $destdir = $destination
    }

    if $playbook != undef {
      if $url != undef {
        case $verbose_level {
          1: {      $verbose_flag=' -v' }
          2:       { $verbose_flag=' -vv' }
          3:       { $verbose_flag=' -vvv' }
          4:       { $verbose_flag=' -vvvv' }
          default: { $verbose_flag=' ' }
        }
        if $logfile != undef {
          $logfile_flag=" > ${logfile} 2> ${logfile}"
        } else {
          $logfile_flag=" > /tmp/ansible_run_${destdir}.txt 2> /tmp/ansible_run_${destdir}.txt"
        }
        if $inventory != undef {
          $inventory_flag="-i ${inventory}"
        } else {
          $inventory_flag="-i ${host},"
        }
        if $checkout_dir != undef {
          $checkout_flag = " --directory ${checkout_dir}"
        } else {
          $checkout_flag = " --directory /home/${ansible_user}/ansible"
        }
        if $check_mode == true {
          $check_flag = ' --check'
        } else {
          $check_flag = ' '
        }
        if $extra_vars != undef {
          $vars_flag = " -e '${extra_vars}'"
        } else {
          $vars_flag = ' '
        }

        exec{"Clone git repo ${url}":
         user     => $ansible_user,
         path     => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
         command  => "eval $(ssh-agent -s); ssh-add; git clone ${url} /home/${ansible_user}/${destdir}",
         creates  => "/home/${ansible_user}/${destdir}/.git",
         cwd     => "/home/${ansible_user}",
         provider => 'shell',
         before   => Exec["Updating git repo ${url}"],
        }
        
        exec{"Updating git repo ${url}":
         user     => $ansible_user,
         command  => 'eval $(ssh-agent -s); ssh-add;  git fetch && git pull',
         path     => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
         cwd     => "/home/${ansible_user}/${destdir}",
         provider => 'shell',
         require  => Exec["Clone git repo ${url}"],
        }
         
        if $branch != undef {
          exec{"git checkout ${branch}":
           user     => $ansible_user,
           command  => "git checkout ${branch}",
           path     => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
           cwd     => "/home/${ansible_user}/${destdir}",
           require  => Exec["Updating git repo ${url}"],
           before   => Exec["Run playbook ${playbook} from svn repo ${url}"],
          }
        }

        exec{"Run playbook ${playbook} from svn repo ${url}":
          user    => $ansible_user,
          path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
          command => "ansible-playbook ${inventory_flag}${verbose_flag}${check_flag} --connection ${connection}${vars_flag} ${playbook} ${logfile_flag} > /tmp/ansible_${destdir}_play.log",
          cwd     => "/home/${ansible_user}/${destdir}",
          provider => 'shell',
          timeout => '600',
          require => [
            Package['ansible','git2u'],
            File["/home/${ansible_user}/.ssh/id_rsa.pub","/home/${ansible_user}/.ssh/known_hosts","/home/${ansible_user}/.ssh/id_rsa"],
            Exec["Updating git repo ${url}"],
          ],
        }
      }
    }
}
