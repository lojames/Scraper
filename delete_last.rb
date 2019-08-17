# Deletes the last business that was added to the data file.  Somewhat obsolete
# due to archiving, however can be useful if archived data was deleted.

require 'yaml'
require 'fileutils'

businesses = YAML.load_file("data.yaml")
last = businesses.keys.last

if last == nil
  puts "File is empty."
else
  businesses.delete(last)

  t = Time.now
  File.write("temp.yaml", businesses.to_yaml)
  backup_file_name = "data-#{t.year}-#{t.month}-#{t.day}-#{t.hour}#{t.min}#{t.sec}.yaml"
  File.rename("data.yaml", "archive/#{backup_file_name}")
  File.rename("temp.yaml", "data.yaml")
  puts "Successfully deleted #{last}."
end
