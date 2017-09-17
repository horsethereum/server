class Horse < ActiveRecord::Base
  has_many :race_horse_join

  has_many :races, through: :race_horse_join
  has_many :bets
end
