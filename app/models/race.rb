class Race < ActiveRecord::Base
  has_many :race_horse_join

  has_many :horses, through: :race_horse_join
  has_many :bets
end
