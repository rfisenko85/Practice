require_relative 'orm'

orm = Orm.new

puts "What do you want do?", "Input: \"R\" - registry, \"L\" - login"
case gets.chomp.upcase
  when "R"
    puts "Registry:"
    orm.create_user
  when "L"
    puts "Login"
    orm.login
  else
    puts "FUUUUUCK!!!"
end