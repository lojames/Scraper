require 'yaml'

class UserGenerator

  def initialize
    @characters = 'abcdefghijklmnopqrstuvwxyz'.split("")
    @domains = ['@gmail.com', '@outlook.com', '@yahoo.com']

    names = YAML.load(File.read("names.yml"))
    @first_names = names[:first_names]
    @last_names = names[:last_names]
  end

  def random_name
    @first_names.sample + " " + @last_names.sample
  end

  def random_male_name
    @first_names[0...30].sample + " " + @last_names.sample
  end

  def random_female_name
    @first_names[30...60].sample + " " + @last_names.sample
  end

  def random_email
    @characters.sample + @domains.sample
  end

  def names(num=60)
    count = 0
  end

  def emails(num=78)
    count = 0
    emails = []
    until count == num
      @characters.each do |c|
        @domains.each do |d|
          emails << (c+d)
          count+=1
          return emails if count == num
        end
      end
    end
    emails
  end

end

generator = UserGenerator.new
puts generator.emails.length
puts generator.emails.first
puts generator.emails.last
