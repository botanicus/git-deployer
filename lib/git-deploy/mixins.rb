# coding: utf-8

require "fileutils"

module MetadataMixin
  def metadata_file
    File.join(self.root, "metadata.yml")
  end

  attr_writer :metadata
  def metadata
    @metadata ||= YAML::load_file(self.metadata_file)
  end
  
  def save_metadata
    File.open(self.metadata_file, "w") do |file|
      file.puts(@metadata.to_yaml)
    end
  end
end

module ChdirMixin
  # app.chdir("media/cache") do
  #   system("rm -rf *")
  # end
  def chdir(directory, &block)
    Dir.chdir(path, &block)
  end
end

module HooksMixin
  def hook(name)
    File.executable?(File.join(self.hooks_root, name))
  end
  
  def run_hook(name, options = Hash.new)
    hook = self.hook(name)
    if File.executable?(hook)
      # Running hook name
      sh "#{hook} #{options}"
    else
      # Haven't found hook
    end
  end
end
