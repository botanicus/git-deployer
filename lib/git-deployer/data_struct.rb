# coding: utf-8

require "fileutils"

class DataStruct
  class << self
    def create(path, options = Hash.new)
      # TODO: spec it
      superdir = File.dirname(path)
      raise "Not Found: #{superdir}" unless File.directory?(superdir)
      if File.directory?(path)
        raise "Application #{path} already exists!".red
      end
      mkdir path
      self.new(path).tap { |project| project.create(options) }
    end
  end
  
  attr_reader :root
  
  def name
    File.basename(self.root)
  end

  def initialize(root)
    raise "Not Found: #{root} (class #{self.class})" unless File.directory?(root)
    @root = root
    self.setup if self.respond_to?(:setup)
  end

  def setup_privilegies
    sh "chown -R #{self.user}:#{self.group} #{self.root}"
  end
  
  def setup_ssh_keys
    green ".ssh/authorized_keys ..."
    mkdir_p "#{self.root}/.ssh"
    File.open("#{self.root}/.ssh/authorized_keys", "w") do |file|
      file.puts(CONFIG.keys.join("\n"))
    end
  end
  
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
  
  # app.chdir("media/cache") do
  #   system("rm -rf *")
  # end
  def chdir(directory = nil, &block)
    path = directory ? File.join(self.root, directory) : self.root
    Dir.chdir(path, &block)
  end
  
  def metadata_file
    File.join(self.root, "metadata.yml")
  end

  attr_writer :metadata
  def metadata
    @metadata ||= YAML::load_file(self.metadata_file)
  end
  
  def write_init_metadata(metadata)
    Config.save("metadata.yml", metadata)
  end
  
  def config
    Config.load(File.join(self.root, "metadata.yml"))
  rescue Errno::ENOENT
    OpenStruct.new
  end
  
  # /webs/static => user static
  # /webs/rango/101ideas.cz => user 101ideas.cz
  def user
    File.basename(self.root)
  end
  
  def group
    self.config.group || CONFIG.group || "webservd"
  end
  
  def shell
    self.config.shell || CONFIG.shell || "/bin/bash"
  end
  
  # TODO: spec it
  def write_hooks(*hooks)
    # TODO: not symlink, just require the hook
    hooks.each do |hook|
      hook = File.join(self.framework_hooks_root, hook.to_s)
      if File.executable?(hook)
        sh "ln -sf #{hook} #{self.root}/repo.git/hooks/post-receive"
      else
        red "Can't find #{hook} hook! Please symlink it by hand."
      end
    end
  end
  
  def create_user
    sh "useradd -md #{self.root} -g #{self.group} -s #{self.shell} #{self.user}"
    password = Array.new(16) { rand(256) }.pack("C*").unpack("H*").first
    red "Please run passwd #{self.user} and set it to #{password}"
  end
  
  def destroy_user
    sh "userdel #{self.user}"
  end
  
  def superdir_vhost
    File.join(File.dirname(self.root), "vhost.conf")
  end
  
  # TODO: spec it
  def register_vhost
    green "Registering #{self.root}/vhosts to $vhost ..."
    sh "echo 'include #{self.root}/vhosts/*;' >> #{self.superdir_vhost}"
  end
  
  def remove_from_vhost
    green "Registering #{self.root}/vhosts to $vhost ..."
    lines  = File.readlines(self.superdir_vhost)
    regexp = Regexp.new(Regexp::quote(self.root))
    lines  = lines.select { |line| not line.match(regexp) }
    File.open(self.superdir_vhost, "w") do |file|
      file.puts(lines) 
    end
  end
end