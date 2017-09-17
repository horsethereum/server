ENV['RACK_ENV'] = 'test'
require_relative '../app'
require_relative './test_helpers'

require 'rspec'
require 'rack/test'
require 'pry'
require 'database_cleaner'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include TestHelpers

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
