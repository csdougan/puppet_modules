class cdougan_was::configure_middleware::set_soap_properties () inherits cdougan_was {
if $was_flavour == "ND" {
   
   exec {'set SOAP securityEnabled for DM Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${was_profile_dir}/${dmgr_was_profile_name}/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.securityEnabled=true ${was_profile_dir}/${dmgr_was_profile_name}/properties/soap.client.props",
  }
   exec {'set SOAP securityEnabled for DM Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${was_profile_dir}/${dmgr_was_profile_name}/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.securityEnabled=true ${was_profile_dir}/${dmgr_was_profile_name}/temp/soap.client.props",
  }
   exec {'set SOAP securityEnabled for Node Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.securityEnabled=true ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
  }
   exec {'set SOAP securityEnabled for Node Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.securityEnabled=true ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
  }


   exec {'set SOAP loginUser for DM Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${was_user}/g' ${was_profile_dir}/${dmgr_was_profile_name}/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.loginUserid=${was_user} ${was_profile_dir}/${dmgr_was_profile_name}/properties/soap.client.props",
  }
   exec {'set SOAP loginUser for DM Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${was_user}/g' ${was_profile_dir}/${dmgr_was_profile_name}/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.loginUserid=${was_user} ${was_profile_dir}/${dmgr_was_profile_name}/temp/soap.client.props",
  }
   exec {'set SOAP loginUser for Node Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${was_user}/g' ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.loginUserid=${was_user} ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
  }
   exec {'set SOAP loginUser for Node Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${was_user}/g' ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.loginUserid=${was_user} ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
  }


   exec {'set SOAP loginPassword for DM Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${soap_password}/g' ${was_profile_dir}/${dmgr_was_profile_name}/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.loginPassword=${soap_password} ${was_profile_dir}/${dmgr_was_profile_name}/properties/soap.client.props",
  }
   exec {'set SOAP loginPassword for DM Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${soap_password}/g' ${was_profile_dir}/${dmgr_was_profile_name}/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.loginPassword=${soap_password} ${was_profile_dir}/${dmgr_was_profile_name}/temp/soap.client.props",
  }
   exec {'set SOAP loginPassword for Node Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${soap_password}/g' ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.loginPassword=${soap_password} ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
  }
   exec {'set SOAP loginPassword for Node Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${soap_password}/g' ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.loginPassword=${soap_password} ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
  }
} else {
   
   exec {'set SOAP securityEnabled for Admin Agent Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${was_profile_dir}/adminagent/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.securityEnabled=true ${was_profile_dir}/adminagent/properties/soap.client.props",
  }
   exec {'set SOAP securityEnabled for Admin Agent Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${was_profile_dir}/adminagent/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.securityEnabled=true ${was_profile_dir}/adminagent/temp/soap.client.props",
  }
   exec {'set SOAP securityEnabled for Node Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.securityEnabled=true ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
  }
   exec {'set SOAP securityEnabled for Node Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.securityEnabled=.*/com.ibm.SOAP.securityEnabled=true/g' ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.securityEnabled=true ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
  }


   exec {'set SOAP loginUser for Admin Agent Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${was_user}/g' ${was_profile_dir}/adminagent/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.loginUserid=${admin_user} ${was_profile_dir}/adminagent/properties/soap.client.props",
  }
   exec {'set SOAP loginUser for Admin Agent Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${was_user}/g' ${was_profile_dir}/adminagent/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.loginUserid=${admin_user} ${was_profile_dir}/adminagent/temp/soap.client.props",
  }
   exec {'set SOAP loginUser for Node Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${was_user}/g' ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.loginUserid=${admin_user} ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
  }
   exec {'set SOAP loginUser for Node Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginUserid.*/com.ibm.SOAP.loginUserid=${was_user}/g' ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.loginUserid=${admin_user} ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
  }


   exec {'set SOAP loginPassword for Admin Agent Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${soap_password}/g' ${was_profile_dir}/adminagent/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.loginPassword=${admin_pass} ${was_profile_dir}/adminagent/properties/soap.client.props",
  }
   exec {'set SOAP loginPassword for Admin Agent Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${soap_password}/g' ${was_profile_dir}/adminagent/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.loginPassword=${admin_pass} ${was_profile_dir}/adminagent/temp/soap.client.props",
  }
   exec {'set SOAP loginPassword for Node Profile properties':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${soap_password}/g' ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
     unless => "grep com.ibm.SOAP.loginPassword=${admin_pass} ${was_profile_dir}/${full_was_profile_name}/properties/soap.client.props",
  }
   exec {'set SOAP loginPassword for Node Profile temp':
     path => "/bin:/usr/bin:/sbin:/usr/sbin",
     command => "sed -i 's/com.ibm.SOAP.loginPassword.*/com.ibm.SOAP.loginPassword=${soap_password}/g' ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
     unless => "grep com.ibm.SOAP.loginPassword=${admin_pass} ${was_profile_dir}/${full_was_profile_name}/temp/soap.client.props",
  }
}
}
