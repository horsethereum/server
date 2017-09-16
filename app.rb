require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'

get '/' do
  'Hello world!'
end
