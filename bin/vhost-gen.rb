#!/usr/bin/env ruby
# coding: utf-8

# Examples
# vhost-gen.rb /webs/static/101ideas.cz
# => domain: 101ideas.cz
# => branch: master
# => path: /webs/static/101ideas.cz/master
# => document root: /webs/static/101ideas.cz/master

# vhost-gen.rb /webs/static/101ideas.cz master
# => domain: 101ideas.cz
# => branch: master
# => path: /webs/static/101ideas.cz/master
# => document root: /webs/static/101ideas.cz/master/public

# vhost-gen.rb /webs/static/101ideas.cz alpha
# => domain: alpha.101ideas.cz
# => branch: alpha
# => path: /webs/static/101ideas.cz/alpha
# => document root: /webs/static/101ideas.cz/alpha/public

# if project match "." (botablog.cz), then project is in production
# and so it generates vhost for botablog.cz, but if project do not
# match "." (dytrych, taz), then project is in development and so
# it generates vhost for dytrych.101ideas.cz

# vhost-gen.rb /webs/apps/merb/taz master
# => domain: taz.101ideas.cz
# => branch: master
# => path: /webs/apps/merb/taz/master
# => document root: /webs/apps/merb/taz/master/public

@root = ARGV.shift
@domain = File.basename(@root)
@branch = ARGV.shift || "master"
@type = @root.split("/")[2]

@domain = "#@domain.101ideas.cz" unless @domain.match(/\./)

if @type == "django"
  @project_root  = File.join(@root, @branch, "web")
  @document_root = File.join(@project_root,  "media")
else
  @project_root  = File.join(@root, @branch)
  @document_root = File.join(@project_root, "public")
end

require "erb"
template = File.join(File.dirname(__FILE__), "..", "templates", "#{@type}.vhost.erb")
puts ERB.new(File.read(template)).result(binding)
