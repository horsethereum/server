namespace :db do

  task :import => :load_config do

    require 'csv'
    require 'pry'

    path = File.dirname(File.expand_path(__FILE__))
    rows = CSV.read("#{path}/../../db/seeds.csv")

    _names = rows.shift

    races_horses = rows.map do |row|
      {
        id:          "#{Time.zone.parse(row[1]).strftime("%Y%m%d")}_#{row[0].to_i}",
        date:        Time.zone.parse(row[1]).to_date,
        race_number: row[0].to_i,
        start_time:  Time.zone.parse(row[15]),
        end_time:    Time.zone.parse(row[16]),
        name:        row[7],
        odds:        Float(row[6]),
        finish:      row[5].to_i
      }
    end


    ActiveRecord::Base.transaction do

      start_date = races_horses.map { |rh| rh[:date] }.uniq.sort.first

      races_horses.group_by { |o| o[:id] }.each do |race, horses|
        data = horses[0]

        date  = data[:date]
        today = Time.zone.today + 1.day
        race_number = data[:race_number]

        race = Race.create!(date: today + (date - start_date),
                            race_number: race_number,
                            start_time:  data[:start_time] + (today - date).days,
                            end_time:    data[:end_time] + (today - date).days)

        p race.inspect

        horses.each do |d|
          horse = Horse.find_or_create_by(name: d[:name])

          RaceHorseJoin.create!(race:   race,
                                horse:  horse,
                                odds:   d[:odds],
                                finish: d[:finish])
        end
      end

    end

  end
end
