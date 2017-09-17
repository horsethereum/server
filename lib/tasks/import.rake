namespace :db do

  task :import => :load_config do

    require 'csv'
    path = File.dirname(File.expand_path(__FILE__))
    rows = CSV.read("#{path}/../../db/seeds.csv")

    _names = rows.shift

    races_horses = rows.map do |row|
      {
        id:          "#{Date.parse(row[1]).strftime("%Y%m%d")}_#{row[0].to_i}",
        date:        Date.parse(row[1]),
        race_number: row[0].to_i,
        start_time:  Time.parse(row[15]),
        end_time:    Time.parse(row[16]),
        name:        row[7],
        odds:        Float(row[6]),
        finish:      row[5].to_i
      }
    end


    ActiveRecord::Base.transaction do

      races_horses.group_by { |o| o[:id] }.each do |race, horses|
        data = horses[0]
        p data

        date = data[:date]
        race_number = data[:race_number]

        race = Race.create!(date: date,
                            race_number: race_number,
                            start_time: data[:start_time],
                            end_time: data[:end_time])

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
