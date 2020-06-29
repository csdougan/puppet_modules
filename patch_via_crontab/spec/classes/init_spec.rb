require 'spec_helper'
describe 'patch_via_crontab' do

  context 'with defaults for all parameters' do
    it { should contain_class('patch_via_crontab') }
  end
end
