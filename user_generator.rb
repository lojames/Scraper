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
    first_names.sample + " " + last_names.sample
  end

  def random_male_name
    first_names[0...30].sample + " " + last_names.sample
  end

  def random_female_name
    first_names[30...60].sample + " " + last_names.sample
  end

  def random_email

  end

  def names(num=60)

  end

  def emails(num=78)

  end

end

generator = UserGenerator.new
puts generator.first_names[30...60]
