#!/usr/bin/env ruby1.9
# coding: utf-8

require "git-deploy"

name    = ARGV.first # branch name
project = Project.new(Dir.pwd)
branch  = project.branch(branch_name)

if branch
  project.create_branch(branch)
else
  branch.update
end
