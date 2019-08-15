require 'yaml'
require_relative 'user_generator'

users = []
ug = UserGenerator.new
ug.emails.each do |e|
  users << {
    email: e,
    first_name: ug.random_first_name,
    last_name: ug.random_last_name,
    password: "starwars",
    zip_code: "10004",
    city: "New York",
    state: "NY"
  }
end

puts users.first
puts users.last

file = File.open("users.yaml", "w")
file.write(users.to_yaml)
file.close
