require_relative 'user_generator'

# businesses = YAML.load(File.read("data.yml"))
# puts businesses

#Create Users
ug = UserGenerator.new
ug.emails.each do
users = []
