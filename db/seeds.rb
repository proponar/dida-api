# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(name: 'martin', password: 'kompost', token: 'sekkrit')

Source.create(name: 'vlasta', typ: 'casopis', rok: 1984, lokalizace: 'Brno')
Source.create(name: 'vlasta', typ: 'casopis', rok: 1985, lokalizace: 'Praha')
