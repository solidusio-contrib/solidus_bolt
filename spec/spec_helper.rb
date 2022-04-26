# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

# Run Coverage report
require 'solidus_dev_support/rspec/coverage'
require 'pry'
require 'vcr'
require 'webmock/rspec'

# Create the dummy app if it's still missing.
dummy_env = "#{__dir__}/dummy/config/environment.rb"
system 'bin/rake extension:test_app' unless File.exist? dummy_env
require dummy_env

# Requires factories and other useful helpers defined in spree_core.
require 'solidus_dev_support/rspec/feature_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require f }

# Requires factories defined in lib/solidus_bolt/testing_support/factories.rb
SolidusDevSupport::TestingSupport::Factories.load_for(SolidusBolt::Engine)

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  if Spree.solidus_gem_version < Gem::Version.new('2.11')
    config.extend Spree::TestingSupport::AuthorizationHelpers::Request, type: :system
  end
end

# Configure VCR
VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data('<API_KEY>') do |interaction|
    interaction.request.headers['X-API-KEY']&.first
  end

  config.filter_sensitive_data('<PUBLISHABLE_KEY>') do |interaction|
    interaction.request.headers['X-Publishable-Key']&.first
  end

  # Let's you set default VCR record mode with VCR_RECORDE_MODE=all for re-recording
  # episodes. :once is VCR default
  record_mode = ENV.fetch('VCR_RECORD_MODE', :once).to_sym
  config.default_cassette_options = { record: record_mode }
end
