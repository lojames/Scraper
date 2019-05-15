require 'yaml'

characters = 'abcdefghijklmnopqrstuvwxyz'
domains = ['@gmail.com', '@outlook.com', '@yahoo.com']

names = YAML.load(File.read("names.yml"))
first_names = names[:first_names]
last_names = names[:last_names]

puts first_names.to_s
puts last_names.to_s
