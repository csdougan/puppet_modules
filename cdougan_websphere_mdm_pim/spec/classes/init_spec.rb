require 'spec_helper'
describe 'cdougan_websphere_mdm_pim' do

  context 'with defaults for all parameters' do
    it { should contain_class('cdougan_websphere_mdm_pim') }
  end
end
