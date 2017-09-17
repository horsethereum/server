class RaceHorseJoin < ActiveRecord::Base
  self.table_name = 'races_horses'

  belongs_to :race
  belongs_to :horse
end
