require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv/load'
require './config/environments'
require './lib/error'
require 'pry'


before do
  Time.zone = 'Pacific Time (US & Canada)'
  content_type :json
end


def respond(response)
  case response
  when Error
    halt(response.status, response.to_json)
  else response.to_json
  end
end


get '/profile' do
  user_id = params[:user_id]

  unless user_id
    return respond Error.new(error: 'not_valid')
  end

  user = Bettor.find_or_create_by(user_id: user_id)

  respond user
end


put '/profile' do
  user_id = params[:user_id]

  unless user_id
    return respond Error.new(error: 'not_valid')
  end

  Race.update_all! # update race balances

  user = Bettor.find_or_create_by(user_id: user_id)

  respond user
end


get '/races' do
  scope = (params[:scope] || :all).to_sym

  races =\
    case scope
    when :all
      Race.all
    when :future
      Race.where('start_time > ?', Time.zone.now)
    when :past
      Race.where('start_time < ?', Time.zone.now)
    else
      Error.new(error: 'invalid_scope')
    end

  respond races.order('start_time asc')
end


get '/races_today' do
  scope = (params[:scope] || :all).to_sym

  races = \
    case scope
    when :all
      Race.where(date: Date.today)
    when :future
      Race.where('date = ? and start_time > ?', Date.today, Time.zone.now)
    when :past
      Race.where('date = ? and start_time < ?', Date.today, Time.zone.now)
    else
      respond Error.new(error: 'invalid_scope')
      return
    end

  respond races.order('start_time asc')
end


get '/next_race' do
  races = Race.where('start_time > ?', Time.zone.now)

  respond races.order('start_time asc').first
end


get '/races/:race_id/horses' do
  race_id = params[:race_id].to_i
  results = params[:results] ? true : false

  race = Race.find_by(id: race_id)

  unless race
    return respond Error.new(error: 'not_found')
  end

  if results && !race.over?
    return respond Error.new(error: 'race_not_over')
  end

  races_horses = RaceHorseJoin.includes(:horse)
                              .where(race_id: race_id)
                              .order('id asc')

  horses = \
    races_horses.map do |race_horse|
      race_horse.horse.as_json.tap do |json|
        json[:odds]   = race_horse.odds
        json[:finish] = race_horse.finish if results
      end
    end

  respond horses
end


get '/races/:race_id/bets' do
  race_id  = params[:race_id].to_i
  user_id  = params[:user_id]
  scope    = (params[:scope] || :all).to_sym

  race   = Race.find_by(id: race_id)
  bettor = Bettor.find_by(user_id: user_id)

  unless race && bettor
    return respond Error.new(error: 'not_found')
  end

  bets =\
    case scope
    when :all
      Bet.where(race: race, bettor: bettor)
         .order('created_at asc')
    when :settled
      Bet.settled.where(race: race, bettor: bettor)
         .order('created_at asc')
    when :winning
      Bet.settled.winning
         .where(race: race, bettor: bettor)
         .order('created_at asc')
    end

  results =\
    bets.map do |bet|
      bet.horse.as_json.tap do |json|
        json['amount'] = bet.amount
      end
    end

  respond results
end


post '/races/:race_id/bets' do
  race_id  = params[:race_id].to_i
  horse_id = params[:horse_id].to_i
  user_id  = params[:user_id]
  amount   = params[:amount].to_f

  race   = Race.find_by(id: race_id)
  horse  = Horse.find_by(id: horse_id)
  bettor = Bettor.find_by(user_id: user_id)

  unless race && horse && bettor
    return respond Error.new(error: 'not_found')
  end

  unless amount > 0
    return respond Error.new(error: 'invalid_amount')
  end

  bet = Bet.new(race: race, horse: horse, bettor: bettor, amount: amount)
  respond bet.save ? bet : Error.new(bet)
end
