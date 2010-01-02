#!/usr/bin/env ruby
# coding: utf-8

# Usage:
# app 101ideas.cz/master restart
# app 101ideas.cz restart

require "git-deployer"

action = ARGV.shift.to_sym
applications = ARGV.map { |arg| Application.new(arg) }

applications.each do |app|
  case action
  when :start, :stop, :restart
    app.send(action)
  else
    puts "Usage: #$0 [start|stop|restart] [applications]"
    exit 1
  end
end
