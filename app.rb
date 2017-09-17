require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'


get '/races_today' do
  Race.where(date: Date.today)
end


get '/next_race' do
end


get '/races/#id/horses' do
end


get '/races/#id/odds' do
end


post '/races/#id/bets' do
end
