# coding: utf-8

require "yaml"
require "extlib"
require "fileutils"
require "ostruct"
require "term/ansicolor"
require "git-deploy/argv"
require "git-deploy/config"
require "git-deploy/helpers"
require "git-deploy/mixins"
require "git-deploy/servers"
require "git-deploy/project"
require "git-deploy/application"

String.send(:include, Term::ANSIColor)
