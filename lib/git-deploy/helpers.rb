# coding: utf-8

module Kernel
  def sh(command)
    puts "> #{command}"
    puts %x[#{command}]
  end
  
  def red(string)
    puts string.red
  end
  
  def green(string)
    puts string.green
  end
  
  def blue(string)
    puts string.blue
  end
end
