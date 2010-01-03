#!/usr/bin/env gem build
# encoding: utf-8

Gem::Specification.new do |s|
  s.name = "git-deployer"
  s.version = "0.0.1"
  s.authors = ["Jakub Šťastný aka Botanicus"]
  s.homepage = "http://github.com/botanicus/git-deployer"
  s.summary = "Easy deploy system based on Git hooks"
  s.description = "" # TODO: long description
  s.cert_chain = nil
  s.email = ["knava.bestvinensis", "gmail.com"].join("@")
  s.has_rdoc = false

  # files
  s.files = Dir.glob("**/*") - Dir.glob("*.gem")
  s.require_paths = ["tasks"]

  # dependencies
  s.add_development_dependency "nake"

  # RubyForge
  s.rubyforge_project = "git-deployer"
end
