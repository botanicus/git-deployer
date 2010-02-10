#!/usr/bin/env gem build
# encoding: utf-8

require "base64"

Gem::Specification.new do |s|
  s.name = "git-deployer"
  s.version = "0.0.2"
  s.authors = ["Jakub Šťastný aka Botanicus"]
  s.homepage = "http://github.com/botanicus/git-deployer"
  s.summary = "Easy deploy system based on Git hooks"
  s.description = "" # TODO: long description
  s.cert_chain = nil
  s.email = Base64.decode64("c3Rhc3RueUAxMDFpZGVhcy5jeg==\n")
  s.has_rdoc = false

  # files
  s.files = `git ls-files`.split("\n")

  s.require_paths = ["tasks"]

  # dependencies
  s.add_development_dependency "nake"

  # RubyForge
  s.rubyforge_project = "git-deployer"
end
