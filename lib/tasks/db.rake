namespace :db do
  desc "Seed the location data."
  task :seed_location do
    config = Rails.configuration.database_configuration[Rails.env]
    #system(
    #  'psql', '-U', config['username'],
    #  # FIXME: assuming no password
    #  '-f', 'db/seed/naki-locations.sql',
    #  config['database']
    #)
    system('bundle exec rails db -p < db/seed/naki-locations.sql')
  end

  desc "Drop, recreate and seed database."
  task :reseed => [:environment, 'db:create', 'db:schema:load', 'db:seed_location', 'db:seed']

  desc "Force seed (for tests)"
  task :force_seed do
    require File.expand_path('./config/environment.rb')
    require_relative '../../db/seeds.rb'
  end
end
