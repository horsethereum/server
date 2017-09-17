# Rakefile
require 'sinatra/activerecord/rake'

Rake.add_rakelib 'lib/tasks'

namespace :db do
  task :load_config do
    require './app'
  end
end

task :console do
  sh 'pry -r ./app.rb'
end
