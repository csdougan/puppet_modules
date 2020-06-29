class cdougan_oracle_db::os_setup::limits () {
  include cdougan_oracle_db::params
  $environment_name = $cdougan_oracle_db::params::environment_name
  $oraenv_nproc_soft = $cdougan_oracle_db::params::oraenv_nproc_soft
  $oraenv_nproc_hard = $cdougan_oracle_db::params::oraenv_nproc_hard
  $oraenv_nofile_soft = $cdougan_oracle_db::params::oraenv_nofile_soft
  $oraenv_nofile_hard = $cdougan_oracle_db::params::oraenv_nofile_hard
  $oraenv_stack_soft = $cdougan_oracle_db::params::oraenv_stack_soft
  $oraenv_stack_hard = $cdougan_oracle_db::params::oraenv_stack_hard
    class { '::limits':
      config    => {
        "ora${environment_name}" => { 'nofile'  => { soft => $oraenv_nofile_soft  , hard => $oraenv_nofile_hard,  },
                                      'nproc'   => { soft => $oraenv_nproc_soft   , hard => $oraenv_nproc_hard,  },
                                      'memlock' => { soft => '3145728' , hard => '3145728', },
                                      'stack'   => { soft => $oraenv_stack_soft  ,  hard => $oraenv_stack_hard,  },},
        },
      use_hiera => false,
    }
}
