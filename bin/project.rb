#!/usr/bin/env ruby
# coding: utf-8

# TODO: base = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require "git-deployer"

if ARGV.length < 2
  puts "=== Usage ===".red
  puts "project.sh [create|destroy] [path]/[domain]  [options]"
  puts "project.sh create /webs/apps/rango/101ideas.cz [options]"
  puts
  puts "=== Arguments ===".red
  puts "Path: /webs/apps/rango, /webs/static"
  puts "Domain: example.com"
  puts
  puts "=== Options ===".red
  puts "--database=[mysql|sqlite]"
  puts "--uploads"
  puts
  puts "=== Environment ===".red
  puts "BACKUPDIR points to dir with data [Example: /webs/backups]"
  exit 1
end

action = ARGV.shift.to_sym
path = ARGV.shift

unless [:create, :destroy].include?(action)
  abort "First argument must be create or destroy".red
end

if CONFIG.user != ENV["USER"]
 abort "You must be #{CONFIG.user}".red
end

options = ARGV.to_params

case action
when :destroy
  project = Project.new(path)
  project.destroy(options)
when :create
  options[:backupdir] = ENV["BACKUPDIR"]
  project = Project.create(path, options)
  puts project.metadata
end
