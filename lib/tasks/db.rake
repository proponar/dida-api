namespace :db do
  desc "Seed the location data."
  task :seed_location do
    config = Rails.configuration.database_configuration[Rails.env]
    system(
      'psql', '-U', config['username'],
      # FIXME: assuming no password
      '-f', 'db/seed/naki-locations.sql',
      config['database']
    )
  end

  desc "Drop, recreate and seed database."
  task :reseed => [:environment, 'db:reset', 'db:seed_location']
end