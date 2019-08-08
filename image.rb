require "mini_magick"

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
