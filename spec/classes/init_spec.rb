require 'spec_helper'

describe 'solr' do
  let(:version) { '7.1.0' }

  it { is_expected.to contain_class('Solr') }
end
