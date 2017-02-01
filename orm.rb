require 'pg'

class Orm

  def initialize
    @conn = PG.connect(:host => '127.0.0.1', :port => 5432, :dbname => 'testdb', :user => 'test', :password => 'usroftest')
    @curdate = Time.now
    @maintable = "users"
    @linktable = "authdata"
  end

  def get_values(command, flag_admin = false)
    params1 = {}
    params2 = {}
    case command
      when "insert"
        params1[:name] = check_value(/\A[A-Za-z]{1,20}\z/, "Name (max 20 latin leters)").capitalize
        params1[:secname] = check_value(/\A[A-Za-z]{1,30}\z/, "Patronymic (max 30 latin leters)").capitalize
        params1[:surname] = check_value(/\A[A-Za-z]{1,30}\z/, "Surname (max 30 latin leters)").capitalize
        params2[:login] = check_value(/\A\w{1,50}\z/, "Login (max 50 symbols, use only 0-9, A-z, _)")
        params2[:password] = check_value(/\A\S{1,50}\z/, "Password (max 50 symbols, use only 0-9, A-z, _)")
        params2[:email] = check_value(/\A\S{1,10}\@\w{1,10}\.[A-Za-z]{1,10}\z/, "Email (format: my@email.com)").downcase
        params1[:sex] = check_value(/\A[MmWw]{1}\z/, "пол (M или W)").capitalize
        params1[:born] = check_value(/\A\d\d\.\d\d\.\d{4}\z/, "born date(Format: 01.01.2000)").capitalize
        params1[:flag_admin] = flag_admin
        params1[:fd] = Time.now
        params2[:fd] = Time.now
        params1[:td] = "01.01.9999"
        params2[:td] = "01.01.9999"
      when "close"
        params2[:login] = check_value(/\A\w{1,50}\z/, "Login for close")
      when "delete"
        params2[:login] = check_value(/\A\w{1,50}\z/, "Login for remove")
      when "find"
        params2[:login] = check_value(/\A\w{1,50}\z/, "Login for search")
      when "login"
        params2[:login] = check_value(/\A\w{1,50}\z/, "Login")
        params2[:password] = check_value(/\A\S{1,50}\z/, "Password")
      end
    return params1, params2
  end

  def create_user(values = get_values("insert"))
    res = modify_string("insert", @maintable, values[0], "n")
    values[1][:up] = res[0]['n']
    res = modify_string("insert", @linktable, values[1], "up")
    puts "was created #{res.cmdtuples()} users"
  end

  def close_user(values = get_values("close"))
    res = modify_string("find", @linktable, values[1], nil)
    if res.cmdtuples() == 0
      puts "user not found."
    else
      modify_string("update", @linktable, {:td => Time.now}, {:up => res[0]['up']})
      res = modify_string("update", @maintable, {:td => Time.now}, {:n => res[0]['up']})
      puts "was closed #{res.cmdtuples()} users"
    end
  end

  def delete_user(values = get_values("delete"))
    res = modify_string("find", @linktable, values[1], nil)
    if res.cmdtuples() == 0
      puts "user not found."
    else
      modify_string("delete", @linktable, {:up => res[0]['up']}, nil)
      res = modify_string("delete", @maintable, {:n => res[0]['up']}, nil)
      puts "was deleted #{res.cmdtuples()} users"
    end
  end  

  def find_user( values = get_values("find"))
    res1 = modify_string("find", @linktable, values[1], nil)
    if res1.cmdtuples() == 0
      puts "user not found."
    else
      res2 = modify_string("find", @maintable, {:n => res1[0]['up']}, nil)
      puts "found #{res2.cmdtuples()} users"
      i = 0
      res2.cmdtuples().times do 
        puts "#{i+1}. #{res2[i]['surname']} #{res2[i]['name']} #{res2[i]['secname']} was registered #{res2[i]['fd']} and has SN: #{res2[i]['n']}, login: #{res1[i]['login']}, email: #{res1[i]['email']} "
        i+=1
      end
    end
  end

  def login(values = get_values("login"))
    res = modify_string("find", @linktable, values[1], nil)
    if res.cmdtuples() == 0
      puts "user not found."
    else
      fl_adm = modify_string("find", @maintable, {:n => res[0]['up']}, nil)
      puts "","--------","Welcome to administration panel:", "--------", ""
      admin(fl_adm[0]['flag_admin'])
    end
  end

  private

  def admin(flag_admin)
    puts "Input a command:", "C - create user (for Admin),", "D - full delete user (for admin),", "CL - close user(for Admin)", "F - find user", "H - help", "Q - quit"
    loop do
      if flag_admin == 't' 
        command = check_value(/\A[QqCcDdFfHh]{1}[Ll]?\z/, "command").upcase
      else
        command = check_value(/\A[FfHhQq]{1}\z/, "command").upcase
      end
      case command
        when "C"
          create_user
        when "D"
          delete_user
        when "CL"
          close_user
        when "F"
          find_user
        when "H"
          puts "All command:", "C - create user (for Admin),", "D - full delete user (for admin),", "CL - close user(for Admin)", "F - find user", "H - help", "Q - quit"
        when "Q"
          break
      end
    end
    puts "","--------","Good bye!", "--------"
  end

  def modify_string(command = "select", table, values, params)
    values.collect { |key, value| values[key] = ((value.is_a? String) || (value.is_a? Time)) ? "'#{value}'" : value } unless values.nil?
    params.collect { |key, value| params[key] = ((value.is_a? String) || (value.is_a? Time)) ? "'#{value}'" : value } unless params.nil? or params.is_a? String

    case command
      when "insert"
        @conn.exec "insert into #{table} (#{values.keys.join(', ')}) values (#{values.values.join(', ')}) returning #{params};"
      when "delete"
        @conn.exec "delete from #{table} where #{values.collect { |key, value| "#{key} = #{value}" }.join(', and ')};"
      when "update"
        @conn.exec "update #{table} set #{values.collect { |key, value| "#{key} = #{value}" }.join(', ')} where #{params.collect { |key, value| "#{key} = #{value}" }.join(' and ')}" unless params.nil?
      else
        @conn.exec "select * from #{table} where #{values.collect { |key, value| "#{key} = #{value}" }.join(' and ')} and td > current_timestamp;"
    end
  end

  def check_value(regexp, str)
    puts "Input #{str}:"
    loop do
      key = gets.chomp
      regexp =~ key ? (return key) : (puts "Wrong format try again:")
    end
  end

end
