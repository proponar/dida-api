# API for DIDA entry app.

* Dependencies:
  * Ruby 2.6.x, Rails 6.x.
  * PosgreSQL

* Configuration

* Database creation

* Database initialization

* Running tests:
  First seed the locations:

  `RAILS_ENV=test rake db:seed_location`

  Run all tests, documentation format:
  `bundle exec rake spec SPEC_OPTS=-fd`

  Run a single test:
  `bundle exec rake spec SPEC=./spec/models/entry_spec.rb`

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

### Progress

 * `rails new dida-api -d postgresql --api`
 * add papertrail: https://github.com/paper-trail-gem/paper\_trail

`bundle exec rails generate paper_trail:install --with-changes`

 token authorization
 * https://thoughtbot.com/blog/token-authentication-with-rails
   https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token.html

 * add "exemp"

 * add "source" model

 * add CORS: https://github.com/cyu/rack-cors

 * add "sources" controller

 * add location seeding

 * search for location
        * script to load tables
        * search action
        * test for search action

 * basic crud for entries
        * add columns
                Heslo,
                kvalifikator,
                vyznam
                vetne/nevetne,
                dejme do společné části ještě
                slovní druh (substantivum/adjektivum)
                rod (m., f., n.)
  * crud for exemps
        * add columns
                autor, exemplifikace, zdroj, lokalizace, lokalizace_text, vetne/nevetne, zdroj
                rok, kvantifikator, vyznam, deaktivovat, chybny
        * add controller + routes

  * nested /entries/exemps/
  * import with preview
  * simple auth
  * attaching files:
        https://edgeguides.rubyonrails.org/active_storage_overview.html

        `rails active_storage:install`

  * added Meanings
  * basic test for entries crud
  * basic test for import

### next:
  * session tokens

---

[![Rails test workflow](https://github.com/martinpovolny/dida-api/workflows/Rails%20tests/badge.svg?branch=master)](https://github.com/martinpovolny/dida-api/actions?query=workflow%3A%22Rails+tests%22)
