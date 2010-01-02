#!/usr/bin/env ruby
# coding: utf-8

# Usage:
# apps.rb start

require "git-deployer"

Application.all.each do |app|
  case action = ARGV.first.to_sym
  when :start, :stop, :restart
    app.send(action)
  else
    puts "Usage: #$0 [start|stop|restart]"
    exit 1
  end
end
