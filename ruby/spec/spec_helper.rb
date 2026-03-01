# frozen_string_literal: true

require 'webmock/rspec'
require 'whatsrb_cloud'
require_relative 'support/fake_server'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random

  config.before do
    WhatsrbCloud.reset_configuration!
  end
end
