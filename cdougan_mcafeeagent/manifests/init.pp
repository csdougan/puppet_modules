# Class: cdougan_mcafeeagent
# ===========================
#
# Full description of class cdougan_mcafeeagent here.
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
#    class { 'cdougan_mcafeeagent':
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
# Copyright 2019 Your name here, unless otherwise noted.
#
class cdougan_mcafeeagent (
  $av_version     = '5.5.1-342',
  $nexus_group    = 'RedHat',
  $nexus_repo     = 'Mcafee',
  $nexus_host     = 'abc-watm-artefactrepo.somehost.co.uk',
  $nexus_port     = '8081',
  $nexus_artifact = 'AVclient',
)
{
  $download_file  = "${nexus_artifact}-${av_version}.zip"
  $download_path  = "/root/${download_file}"
  $extract_path   = "/root"
  $download_url   = "http://${nexus_host}:${nexus_port}/nexus/service/local/repositories/${nexus_repo}/content/${nexus_group}/${nexus_artifact}/${av_version}/${download_file}"

  exec {"Remove old packages":
    command => "yum remove -y MFEcma* MFErt*",
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    onlyif  => "rpm -q MFEcma*",
    unless  => "rpm -q MFEcma-${av_version}",
    before  => Archive[$download_file],
  }
 
  archive {$download_file:
    path         => $download_path,
    source       => $download_url,
    extract      => true,
    extract_path => $extract_path,
    creates      => '/opt/McAfee/agent/bin',
    cleanup      => true,
    user         => root,
    group        => root,
  }

  exec {"Install McAfee version ${av_version}":
    command => "bash ${extract_path}/installrpm.sh -i",
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => "rpm -q MFEcma-${av_version}",
    require => Archive[$download_file],
  }

  file {["${extract_path}/installrpm.sh","${extract_path}/install.sh","${extract_path}/installdeb.sh","${download_path}"]:
    ensure  => absent,
    require => Exec["Install McAfee version ${av_version}"],
  }
}
