# coding: utf-8

require File.join(Dir.pwd, "spec", "spec_helper")
require "git-deploy/static"

def owner(file)
  require "etc"
  uid = File.stat(file).uid
  Etc.getpwuid(uid).name
end

describe Static do
  before(:each) do
    @path = File.expand_path(File.join(STUBS, "webs", "static"))
  end
  
  describe ".create" do
    before(:each) do
      @static = quiet { Static.create }
    end
    
    after(:each) do
      system("rm -rf spec/stubs/webs/static") #####
      quiet { @static.destroy }
    end

    it "should create directory CONFIG.static" do
      File.directory?(@path).should be_true
    end
    
    it "should create user static" do
      pending "OS X doesn't have useradd command" do
        File.readlines("/etc/passwd").find { |line| line.match(/^static:/) }.should_not be_nil
      end
    end
    
    it "should setup SSH keys" do
      @static.chdir do
        File.directory?(".ssh").should be_true
        File.file?(".ssh/authorized_keys").should be_true
      end
    end
    
    it "should write metadata" do
      @static.chdir do
        metadata = YAML::load_file("metadata.yml")
        metadata.should have_key(:user)
        metadata.should have_key(:group)
      end
    end
    
    it "should register vhost" do
      @static.chdir("..") do
        File.readlines("vhost.conf").grep(%r[/static]).should_not be_nil
      end
    end
    
    it "should write hooks" do
      @static.chdir do
        File.directory?("hooks").should be_true
        File.file?("hooks/project-create").should be_true
        File.file?("hooks/project-destroy").should be_true
      end
    end
    
    it "should setup privilegies" do
      pending "OS X doesn't have useradd command" do
        @static.chdir do
          owner(".").should eql("static")
          owner("metadata.yml").should eql("static")
        end
      end
    end
  end

  describe "#destroy" do
    before(:each) do
      quiet do
        @static = Static.create
        @static.destroy
      end
    end

    it "should destroy CONFIG.static" do
      File.directory?(@path).should be_false
    end
    
    it "should unregister vhost" do
      File.readlines(@static.superdir_vhost).grep(%r[/static]).should be_empty
    end
    
    it "should remove static user" do
      File.readlines("/etc/passwd").find { |line| line.match(/^static:/) }.should be_nil
    end
  end
end
