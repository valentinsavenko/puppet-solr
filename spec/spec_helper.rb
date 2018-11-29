require 'rspec-puppet'
require 'puppetlabs_spec_helper/module_spec_helper'

fixture_path = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures')

require 'facter'

module Facter
  def self.version
    ENV['FACTER_VERSION'] || '3.8.0'
  end
end

RSpec.configure do |c|
  c.mock_with :rspec  # See https://github.com/puppetlabs/puppetlabs_spec_helper#mock_with
  c.module_path     = File.join(fixture_path, 'modules')
  c.manifest_dir    = File.join(fixture_path, 'manifests')
  c.manifest        = File.join(fixture_path, 'manifests', 'site.pp')
  c.environmentpath = File.join(Dir.pwd, 'spec')
end
