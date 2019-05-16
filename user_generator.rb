require 'yaml'

class UserGenerator
  attr_reader :first_names, :last_names
  @characters = 'abcdefghijklmnopqrstuvwxyz'
  @domains = ['@gmail.com', '@outlook.com', '@yahoo.com']

  def initialize
    names = YAML.load(File.read("names.yml"))
    @first_names = names[:first_names]
    @last_names = names[:last_names]
  end

end

puts UserGenerator.new.last_names
