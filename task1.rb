if ARGV.length != 1
  puts "We need exactly one parameter. The name of a file."
  exit;
end

filename = ARGV[0]

fo = open filename
$stdout = open('result.txt', 'w')
i = 0

fo.each do |line|
  if line =~ /<worker name/
    i+=1
    separline = line.split('=')
    startind = separline[1].index('"')
    endind = separline[1].rindex('"')
    puts "#{i}. " + separline[1][startind+1..endind-1]
  end
end
 
fo.close