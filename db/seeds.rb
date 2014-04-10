# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#

BowlingGame.destroy_all
Throw.destroy_all
bowling_game = BowlingGame.create(id:1)
Throw.create(pins: 6, bowling_game: bowling_game) 
Throw.create(pins: 3, bowling_game: bowling_game) 
Throw.create(pins: 4, bowling_game: bowling_game) 
Throw.create(pins: 4, bowling_game: bowling_game) 
