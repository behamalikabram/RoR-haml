# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
u = User.new(username: "admin", role_name: :admin, email: "admin@duelallday.com", password: "foobar", password_confirmation: "foobar")
u.skip_confirmation!
u.save!

100.times do |t|
  u = User.new(username: "test-user-#{t}", email: "test-user#{t}@test.com", password: "foobar", password_confirmation: "foobar")
  u.skip_confirmation!
  u.save!
end