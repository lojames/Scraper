def url_source_to_string(url)
  require 'open-uri'

  source = open(url,
              "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36").read
end

url = "https://yawp-app.herokuapp.com"
puts url_source_to_string(url)

###Business
#name
#neighborhood (opt)
#street_address
#city
#state
#zip
#phone (opt)
#website (opt)
#price (opt)
#latitude
#longitude

###Business Hours
#day
#hours
#business_id

###Business Categories
#Scrape all business categories into an array
#FOR SEEDING: search categories by "ref" to get category id

###Business Properties
#Scrape all business properties into an array
#FOR SEEDING: search categories by "key" and "value" to get property id...if ID doesn't exist, create new business property

###Reviews
#body
#business_id
#score

###Images
#image_url (generate after scraping)
#comment
#user_id
#business_id
#review_id
