require 'spec_helper'

describe 'solr' do
  context 'user, group created and Class, config' do
    let :params do
      {
        version: '7.0.0',
        install_dir: '/tmp',
        service_name: 'solr_special_service_name',
        user: 'solr_special_user_name',
        group: 'solr_special_group_name',
      }
    end

    it { is_expected.to contain_user('solr_special_user_name') }
    it { is_expected.to contain_group('solr_special_group_name') }

    it { is_expected.to contain_class('Solr') }
  end

  context 'unmanaged user and group untouched' do
    let :params do
      {
        user: 'solr_special_user_name',
        group: 'solr_special_group_name',
        manage_user: false,
        manage_group: false,
      }
    end

    it { is_expected.not_to contain_user('solr_special_user_name') }
    it { is_expected.not_to contain_group('solr_special_group_name') }
  end
end
