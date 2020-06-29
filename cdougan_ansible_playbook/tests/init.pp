class{'cdougan_ansible_playbook':
  playbook         =>  'print_out_vars.yml',
  url              => "ssh://git@abc-wscm-sourcerepo.somehost.co.uk:7999/aap/filesystem_checker.git",
  extra_vars       => 'testvar=yourmum testvar2=somethingelse',
}
