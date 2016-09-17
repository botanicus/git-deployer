#!/usr/bin/env ruby
# encoding: utf-8

require 'httparty'

class AssertionError < StandardError
  def initialize(a, b, method)
    super("Expected #{a.inspect} to #{method} #{b.inspect}.")
  end
end

class PendingError < StandardError
end

def assert(a, b, method = :==)
  unless a.send(method, b)
    raise AssertionError.new(a, b, method)
  end
end

def error(message)
  puts "\033[31m[ERROR]\033[0m #{message}"
end

def success(message)
  puts "\033[32m[OK]\033[0m #{message}"
end

def debug(message)
  puts "\033[35m#{message}\033[0m"
end

def info(message)
  puts "\033[33m[PENDING]\033[0m #{message}"
end

def get(uri, options = Hash.new, &block)
  request(:get, uri, options, &block)
end

def head(uri, options = Hash.new, &block)
  request(:head, uri, options, &block)
end

def request(http_verb, uri, options, &block)
  puts "\033[36m#{http_verb.to_s.upcase}\033[0m #{uri}\n\n"
  response = HTTParty.send(http_verb, uri, options)
  block.call(response)
  success uri
rescue EOFError => error
  begin
    block.call(nil)
  rescue PendingError => error
    info error.message
  rescue
    error "can't connect"
  else
    error "can't connect"
  end
rescue AssertionError => error
  error error.message
rescue PendingError => error
  info error.message
ensure
  if response
    puts
    puts "\033[33m#{response.headers.inspect}\033[0m"
    # if response.body
    #   puts
    #   debug "\033[34m#{response.body}\033[0m"
    # end
  end
  puts
  puts "====================================" * 2
  puts
end

get('http://blog.101ideas.cz/') do |response|
  assert response.code, 200
  assert response.body, "Blog 101Ideas.cz", :match
end

get('http://static.101ideas.cz/CV.html') do |response|
  assert response.code, 200
  assert response.body, "James C Russell", :match
end
