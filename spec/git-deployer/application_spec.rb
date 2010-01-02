# coding: utf-8

require File.join(Dir.pwd, "spec", "spec_helper")
require "git-deployer/application"

describe Application do
  before(:each) do
    @path = File.join(STUBS, "webs", "static", "test", "master")
    @app  = Application.new(@path)
  end
  
  describe ".create" do
  end

  describe "#initialize" do
    it "should raise exception if path doesn't exists" do
      -> { Application.new("/a/b/c/d/e/f/g") }.should raise_error
    end
    
    it "should not raise exception if path exists" do
      -> { Application.new(@path) }.should_not raise_error
    end
    
    it "should include tasks for server from configuration" do
      @app.class.included_modules.should include(Servers::Thin)
    end
  end

  describe "#config" do
  end
end
