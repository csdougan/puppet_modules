class cdougan_was::configure_os::limits ( 
) inherits cdougan_was { 
    class { '::limits':
      config => {
             "${was_user}"  => { 'nofile'  => { soft => '16000'  , hard => '100000',},},
             "root"             => { 'nofile'  => { soft => '16000'  , hard => '100000',},},
             },
      use_hiera => false,
    }
}
