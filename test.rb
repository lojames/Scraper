require 'yaml'

users = YAML.load_file("users.yaml")
puts users.first
puts users.last

categories = YAML.load_file("categories.yaml")
puts categories.first[:name]
puts categories.last
