describe 'my example app' do

  def app
    Sinatra::Application
  end

  let!(:r1) { Race.create(date: Date.today, race_number: 1,
                          start_time: Time.zone.now + 5.minutes,
                          end_time:   Time.zone.now + 10.minutes) }
  let!(:r2) { Race.create(date: Date.today, race_number: 2,
                          start_time: Time.zone.now + 5.minutes,
                          end_time:   Time.zone.now + 10.minutes) }
  let!(:r3) { Race.create(date: Date.today, race_number: 3,
                          start_time: Time.zone.now + 5.minutes,
                          end_time:   Time.zone.now + 10.minutes) }

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

  context 'GET /profile' do

    let!(:u1) { Bettor.create(user_id: '12345') }

    it 'should return the user profile if the user exists' do
      get '/profile', user_id: u1.user_id
      expect(body['user_id']).to_not be_nil
      expect(body['profit'].to_f).to eq(0)
    end


    it 'should return the user profile if the user does not exist' do
      get '/profile', user_id: 'not_here'
      expect(body['user_id']).to_not be_nil
      expect(body['profit'].to_f).to eq(0)
    end

  end


  context 'PUT /profile' do

    let!(:u1)   { Bettor.create(user_id: '12345') }

    context 'win' do

      let!(:bet1) { Bet.create(race: r1, horse: h1, bettor: u1, amount: 1) }

      it 'should return the user profile with profits' do
        Timecop.travel(r1.start_time + 30.minutes) do
          put '/profile', user_id: u1.user_id
          expect(body['user_id']).to eq(u1.user_id)
          expect(body['profit'].to_f).to be > 0
        end
      end

    end

    context 'loss' do

      let!(:bet1) { Bet.create(race: r1, horse: h2, bettor: u1, amount: 1) }

      it 'should return the user profile with no profits' do
        Timecop.travel(r1.start_time + 30.minutes) do
          put '/profile', user_id: u1.user_id
          expect(body['user_id']).to eq(u1.user_id)
          expect(body['profit'].to_f).to be < 0
        end
      end

    end

  end


  context '/races_today' do

    context 'valid' do

      it 'should return all the races' do
        get '/races_today'
        expect(body.size).to eq(3)
      end

    end

    context 'invalid' do

      it 'should return an error if scope is invalid' do
        get '/races_today?scope=bad'
        expect(last_response.status).to eq(400)
        expect(body['error']).to eq('invalid_scope')
      end

    end

  end


  context '/next_race' do

    it 'should return the next race' do
      get '/next_race'
      expect(body['race_number']).to eq(r1.race_number)
    end

  end


  context '/races/:id/horses' do

    context 'valid' do

      it 'should list the odds in a race' do
        get "/races/#{r1.id}/horses"
        expect(body.size).to eq(3)
        expect(body[0]['odds']).to_not be_nil
      end

      it 'should list the finish in a race which is over' do
        Timecop.travel(r1.end_time + 30.minutes) do
          get "/races/#{r1.id}/horses", results: true
          expect(body.size).to eq(3)
          expect(body[0]['odds']).to_not be_nil
        end
      end

    end

    context 'invalid' do

      it 'should not list the finish in a race which is not over' do
        Timecop.travel(r1.end_time - 30.minutes) do
          get "/races/#{r1.id}/horses", results: true
          expect(body['error']).to eq('race_not_over')
        end
      end

    end

  end

  context 'POST /races/:race_id/bets' do

    let!(:u1) { Bettor.create(user_id: '12345') }


    context 'valid' do

      it 'should place a bet' do
        post "/races/#{r1.id}/bets",
          user_id: u1.user_id, horse_id: h1.id, amount: 100

        expect(body['id']).to_not be_nil
      end

    end

    context 'invalid' do

      it 'should not place a bet without a user' do
        post "/races/#{r1.id}/bets",
          user_id: 'another_user', horse_id: h1.id, amount: 100

        expect(body['error']).to eq('not_found')
      end


      it 'should not place a bet without an amount' do
        post "/races/#{r1.id}/bets",
          user_id: u1.user_id, horse_id: h1.id

        expect(body['error']).to eq('invalid_amount')
      end


      it 'should not place a bet without a horse' do
        post "/races/#{r1.id}/bets",
          user_id: u1.user_id, amount: 100

        expect(body['error']).to eq('not_found')
      end

    end

  end


  context 'GET /races/:race_id/bets' do

    let!(:u1)   { Bettor.create(user_id: '12345') }
    let!(:bet1) { Bet.create(race: r1, horse: h1, bettor: u1, amount: 1) }
    let!(:bet2) { Bet.create(race: r1, horse: h2, bettor: u1, amount: 5) }

    context 'valid' do

      it 'should list all user bets' do
        get "/races/#{r1.id}/bets", user_id: u1.user_id

        expect(body.size).to eq(2)
      end

    end

    context 'invalid' do

      it 'should not list user bets without a user' do
        post "/races/#{r1.id}/bets"

        expect(body['error']).to eq('not_found')
      end

    end

  end

end
