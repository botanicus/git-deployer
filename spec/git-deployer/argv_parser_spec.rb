# coding: utf-8

require File.join(Dir.pwd, "spec", "spec_helper")
require "git-deployer/argv_parser"

# @done
describe ArgvParser do
  before(:each) do
    @argv = ["--uploads", "--database=sqlite3"]
    @params = {uploads: true, database: "sqlite3"}
  end

  describe ".to_params" do
    it "should convert --argument to {argument: true}" do
      ArgvParser.to_params(["--argument"]).should eql(argument: true)
    end
    
    it "should convert --key=value to {key: 'value'}" do
      ArgvParser.to_params(["--key=value"]).should eql(key: "value")
    end

    it "should convert ARGV to hash of params" do
      ArgvParser.to_params(@argv).should eql(@params)
    end
  end

  describe ".to_argv" do
    it "should convert {argument: true} to --argument" do
      ArgvParser.to_argv(argument: true).should eql("--argument")
    end
    
    it "should convert {key: 'value'} to --key=value" do
      ArgvParser.to_argv(key: "value").should eql("--key=value")
    end

    it "should convert hash of params to ARGV" do
      ArgvParser.to_argv(@params).should eql(@argv.join(" "))
    end
  end
end
