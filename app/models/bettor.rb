class Bettor < ActiveRecord::Base
  has_many :bets

  def profit
    Bet.settled.where(bettor_id: id).sum(:profit)
  end


  def as_json(*args)
    { id: id, user_id: user_id, profit: profit }.as_json(*args)
  end

end
