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
  s.has_rdoc = true

  # files
  s.files = Dir.glob("**/*")
  s.executables = Dir["bin/*"].map { |executable| File.basename(executable) }
  #s.default_executable = ""
  s.require_paths = ["lib"]

  # Ruby version
  s.required_ruby_version = ::Gem::Requirement.new("~> 1.9")

  # === Dependencies ===
  # RubyGems has runtime dependencies (add_dependency) and
  # development dependencies (add_development_dependency)
  # Rango isn't a monolithic framework, so you might want
  # to use just one specific part of it, so it has no sense
  # to specify dependencies for the whole gem. If you want
  # to install everything what you need for start with Rango,
  # just run gem install rango --development

  s.add_development_dependency "simple-templater", ">= 0.0.1.2"
  s.add_development_dependency "bundler"

  begin
    require "changelog"
  rescue LoadError
    warn "You have to have changelog gem installed for post install message"
  else
    changelog = CHANGELOG.new(File.join(File.dirname(__FILE__), "CHANGELOG"))
    s.post_install_message = "=== Changes in the last Git-deploy ===\n  - #{changelog.last_version_changes.join("\n-  ")}"
  end

  # RubyForge
  s.rubyforge_project = "git-deployer"
end
