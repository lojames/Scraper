require 'yaml'

class UserGenerator
  attr_reader :first_names, :last_names
  @characters = 'abcdefghijklmnopqrstuvwxyz'.split("")
  @domains = ['@gmail.com', '@outlook.com', '@yahoo.com']

  def initialize
    names = YAML.load(File.read("names.yml"))
    @first_names = names[:first_names]
    @last_names = names[:last_names]
  end

  def random_name

  end

  def random_male_name

  end

  def random_female_name

  end

  def random_email

  end

  def names(num)

  end

  def emails(num)
    
  end

end

generator = UserGenerator.new
puts generator.last_names
