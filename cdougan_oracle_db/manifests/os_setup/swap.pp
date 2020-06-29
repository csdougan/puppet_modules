class cdougan_oracle_db::os_setup::swap () {
  include cdougan_oracle_db::params
  $desired_swap_size = $cdougan_oracle_db::params::desired_swap_size
  custom_resources::set_swapsize{$desired_swap_size: }
}
