# coding: utf-8

require "yaml"
require "extlib"
require "fileutils"
require "ostruct"
require "term/ansicolor"
require "git-deployer/config"
require "git-deployer/helpers"
require "git-deployer/core_ext"
include FileUtils

local  = File.join(File.dirname(__FILE__), "..", "config", "config.yml")
CONFIG = Config.find_file(ENV["GD_CONFIG"], "/etc/git-deployer.yml", local)

String.send(:include, Term::ANSIColor)
