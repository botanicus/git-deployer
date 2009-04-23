# coding: utf-8

class ArgvParser
  # --uploads --database=sqlite3 => {:uploads => true, :database => "sqlite3"}
  def self.to_params(argv = ARGV)
    def to_params
      params = Hash.new
      ARGV.each do |arg|
        arg = arg.dup.sub(/^--/, String.new)
        if arg.match(Regexp.new("="))
          key, value = arg.split("=")
          params[key.to_sym] = value
        else
          params[arg.to_sym] = true
        end
      end
      return params
    end
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
    argv.join(" ")
  end
end
