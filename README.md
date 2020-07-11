# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

### Progress

 * `rails new dida-api -d postgresql --api`
 * add papertrail: https://github.com/paper-trail-gem/paper\_trail

`bundle exec rails generate paper_trail:install --with-changes`

 token authorization
 * https://thoughtbot.com/blog/token-authentication-with-rails


next:
  basic crud for entries
	* add columns
		Heslo,
		kvalifikator,
		vyznam
		vetne/nevetne,
		dejme do společné části ještě
		slovní druh (substantivum/adjektivum)
		rod (m., f., n.)

	* tests for crud
  search for location
	* script to load tables
	* search action
	* test for search action


  add "records"
  crud for records
	* add columns
		autor, exemplifikace zdroj, lokalizace, lokalizace_text, vetne/nevetne, zdroj
		rok, kvantifikator, vyznam, deaktivovat, chybny
	* add controller + routes

  attaching files:
	https://edgeguides.rubyonrails.org/active_storage_overview.html

