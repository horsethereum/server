# Init

Install rbenv and Ruby 2.4
```
brew install rbenv ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
rbenv install 2.4.0
```

Install Postgres
```
brew install postgres
brew services start postgresql
```

Install gems
```
rbenv shell 2.4.0
gem install bundler
bundle install
```

Init DB
```
bundle exec rake db:create db:migrate db:import
```

Run Tests
```
RACK_ENV=test bundle exec rake db:drop db:create db:migrate
bundle exec rspec
```

Start local web server
```
bundle exec rackup
```

Start port forwarding
```
brew cask install ngrok
ngrok http 9292
```

Re-Init DB (on schema change)
```
bundle exec rake db:drop db:create db:migrate db:import
```

