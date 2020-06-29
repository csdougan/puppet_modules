require 'spec_helper'
describe 'cdougan_ansible_playbook' do
  context 'with default values for all parameters' do
    it { should contain_class('cdougan_ansible_playbook') }
  end
end
