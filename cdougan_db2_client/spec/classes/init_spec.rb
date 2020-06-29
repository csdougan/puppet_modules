require 'spec_helper'
describe 'cdougan_db2_client' do

  context 'with defaults for all parameters' do
    it { should contain_class('cdougan_db2_client') }
  end
end
