require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'

before do
  content_type :json
end

class Error
  attr_reader :status, :error, :message

  def initialize(obj = {})
      case obj
      when Hash
        @status  = obj[:status]  || 400
        @error   = obj[:error]   || 'error'
        @message = obj[:message] || 'error'
      when String
        @status  = 400
        @error   = 'error'
        @message = obj
      when ActiveModel::Validations
        @status  = 400,
        @error   = 'validation_error'
        @message = obj.errors.messages.to_a.map(&:flatten).map { |l| l.join(' ') }.join(', ')
      else
        raise TypeError, "#{obj.class} not supported"
      end
  end

  def to_json
    { status: @status, error: @error, message: @message }.to_json
  end
end


def respond(response)
  case response
  when Error
    halt(response.status, response.to_json)
  else response.to_json
  end
end


get '/races' do
  scope = (params[:scope] || :all).to_sym

  races =\
    case scope
    when :all
      Race.all
    when :future
      Race.where('start_time > ?', Time.now)
    when :past
      Race.where('start_time < ?', Time.now)
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
      Race.where('date = ? and start_time > ?', Date.today, Time.now)
    when :past
      Race.where('date = ? and start_time < ?', Date.today, Time.now)
    else
      respond Error.new(error: 'invalid_scope')
      return
    end

  respond races.order('start_time asc')
end


get '/next_race' do
  races = Race.where('start_time > ?', Time.now)

  respond races.order('start_time asc').first
end


get '/races/:id/horses' do
  race_id = params[:id]

  races_horses = RaceHorseJoin.includes(:horse)
                              .where(race_id: race_id)
                              .order('id asc')

  horses = \
    races_horses.map do |race_horse|
      horse = race_horse.horse.as_json
      horse[:odds] = race_horse.odds
      horse
    end

  respond horses
end


post '/races/:id/bets' do
  bets = Race.find(race_id).bets

  respond bets.order('created_at asc').to_json
end
