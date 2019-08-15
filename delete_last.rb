require 'yaml'
require 'fileutils'

businesses = YAML.load_file("data.yaml")
last = businesses.keys.last
puts businesses[last]
puts "\n"
puts businesses[last].to_s
# if last == nil
#   puts "File is empty."
# else
#   businesses.delete(last)
#
#   t = Time.now
#   File.write("temp.yaml", businesses.to_yaml)
#   backup_file_name = "data-#{t.year}-#{t.month}-#{t.day}-#{t.hour}#{t.min}#{t.sec}.yaml"
#   File.rename("data.yaml", "archive/#{backup_file_name}")
#   File.rename("temp.yaml", "data.yaml")
#   puts "Successfully deleted #{last}."
# end
