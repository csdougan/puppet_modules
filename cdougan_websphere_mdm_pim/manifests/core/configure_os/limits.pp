class cdougan_websphere_mdm_pim::core::configure_os::limits ( 
) inherits cdougan_websphere_mdm_pim { 
    class { '::limits':
      config => {
             "${was_user}"  => { 'nofile'  => { soft => '16000'  , hard => '100000',},},
             "root"             => { 'nofile'  => { soft => '16000'  , hard => '100000',},},
             },
      use_hiera => false,
    }
}
