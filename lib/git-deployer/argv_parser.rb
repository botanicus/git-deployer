# coding: utf-8

# @done
class ArgvParser
  # ["--uploads", "--database=sqlite3"] => {:uploads => true, :database => "sqlite3"}
  def self.to_params(argv = ARGV)
    params = Hash.new
    argv.each do |arg|
      arg = arg.delete("--")
      if arg.match(Regexp.new("="))
        key, value = arg.split("=")
        params[key.to_sym] = value
      else
        params[arg.to_sym] = true
      end
    end
    return params
  end
  
  # {:uploads => true, :database => "sqlite3"} => --uploads --database=sqlite3
  def self.to_argv(hash)
    argv = Array.new
    hash.each do |key, value|
      if [false, true, nil].include?(value)
        argv << "--#{key}"
      else
        argv << "--#{key}=#{value}"
      end
    end
    return argv.join(" ")
  end
end
