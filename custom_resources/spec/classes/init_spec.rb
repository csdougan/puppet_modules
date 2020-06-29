require 'spec_helper'
describe 'custom_resources' do

  context 'with defaults for all parameters' do
    it { should contain_class('custom_resources') }
  end
end
