# coding: utf-8

require "yaml"
require "ostruct"

# TODO: symbolize_keys for inputs
class Config
  # TODO: spec it
  def self.find_file(*files)
    file = files.compact.find(&File.method(:exist?))
    return self.load(file)
  rescue
    raise "Configuration file doesn't exist. Tryied #{files}"
  end
  
  def self.load(file)
    self.new(file, YAML::load_file(file))
  rescue TypeError
    raise "File must be string, got #{file.inspect}"
  end
  
  # TODO: spec it
  def self.save(file, properties)
    FileUtils.touch(file) unless File.file?(file)
    self.new(file, properties).tap { |config| config.save }
  end

  attr_accessor :properties
  def initialize(file, properties = Hash.new)
    @file = file
    @properties = properties
  end
  
  def save
    File.open(@file, "w") do |file|
      file.puts(@properties.to_yaml)
    end
  end
  
  def to_s
    @properties.map do |key, value|
      "#{key}: #{value}"
    end
  end
  
  def method_missing(method, value = nil)
    if method.match(/^(.+)=$/) && ! value.nil?
      @properties[$1.to_sym] = value
    else
      @properties[method]
    end
  end
end