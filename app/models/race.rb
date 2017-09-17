class Race < ActiveRecord::Base
  has_many :race_horse_join

  has_many :horses, through: :race_horse_join
  has_many :bets

  scope :settled,     -> { where(settled: true)  }
  scope :not_settled, -> { where(settled: false) }


  def self.update_all!
    Race.not_settled.where('end_time < ?', Time.zone.now).each do |race|
      race.transaction do
        race.bets.each do |bet|
          bet.update(profit: bet.calculate_profit)
        end
        race.update(settled: true)
      end
    end
  end


  def over?
    end_time < Time.zone.now
  end

end
