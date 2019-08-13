require 'yaml'

class UserGenerator
  attr_reader :first_names, :last_names
  def initialize
    @characters = 'abcdefghijklmnopqrstuvwxyz'.split("")
    @domains = ['@gmail.com', '@outlook.com', '@yahoo.com', '@aol.com']

    names = YAML.load(File.read("names.yml"))
    @first_names = names[:first_names]
    @last_names = names[:last_names]
  end

  def random_first_name
    @first_names.sample
  end

  def random_last_name
    @last_names.sample
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
    names = []
    until count == num
      @first_names.each do |f|
        @last_names.each do |l|
          names << (f+" "+l)
          count+=1
          return names if count == num
        end
      end
    end
    names
  end

  def emails(num=104)
    num = num > 104 ? 104 : num
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
