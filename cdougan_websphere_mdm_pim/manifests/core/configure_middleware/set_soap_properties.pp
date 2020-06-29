class cdougan_websphere_mdm_pim::core::configure_middleware::set_soap_properties () inherits cdougan_websphere_mdm_pim 
{
  if $cdougan_websphere_mdm_pim::was_flavour == "ND" {
    exec {'set SOAP securityEnabled for DM Profile properties':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/properties/soap.client.props",
      unless => "grep com.ibm.SOAP.securityEnabled=true ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/properties/soap.client.props",
    }
    exec {'set SOAP securityEnabled for DM Profile temp':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/temp/soap.client.props",
      onlyif => "test -e ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/temp/soap.client.props",
      unless => "grep com.ibm.SOAP.securityEnabled=true ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/temp/soap.client.props",
    }
    exec {'set SOAP securityEnabled for Node Profile properties':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/properties/soap.client.props",
      unless => "grep com.ibm.SOAP.securityEnabled=true ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/properties/soap.client.props",
    }
    exec {'set SOAP securityEnabled for Node Profile temp':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/temp/soap.client.props",
      onlyif => "test -e  ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/temp/soap.client.props",
      unless => "grep com.ibm.SOAP.securityEnabled=true ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/temp/soap.client.props",
    }

    exec {'set SOAP loginUser for DM Profile properties':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      onlyif => "test -e ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/properties/soap.client.props",
      command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${cdougan_websphere_mdm_pim::was_user}/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/properties/soap.client.props",
      unless => "grep com.ibm.SOAP.loginUserid=${cdougan_websphere_mdm_pim::was_user} ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/properties/soap.client.props",
    }
    exec {'set SOAP loginUser for DM Profile temp':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      onlyif => "test -e ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/temp/soap.client.props",
      command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${cdougan_websphere_mdm_pim::was_user}/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/temp/soap.client.props",
      unless => "grep com.ibm.SOAP.loginUserid=${cdougan_websphere_mdm_pim::was_user} ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/temp/soap.client.props",
    }
    exec {'set SOAP loginUser for Node Profile properties':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${cdougan_websphere_mdm_pim::was_user}/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/properties/soap.client.props",
      onlyif => "test -e ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/properties/soap.client.props",
      unless => "grep com.ibm.SOAP.loginUserid=${cdougan_websphere_mdm_pim::was_user} ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/properties/soap.client.props",
    }
    exec {'set SOAP loginUser for Node Profile temp':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      onlyif => "test -e  ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/temp/soap.client.props",
      command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${cdougan_websphere_mdm_pim::was_user}/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/temp/soap.client.props",
      unless => "grep com.ibm.SOAP.loginUserid=${cdougan_websphere_mdm_pim::was_user} ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/temp/soap.client.props",
    }

    exec {'set SOAP loginPassword for DM Profile properties':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      onlyif => "test -e ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/properties/soap.client.props",
      command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${cdougan_websphere_mdm_pim::soap_password}/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/properties/soap.client.props",
      unless => "grep com.ibm.SOAP.loginPassword=${cdougan_websphere_mdm_pim::soap_password} ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/properties/soap.client.props",
    }
    exec {'set SOAP loginPassword for DM Profile temp':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      onlyif => "test -e ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/temp/soap.client.props",
      command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${cdougan_websphere_mdm_pim::soap_password}/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/temp/soap.client.props",
      unless => "grep com.ibm.SOAP.loginPassword=${cdougan_websphere_mdm_pim::soap_password} ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::dmgr_was_profile_name}/temp/soap.client.props",
    }
    exec {'set SOAP loginPassword for Node Profile properties':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      onlyif => "${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/properties/soap.client.props",
      command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${cdougan_websphere_mdm_pim::soap_password}/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/properties/soap.client.props",
      unless => "grep com.ibm.SOAP.loginPassword=${cdougan_websphere_mdm_pim::soap_password} ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/properties/soap.client.props",
    }
    exec {'set SOAP loginPassword for Node Profile temp':
      path => "/bin:/usr/bin:/sbin:/usr/sbin",
      onlyif => "${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/temp/soap.client.props",
      command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${cdougan_websphere_mdm_pim::soap_password}/g' ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/temp/soap.client.props",
      unless => "grep com.ibm.SOAP.loginPassword=${cdougan_websphere_mdm_pim::soap_password} ${cdougan_websphere_mdm_pim::was_profile_dir}/${cdougan_websphere_mdm_pim::full_was_profile_name}/temp/soap.client.props",
    }
  }
}
