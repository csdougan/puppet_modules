# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
class {"cdougan_oracle_db":
  ora_disk           => '/dev/sdc1',
  env_disk           => '/dev/sdc2',
  fra_disk           => '/dev/sdc3',
  redo_disk          => '/dev/sdc4',
  dbname             => 'TEST',
  environment_number => '1',
  dbversion          => '12.2.0.1',
  environment_layer  => 'SIT',
}


