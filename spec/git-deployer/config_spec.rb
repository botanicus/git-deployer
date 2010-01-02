# coding: utf-8

require File.join(Dir.pwd, "spec", "spec_helper")
require "git-deployer/config"

describe Config do
  before(:each) do
    @file = File.join(STUBS, "metadata.yml")
    File.open(@file, "w") do |file|
      file.puts({server: "thin"}.to_yaml)
    end
  end
  
  before(:each) do
    @config = Config.load(@file)
  end
  
  after(:each) do
    FileUtils.rm_f @file
  end
  
  describe ".load" do
    it "should load file" do
      properties = Config.load(@file).properties
      properties.keys.should include(:server)
      properties.keys.length.should eql(1)
    end
  end

  describe "#properties and #properties=" do
    it "should be readable and writeable" do
      @config.should respond_to(:properties)
      @config.should respond_to(:properties=)
    end
  end
  
  describe "#save" do
    it "should save properties" do
      @config.properties = {server: "mongrel"}
      @config.save
      yaml = YAML::load_file(@file)
      yaml[:server].should eql("mongrel")
    end
  end
  
  describe "#method_missing" do
    it "should returns value if property exists" do
      @config.server.should eql("thin")
    end
    
    it "should write property" do
      @config.server = "mongrel"
      @config.properties[:server].should eql("mongrel")
    end
  end
end
