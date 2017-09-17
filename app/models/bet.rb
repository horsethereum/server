class Bet < ActiveRecord::Base
  belongs_to :race
  belongs_to :horse
  belongs_to :bettor
end
