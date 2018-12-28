# frozen_string_literal: true

require 'bundler/setup'
require 'toolbox'
require 'faraday'
require 'faraday_middleware'
require 'faker'
require 'bunny'
require './spec/support/event_consuming_helper'
require './spec/support/protected_routes_helper'

RSpec.configure do |config|
  TOOLBOX_HOST = ENV.fetch('TOOLBOX_HOST', 'http://www.microkube.com')
  EVENT_API_JWT_PRIVATE_KEY = ENV.fetch('EVENT_API_JWT_PRIVATE_KEY', '')
  EVENT_API_JWT_ALGORITHM = ENV.fetch('EVENT_API_JWT_ALGORITHM', 'RS256')
  EVENT_API_RABBITMQ_HOST = ENV.fetch(
    'EVENT_API_RABBITMQ_HOST',
    'rabbitmq.microkube.com'
  )
  EVENT_API_RABBITMQ_PORT = ENV.fetch('EVENT_API_RABBITMQ_PORT', '5672')
  EVENT_API_RABBITMQ_USERNAME = ENV.fetch(
    'EVENT_API_RABBITMQ_USERNAME',
    'guest'
  )
  EVENT_API_RABBITMQ_PASSWORD = ENV.fetch(
    'EVENT_API_RABBITMQ_PASSWORD',
    'guest'
  )
  EMAIL = Faker::Internet.email
  PASSWORD = Faker::Internet.password(10, 20, true)

  RSpec.configure do |c|
    c.include EventConsumingHelper
  end
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
