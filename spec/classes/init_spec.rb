require 'spec_helper'

describe 'solr' do
  let(:version) { '7.1.0' }


  # it do
  #   is_expected.to contain_file('/opt/solr-7.1.0.tgz')
  #   # .with({
  #   #   'ensure' => 'present',
  #   #   'owner'  => 'root',
  #   #   'group'  => 'root',
  #   #   'mode'   => '0444',
  #   # })
  # end
  
  it { is_expected.to contain_class('Solr') }
  # context 'with compress => true' do
  #   let(:params) { {'compress' => true} }

  #   it do
  #     is_expected.to contain_file('/etc/logrotate.d/nginx') \
  #       .with_content(/^\s*compress$/)
  #   end
  # end

  # context 'with compress => false' do
  #   let(:params) { {'compress' => false} }

  #   it do
  #     is_expected.to contain_file('/etc/logrotate.d/nginx') \
  #       .with_content(/^\s*nocompress$/)
  #   end
  # end

  # context 'with compress => foo' do
  #   let(:params) { {'compress' => 'foo'} }

  #   it do
  #     expect {
  #       is_expected.to contain_file('/etc/logrotate.d/nginx')
  #     }.to raise_error(Puppet::Error, /compress must be true or false/)
  #   end
  # end
end
