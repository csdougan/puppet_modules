class cdougan_oracle_db::os_setup::disable_thp() {
  custom_resources::thp{'never': }
}
