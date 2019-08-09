require 'mini_magick'
require 'aws-sdk-s3'

image = MiniMagick::Image.open("o.jpg")
w, h = image.dimensions

x = w > h ? h : w

if x < 400.0
  image.write("s.jpg")
else
  scale = 350.0/x*100
  image.resize "%#{scale}"
  w, h = image.dimensions
  image.crop  "350x350+#{(w-350)/2.0}+#{(h-350)/2.0}"
  image.write("s.jpg")
end

yelp_id = "TestFolder"

s3 = Aws::S3::Resource.new(region:'us-east-1')
o = s3.bucket('yawp-app').object("bphoto/#{yelp_id}/o.jpg")
o.upload_file('o.jpg', acl:'public-read')
s = s3.bucket('yawp-app').object("bphoto/#{yelp_id}/s.jpg")
s.upload_file('s.jpg', acl:'public-read')
puts s.public_url
puts o.public_url
