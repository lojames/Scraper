require 'open-uri'
require 'json'
require 'set'
require 'cgi'
require 'mini_magick'
require 'aws-sdk-s3'
require 'yaml'
require_relative 'api_keys'

class YelpBusiness
  def initialize(url)
    @source = open(url,
      "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36").read

    biz_header = @source.scan(/(?<=<script type="application\/ld\+json">).*?(?=<)/m)[-1]
    unless biz_header
      puts "Invalid url."
      return
    end

    @yelp_id = url.split('/').last

    images_url = "https://www.yelp.com/biz_photos/#{@yelp_id}"

    @name = biz_header.scan(/(?<=\"name\": \").*?(?=\", \"address\")/m)[0]
    @street_address = biz_header.scan(/(?<=\"streetAddress\": \").*?(?=\", \"postalCode\")/m)[0]
    @city = biz_header.scan(/(?<=\"addressLocality\": \").*?(?=\", \"addressRegion\")/m)[0]
    @state = biz_header.scan(/(?<=\"addressRegion\": \").*?(?=\", \"streetAddress\")/m)[0]
    @zip = biz_header.scan(/(?<=\"postalCode\": \").*?(?=\", \"addressCountry\")/m)[0]
    @phone = biz_header.scan(/(?<=\"telephone\": \"\+1).*?(?=\")/m)[0]
    @phone = @phone ? "(#{@phone[0..2]}) #{@phone[3..5]}-#{@phone[6..9]}" : @phone

    @neighborhood = @source.scan(/(?<=<span class=\"neighborhood-str-list\">).*?(?=<)/m)[0]
    @neighborhood = @neighborhood ? @neighborhood.strip! : @neighborhood

    @website = @source.scan(/(?<=href=\"\/biz_redir\?url=http%3A%2F%2F).*?(?=&amp)/m)[0]
    @website = @source.scan(/(?<=href=\"\/biz_redir\?url=https%3A%2F%2F).*?(?=&amp)/m)[0] unless @website
    @website = @website[0..3] == "www." ? @website[4..-1] : @website
    @website = CGI.unescape(@website)
    @website = @website[-1] == '/' ? @website[0...-1] : @website

    @price = @source.scan(/(?<=<span class=\"business-attribute price-range\">).*?(?=<)/m)[0]

    get_coordinates
    get_categories
    get_hours
    get_properties

    @images = []
    @images_array = []
    get_images(images_url)
    @reviews = []
    get_reviews
  end

  def self.valid_url?(url)
    url.match(/yelp.com\/biz\//)[0] ? true : false
  end

  def to_s
    "Business Name: #{@name}
    Business Address: #{@street_address}, #{@city}, #{@state}, #{@zip}
    Phone: #{@phone}
    Website: #{@website}
    Price: #{@price}
    Coordinates: #{@latitude}, #{@longitude}

    Categories:
    #{@business_categories}

    Hours:
    #{@business_hours}

    Properties:
    #{@business_properties}

    Images:
    #{@images}

    Reviews:
    #{@reviews}
    "
  end

  def to_yaml
    businesses = YAML.load_file("data.yaml")
    if businesses[@yelp_id]
      puts "Business already exists in data file."
    else
      businesses[@yelp_id] = {
        name: @name,
        street_address: @street_address,
        city: @city,
        state: @state,
        zip: @zip,
        phone: @phone,
        website: @website,
        price: @price,
        latitude: @latitude,
        longitude: @longitude,
        business_categories: @business_categories,
        business_hours: @business_hours,
        business_properties: @business_properties,
        reviews: @reviews,
        images: @images
      }
      File.write("temp.yaml", businesses.to_yaml)
      t = Time.new
      backup_file_name = "data-#{t.year}-#{t.month}-#{t.day}-#{t.hour}-#{t.min}-#{t.sec}.yaml"
      File.rename("data.yaml", "archive/#{backup_file_name}")
      File.rename("temp.yaml", "data.yaml")
      puts "Data successfully added to data.yaml."
    end
  end

  private
  def get_coordinates
    street_address = @street_address.split.join('+')
    city = @city.split.join('+')
    geoencode_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{street_address},+#{city},+#{@state},+#{@zip}&key=#{ApiKeys.google_api_key}"
    response = open(geoencode_url,
      "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36").read
    response_hsh = JSON.parse(response)
    @latitude = response_hsh["results"][0]["geometry"]["location"]["lat"]
    @longitude = response_hsh["results"][0]["geometry"]["location"]["lng"]
  end

  def get_categories
    top_level_categories = @source.scan(/(?<=\"top_level_categories\": \[).*?(?=\])/m)[0]
    top_level_categories = top_level_categories.split('"').last.split(',').map {|s| s.strip}

    second_level_categories = @source.scan(/(?<=\"second_level_categories\": \[).*?(?=\])/m)[0]
    second_level_categories = second_level_categories.split('"').last.split(',').map {|s| s.strip}

    categories = top_level_categories + second_level_categories
    @business_categories = categories.uniq
  end

  def get_hours
    business_hours_table = @source.scan(/<tbody.*<\/tbody>/m)[0]
    days = Set["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @business_hours = []
    idx = 0
    key = ""
    value = ""
    while idx < business_hours_table.length-1
      text = ""
      if business_hours_table[idx] == '>'
        idx+=1
        while business_hours_table[idx] != '<'
          text += business_hours_table[idx]
          idx+=1
        end
      end
      idx+=1
      text.strip!
      unless text.empty?
        if days === text
          unless value == "Closed now" or key.empty? or value == "Open now"
            @business_hours << [key, value]
          end
          key = text
          value = ""
        elsif value.count('m') == 2
          @business_hours << [key, value]
          value = text
        else
          value.empty? ? value += text : value += " "+text
        end
      end
    end
    @business_hours << [key, value] unless value.include?("ours")
  end

  def get_properties
    business_properties_table = @source.scan(/<div class=\"short-def-list\">.*?<\/div>/m)[0]

    if business_properties_table
      @business_properties = []
      idx = 0
      counter = 0
      key = nil

      while idx < business_properties_table.length-1
        text = ""
        if business_properties_table[idx] == '>'
          idx+=1
          while business_properties_table[idx] != '<'
            text += business_properties_table[idx]
            idx+=1
          end
        end
        idx+=1
        text.strip!
        unless text.empty?
          counter += 1
          if counter.even?
            @business_properties << [key, text]
          else
            key = text
          end
        end
      end
    end
  end

  def get_reviews
    num_reviews = 4+rand(12)
    review_blocks = @source.split("<div class=\"review-content\">")[1..num_reviews]

    review_blocks.each do |review_block|
      body = review_block.match(/(?<=<p lang=\"en\">).*?(?=<\/p>)/m)
      body = body ? body[0] : nil

      score = review_block.match(/(?<=title=\").*?(?= star rating\")/m)
      score = score ? score[0] : nil

      date = review_block.match(/([1-9]|1[012]?)\/([12]?[1-9]|3[01])\/(\d\d\d\d)/m)
      date = date ? date[0] : nil

      @reviews << {body: body, score: score, date: date}
      image_review_block = review_block.scan(/(?<=<img data-async-src=).*?(?=>)/m)
      image_review_block.each do |b|
        image_id = b.scan(/(?<=bphoto\/).*?(?=\/)/)[0]
        comment = b.scan(/(?<=United States\. ).*?(?=\")/)[0]
        if @images_array.index(image_id)
          @images[@images_array.index(image_id)] = {image_url: image_id, comment: comment, body: body, score: score, date: date}
        else
          s3_url = "https://s3-media4.fl.yelpcdn.com/bphoto/#{image_id}/o.jpg"
          open(s3_url) do |image|
            File.open("./o.jpg", "wb") do |file|
              file.write(image.read)
            end
          end
          convert_image
          upload_image(image_id)
          @images_array << image_id
          @images << {image_url: image_id, comment: comment, body: body, score: score, date: date}
        end
      end
    end
  end

  # Scrapes between 4 and 8 images from the images_url which should be in the
  # format: https://www.yelp.com/biz_photos/#{@yelp_id}.  Each image is copied
  # and scaled (for thumbnails) and then uploaded to the yawp-app s3 bucket.
  # Relevant data about the image are stored in instance variables.
  def get_images(images_url)
    image_source = open(images_url,
      "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36").read
    num_images = 4+rand(5)

    # Split up the image source file into blocks containing each individual
    # image data.
    # MAY NEED CHANGES IF YELP FORMATTING CHANGES
    image_blocks = image_source.scan(/(?<=<li data-photo-id=").*?(?=<\/li>)/m)
    (0..num_images).each do |i|

      # MAY NEED CHANGES IF YELP FORMATTING CHANGES
      image_id = image_blocks[i].split('"').first
      s3_url = "https://s3-media4.fl.yelpcdn.com/bphoto/#{image_id}/o.jpg"
      open(s3_url) do |image|
        File.open("./o.jpg", "wb") do |file|
          file.write(image.read)
        end
      end
      convert_image
      upload_image(image_id)

      # Extract comments with a lookahead and lookbehind
      # MAY NEED CHANGES IF YELP FORMATTING CHANGES
      comment = image_blocks[i].scan(/(?<=, United States.).*?(?=\" class)/m)[0]
      @images_array << image_id
      @images << {image_url: image_id, comment: comment}
    end
  end

  # Rescales and centers and image to a square image of 'px' width and height
  # and writes the newly scaled image to 's.jpg'.
  #
  # min_size is minimum image size (of the original image) threshhold for conversion
  def convert_image(px = 350, min_size=400)
    image = MiniMagick::Image.open("o.jpg")
    w, h = image.dimensions

    # Determine whether width or height is larger.
    x = w > h ? h : w

    if x < min_size
      image.write("s.jpg")
    else
      scale = px.fdiv(x)*100
      image.resize "%#{scale}"
      w, h = image.dimensions
      image.crop  "#{px}x#{px}+#{(w-px)/2.0}+#{(h-px)/2.0}"
      image.write("s.jpg")
    end
  end

  # Uploads 'o.jpg' and 's.jpg' to the yawp-app s3 bucket.
  def upload_image(image_id)
    s3 = Aws::S3::Resource.new(region:'us-east-1')
    o = s3.bucket('yawp-app').object("bphoto/#{image_id}/o.jpg")
    o.upload_file('o.jpg', acl:'public-read')
    s = s3.bucket('yawp-app').object("bphoto/#{image_id}/s.jpg")
    s.upload_file('s.jpg', acl:'public-read')
  end
end

url = ARGV[0]
if YelpBusiness.valid_url? (url)
  business = YelpBusiness.new(url)
  puts business.to_s
  business.to_yaml
else
  puts "Invalid url."
end
