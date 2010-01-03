#!/usr/bin/env nake

$:.unshift(File.join(File.dirname(__FILE__), "..", "tasks"))

load "git-deployer.nake"

Task["deployer:setup"].config[:user] = "root"
Task["deployer:setup"].config[:host] = "tagadab"
Task["deployer:setup"].config[:path] = "/var/www/deploy-test"

