# coding: utf-8

require "ostruct"

local = File.join(File.dirname(__FILE__), "..", "..", "config.yml")
locations = [local, "/etc/git-deploy.yml"]
file = locations.find { |file| File.exist?(file) }

if file.nil?
  abort "Configuration file wasn't found in these locations: #{locations}"
end

data = YAML::load_file(file)
Config = OpenStruct.new(data)
