class Bet < ActiveRecord::Base
  belongs_to :race
  belongs_to :horse
  belongs_to :bettor

  scope :settled, -> { joins(:race).where(races: { settled: true }) }
  scope :winning, -> { where('profit > 0') }

  def as_json(*args)
    {
      id:       id,
      race_id:  race_id,
      horse_id: horse_id,
      amount:   amount,
      settled:  race.settled,
    }.as_json(*args)
  end


  def calculate_profit
    rh = \
      RaceHorseJoin.find_by(race_id: race.id, horse_id: horse.id)

    rh.finish == 1 ? amount * rh.odds : 0
  end
end
