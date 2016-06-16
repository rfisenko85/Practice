if ARGV.length != 1
  puts "You need exactly one parameter. The name of a file."
  exit;
end

filetext = IO.read(ARGV[0])
reg = /\s*<worker.+name\s*=\s*"(\w+)".*/
str = filetext.scan(reg)
$stdout = open('result.txt', 'w')
puts str