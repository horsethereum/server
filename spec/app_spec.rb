describe 'my example app' do

  def app
    Sinatra::Application
  end

  let!(:r1) { Race.create(date: Date.today, race_number: 1,
                          start_time: Time.now + 5.minutes,
                          end_time:   Time.now + 10.minutes) }
  let!(:r2) { Race.create(date: Date.today, race_number: 2,
                          start_time: Time.now + 5.minutes,
                          end_time:   Time.now + 10.minutes) }
  let!(:r3) { Race.create(date: Date.today, race_number: 3,
                          start_time: Time.now + 5.minutes,
                          end_time:   Time.now + 10.minutes) }

  let!(:h1) { Horse.create(name: 'one') }
  let!(:h2) { Horse.create(name: 'two') }
  let!(:h3) { Horse.create(name: 'three') }


  before do
    [r1,r2,r3].each do |race|
      [h1,h2,h3].each.with_index do |horse, i|
        RaceHorseJoin.create(race:  race,
                             horse: horse,
                             odds: (1..10).to_a.sample,
                             finish: i + 1)
      end
    end
  end

  context '/races_today' do

    it 'should return all the races' do
      get '/races_today'
      expect(body.size).to eq(3)
    end

    it 'should return an error if scope is invalid' do
      get '/races_today?scope=bad'
      expect(last_response.status).to eq(400)
      expect(body['error']).to eq('invalid_scope')
    end

  end


  context '/next_race' do

    it 'should return the next race' do
      get '/next_race'
      expect(body['race_number']).to eq(r1.race_number)
    end

  end


  context '/races/:id/horses' do

    it 'should list the odds in a race' do
      get "/races/#{r1.id}/horses"
      expect(body.size).to eq(3)
      expect(body[0]['odds']).to_not be_nil
    end

  end

end
