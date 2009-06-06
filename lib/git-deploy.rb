# coding: utf-8

require "yaml"
require "extlib"
require "fileutils"
require "ostruct"
require "term/ansicolor"
require "git-deploy/config"
require "git-deploy/helpers"
require "git-deploy/core_ext"
include FileUtils

local  = File.join(File.dirname(__FILE__), "..", "config", "config.yml")
CONFIG = Config.find_file(ENV["GD_CONFIG"], "/etc/git-deploy.yml", local)

String.send(:include, Term::ANSIColor)
