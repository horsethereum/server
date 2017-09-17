# Init

Install Ruby 2.4
```
brew install rbenv ruby-build postgresql
brew services start postgresql
rbenv install 2.4.0
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
