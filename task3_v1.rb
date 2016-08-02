require 'open-uri'
require 'time'

# Get city name from keyboard and encode if OS=win
def get_city
  puts "step 1"
  case RUBY_PLATFORM
    when /win/i, /ming/i
      city = gets.chomp.encode("utf-8", "cp866")
    else
      city = gets.chomp
  end
  city
end

# Transleterate city name
def rus_to_en(word)
  puts "step 2"
  array = word.split('')
  i=0
  array.each do |letter|
    case letter
      when "а", "А" then array[i] = "a"
      when "б", "Б" then array[i] = "b"
      when "в", "В" then array[i] = "v"
      when "г", "Г" then array[i] = "g"
      when "д", "Д" then array[i] = "d"
      when "е", "Е" then array[i] = "e"
      when "ё", "Ё" then array[i] = "e"
      when "ж", "Ж" then array[i] = "zh"
      when "з", "З" then array[i] = "z"
      when "и", "И" then array[i] = "i"
      when "й", "Й" then array[i] = "y"
      when "к", "К" then array[i] = "k"
      when "л", "Л" then array[i] = "l"
      when "м", "М" then array[i] = "m"
      when "н", "Н" then array[i] = "n"
      when "о", "О" then array[i] = "o"
      when "п", "П" then array[i] = "p"
      when "р", "Р" then array[i] = "r"
      when "с", "С" then array[i] = "s"
      when "т", "Т" then array[i] = "t"
      when "у", "У" then array[i] = "u"
      when "ф", "Ф" then array[i] = "f"
      when "х", "Х" then array[i] = "kh"
      when "ц", "Ц" then array[i] = "ts"
      when "ч", "Ч" then array[i] = "ch"
      when "ш", "Ш" then array[i] = "sh"
      when "щ", "Щ" then array[i] = "shch"
      when "ъ", "Ъ" then array[i] = ""
      when "ы", "Ы" then array[i] = "y"
      when "ь", "Ь" then array[i] = ""
      when "э", "Э" then array[i] = "e"
      when "ю", "Ю" then array[i] = "yu"
      when "я", "Я" then array[i] = "ya"
      else array[i] = letter
    end
    i+=1
  end
  word = array.join
end

# Get coordinates by city name
def get_coordinates(city = 'London', proxy_exist = 0)
  puts "step 3"
  source_coord = (proxy_exist == 1) ? open("http://maps.google.com/maps/api/geocode/xml?address=#{city}&sensor=false", :proxy=>'http://127.0.0.1:3128') : 
                                      open("http://maps.google.com/maps/api/geocode/xml?address=#{city}&sensor=false")

  text_source_coord = source_coord.read

#  File.open("text.txt", "w") { |f| f.puts text_source_coord }

  adderss_reg = /<formatted_address>(.*?)<\/formatted_address>/
  coord_reg = /<location>\s*?<lat>(-?\d*\.\d*)<\/lat>\s*?<lng>(-?\d*\.\d*)<\/lng>\s*?<\/location>/

  text_adderess = text_source_coord.scan(adderss_reg)
  text_coord = text_source_coord.scan(coord_reg)
  puts text_adderess[0][0]
  "lat=#{text_coord[0][0]}&lng=#{text_coord[0][1]}"
end

# Get time and timezone by coordinates
def get_timezone_by_coordinates(coordinates = "lat=0.00&lng=0.00", proxy_exist = 0)

  puts "step 4"
  #Get London time
  source_london_time = (proxy_exist == 1) ? open("http://ws.geonames.org/timezone?lat=51.5073509&lng=-0.1277583&username=apiuser", :proxy=>'http://127.0.0.1:3128') :
                                            open("http://ws.geonames.org/timezone?lat=51.5073509&lng=-0.1277583&username=apiuser")
  text_london_time = source_london_time.read
  #Get city time
  source_timezone = (proxy_exist == 1) ? open("http://ws.geonames.org/timezone?#{coordinates}&username=apiuser", :proxy=>'http://127.0.0.1:3128') : 
                                         open("http://ws.geonames.org/timezone?#{coordinates}&username=apiuser")
  text_timezone = source_timezone.read

  #Get real hour from site
  time_reg = /<time>\d{4}-\d{2}-\d{2}\s(\d{2}:\d{2})<\/time>/
  array_london_time = text_london_time.scan(time_reg)
  time = Time.new
  real_london_time = Time.parse(array_london_time[0][0]).to_a
  real_london_hour = real_london_time[2]

  #Get hour from utc method
  london_time = time.utc.to_a
  london_hour = london_time[2]
  utc_reg = (real_london_hour - london_hour == 1) ? /<dstOffset>(-?\d*.\d*)<\/dstOffset>/ : /<gmtOffset>(-?\d*.\d*)<\/gmtOffset>/

#  File.open("text2.txt", "w") { |f| f.puts text_timezone }
 
  array_utc = text_timezone.scan(utc_reg)
  f_utc = array_utc[0][0].to_f

  text_time = text_timezone.scan(time_reg)
  city_time = time.utc + f_utc*3600
  "Time: #{city_time}"
end

proxy_exist = 0
puts "Input the city name:"
city = get_city
convert_city_name = rus_to_en(city)
coord = get_coordinates(convert_city_name, proxy_exist)
s_time = get_timezone_by_coordinates(coord, proxy_exist)

puts s_time





