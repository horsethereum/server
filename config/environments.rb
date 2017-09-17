configure :development do
 require 'sinatra/reloader'
 set :show_exceptions, true
end

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::INFO
Time.zone = 'Pacific Time (US & Canada)'

require_relative '../app/models/init'
