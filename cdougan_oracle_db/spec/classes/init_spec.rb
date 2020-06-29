require 'spec_helper'
describe 'cdougan_oracle_db' do

  context 'with defaults for all parameters' do
    it { should contain_class('cdougan_oracle_db') }
  end
end
