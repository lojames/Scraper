require_relative 'user_generator'

#Create Users
users = []
ug = UserGenerator.new
ug.emails.each do |e|
  users << User.create(
    email: e,
    first_name: ug.random_first_name,
    last_name: ug.random_last_name,
    password: "starwars",
    zip_code: "10004",
    city: "New York",
    state: "NY"
  )
end

data = YAML.load(File.read("data.yaml"))
businesses = []
data.values.each do |b|
  businesses << Business.create(
    name: b.name,
    neighborhood: b.neighborhood,
    street_address: b.street_address,
    city: b.city,
    state: b.state,
    zip: b.zip,
    phone: b.phone,
    website: b.website,
    price: b.price,
    latitude: b.latitude,
    longitude: b.longitude
  )

  b.business_hours.each do |h|
    BusinessHour.create(business_id: businesses.last.id, day: h[0], hours: h[1])
  end

  b.business_categories.each do |c|
    BusinessCategory.create(business_id: businesses.last.id, category_id: Category.where("ref = #{c}").first.id
  end

  b.business_properties.each do |p|
    
  end

end
