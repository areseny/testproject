# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

[User, StepClass].each do |klass|
  klass.destroy_all
end

User.create(name: "Adam Hyde", password: "password", password_confirmation: "password", email: "adam@coko.foundation")
User.create(name: "Charlie Ablett", password: "password", password_confirmation: "password", email: "charlie@enspiral.com")
User.create(name: "Jure Triglav", password: "password", password_confirmation: "password", email: "juretriglav@gmail.com")

StepClass.create(name: "PngToJpg")