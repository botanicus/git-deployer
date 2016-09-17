#!/usr/bin/env nake

begin
  require File.expand_path("../.bundle/environment", __FILE__)
rescue LoadError
  require "bundler"
  Bundler.setup
end

# TODO: rewrite the example to Rango, it would be more interesting
# Or maybe add more examples for jekyll, nanoc, Django, maybe Rails.
$LOAD_PATH.unshift(File.expand_path("../tasks", __FILE__))

load "git-deployer.nake"

Task["deployer:setup"].config[:user] = "TODO"
Task["deployer:setup"].config[:host] = "TODO"
Task["deployer:setup"].config[:path] = "/var/www/deploy-test"
