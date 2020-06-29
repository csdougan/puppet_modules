# Class: cdougan_enable_ad_passwords
#
# This module manages cdougan_enable_ad_passwords
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class cdougan_enable_ad_passwords (
  $default_realm = "NET.MYDOMAIN.CO.UK",
){
    package {'pam_krb5':
      ensure  => present,
    }
    
    file {'/etc/krb5.conf':
      ensure  => present,
      content => template('cdougan_enable_ad_passwords/krb5.conf.erb'),
      owner   => root,
      group   => root,
      mode    => 0644,
    }
    
   file {'/etc/pam.d/abc-system-auth':
     ensure   => present,
     source   => "puppet:///modules/cdougan_enable_ad_passwords/abc-system-auth",
     owner   => root,
     group   => root,
     mode    => 0644,
   }
   
   file {'/etc/pam.d/abc-password-auth':
     ensure   => present,
     source   => "puppet:///modules/cdougan_enable_ad_passwords/abc-password-auth",
     owner   => root,
     group   => root,
     mode    => 0644
   }
   
   file {'/etc/pam.d/system-auth':
     ensure   => link,
     target   => "/etc/pam.d/abc-system-auth",
     require  => File['/etc/pam.d/abc-system-auth'],
   }
   
   file {'/etc/pam.d/password-auth':
     ensure   => link,
     target   => "/etc/pam.d/abc-password-auth",
     require  => File['/etc/pam.d/abc-password-auth'],
   }
}
