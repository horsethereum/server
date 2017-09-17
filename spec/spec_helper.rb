ENV['RACK_ENV'] = 'test'
require_relative '../app'
require_relative './test_helpers'

require 'rspec'
require 'rack/test'
require 'pry'
require 'timecop'
require 'database_cleaner'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include TestHelpers

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
