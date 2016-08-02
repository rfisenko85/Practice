require 'open-uri'

puts "Input whole number in $:"
sum_dol = gets.chomp

p1 = open('https://alfabank.ru/ext-json/0.2/exchange/cash/?offset=0&limit=2')

text = p1.read

reg = /"value":(\d+\.?\d*?),/
workstr = text.scan(reg)
puts "1$ = #{workstr[0][0]} rub."
puts "#{sum_dol}$ = #{workstr[0][0].to_s.to_f * sum_dol.to_f} rub."
