# coding: utf-8

ROOT  = File.join(File.dirname(__FILE__), "..")
STUBS = File.join(ROOT, "spec", "stubs")

# configuration file
ENV["GD_CONFIG"] = File.join(STUBS, "config.yml")

$:.unshift(File.join(ROOT, "lib"))

require "git-deployer"
