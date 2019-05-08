def url_source_to_string(url)
  require 'open-uri'

  source = open(url,
              "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36").read
end

url = "https://yawp-app.herokuapp.com"
puts url_source_to_string(url)
