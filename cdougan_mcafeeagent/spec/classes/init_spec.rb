require 'spec_helper'
describe 'cdougan_mcafeeagent' do
  context 'with default values for all parameters' do
    it { should contain_class('cdougan_mcafeeagent') }
  end
end
