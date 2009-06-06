# coding: utf-8

require File.join(Dir.pwd, "spec", "spec_helper")
require "git-deploy/project"

describe Project do
  before(:each) do
    @path = File.join(STUBS, "webs", "static", "test")
    @new  = File.join(STUBS, "webs", "static", "new")
    @project = Project.new(@path)
  end
  
  after(:each) do
    FileUtils.rm_rf(@new) if File.directory?(@new)
  end
  
  describe ".all" do
    it "should returns array with projects" do
      Project.all.should be_kind_of(Array)
      Project.all.each { |project| project.should be_kind_of(Project) }
    end
  end
  
  describe ".create" do
    it "should raise exception when superdirectory doesn't exist" do
      -> { quiet { Project.create("/a/b/c/d/e/f/g") } }.should raise_error
    end
    
    it "should raise exception if given directory already exist" do
      -> { quiet { Project.create(Project.all.first.root, Hash.new) } }.should raise_error
    end
    
    it "should create directory structure" do
      project = quiet { Project.create(@new, Hash.new) }
      project.chdir do
        File.directory?("vhosts").should be_true
        File.directory?("repo.git").should be_true
      end
    end
    
    it "should init git directory" do
      project = quiet { Project.create(@new, Hash.new) }
      project.chdir("repo.git") do
        File.directory?("branches").should be_true
        File.directory?("hooks").should be_true
      end
    end
    
    it "should symlink update and clone hooks" do
      project = quiet { Project.create(@new, Hash.new) }
      project.chdir("repo.git/hooks") do
        File.executable?("clone")
        File.executable?("update")
      end
    end
    
    it "should write ssh keys" do
      project = quiet { Project.create(@new, Hash.new) }
      project.chdir(".ssh") do
        File.file?("authorized_keys").should be_true
        File.zero?("authorized_keys").should be_false
      end
    end
    
    it "should write basic metadata" do
      project = quiet { Project.create(@new, Hash.new) }
      project.metadata.should have_key(:interpret)
      project.metadata.should have_key(:port)
      project.metadata.should have_key(:server)
    end
    
    it "should write extra metadata" do
      project = quiet { Project.create(@new, database: "sqlite3") }
      project.metadata.should have_key(:interpret)
      project.metadata.should have_key(:port)
      project.metadata.should have_key(:server)
      project.metadata.should have_key(:database)
    end
  end

  describe "#initialize" do
    it "should raise exception if path doesn't exists" do
      -> { Project.new("/a/b/c/d/e/f/g") }.should raise_error
    end
    
    it "should not raise exception if path exists" do
      -> { Project.new(@path) }.should_not raise_error
    end
  end

  describe "#config" do
  end
end
