# coding: utf-8

require "fileutils"
require "git-deployer/data_struct"

# === Create === #
# - mkdir /webs/rango/101ideas.cz
# - create user 101ideas.cz
# - setup SSH keys
# - write metadata
# - register vhost
# - symlink hooks
# - chown -R 101ideas.cz:webservd

# === Destroy === #
# - rm -rf /webs/rango/101ideas.cz
# - unregister vhost
# - userdel 101ideas.cz
# - remove backups

class Project < DataStruct
  # array of projects
  def self.all
    paths = YAML::load_file(CONFIG.projects)
    paths.map { |path| Project.new(path) }
  rescue Errno::ENOENT
    raise "File #{CONFIG.projects} doesn't exist"
  end
  
  # TODO: spec it
  def destroy(options)
    @options = options
    rm_rf(self.root)
    self.remove_from_vhost
    self.remove_backups
    self.hook(:destroy)
  end
  
  # TODO: spec it
  def remove_from_vhost
    # green "Removing  from $vhost ..."
    # sh "grep -v include #{@project.root}/vhosts/\* $vhost > $vhost.new"
    # mv "$vhost.new" $vhost
  end
  
  # TODO: spec it
  def remove_backups
    # project data
    green "Removing sources"
    # rm -rf $project_root
    if @options[:force]
      # green "Removing data ..."
      # rm $web_root/database/$basename.db
      # rm $web_root/uploads/$basename 2> /dev/null
    end
  end
  
  # create
  # TODO: spec it
  def register_vhost
    green "Registering #{self.root}/vhosts to $vhost ..."
    sh "echo 'include #{self.root}/vhosts/*;' >> #{@vhost}"
  end

  # TODO: spec it
  def create_directories
    mkdir_p("vhosts")
    mkdir_p("repo.git")
  end

  # TODO: spec it
  def init_repo
    green "Creating git repo"
    Dir.chdir("repo.git") do
      sh("git init --bare")
    end
  end
  
  # TODO: spec it
  def symlink_hooks(*hooks)
    hooks.each do |hook|
      hook = File.join(File.dirname(__FILE__), "hooks", self.fragment, "hooks", hook.to_s)
      if File.executable?(hook)
        sh "ln -sf #{hook} #{self.root}/repo.git/hooks/post-receive"
      else
        red "Can't find #{hook} hook! Please symlink it by hand."
      end
    end
  end

  def get_ports
    project = self.class.all.last
    if project
      last = project.self.config.ports.sort.last
      return ((last + 1)..(last + 6))
    else
      return (4000..4005)
    end
  end

  # TODO: spec it
  def write_init_metadata
    # - ruby (ruby) / python (python 2.6) => interpret
    # - ports (4000, 4001, 4002) => vezme se posledni projekt v projects.yml a vezme se jeho last port
    @config = Config.save("metadata.yml", ports: self.get_ports.to_a, server: @type.config.server, interpret: @type.config.server)
  end

  # TODO: spec it
  def register_application
    paths = YAML::load_file(CONFIG.projects)
    paths.push(self.root)
    File.open(CONFIG.projects, "w") do |file|
      file.puts(paths.to_yaml)
    end
  end

  def create_user
    sh "useradd -md #{self.root} -g #{CONFIG.group} -s #{CONFIG.shell} #{@user}"
    password = Array.new(16) { rand(256) }.pack("C*").unpack("H*").first
    red "Please run passwd #{@user} and set it to #{password}"
  end
  
  # TODO: spec it
  def create(metadata = Hash.new)
    @user  = File.basename(self.root)
    @group = self.config.group || "webservd"
    @vhost = File.join(File.dirname(self.root), "vhost.conf")
    @metadata = metadata.merge(group: CONFIG.group)
    Dir.chdir(self.root) do
      self.create_directories
      self.init_repo
      self.symlink_hooks(:clone, :update)
      self.setup_ssh_keys
      self.register_vhost
      self.write_init_metadata
      self.create_user
      self.setup_privilegies
      self.run_hook(:create)
      blue "git remote add origin $1@77.93.194.146:$2/repo.git"
    end
    return self
  end
  
  # TODO: spec it
  attr_reader :root, :name
  def initialize(root)
    raise "Not Found: #{root}" unless File.directory?(root)
    @root = root
    @name = File.basename(root)
  end
  
  def start
    self.applications.each(&:start)
  end
  
  def start
    self.applications.each(&:stop)
  end
  
  def start
    self.applications.each(&:restart)
  end
  
  # TODO: spec it
  def branches
    files = Dir["#{self.root}/*"]
    dirs  = files.select { |file| File.directory?(file) }
    names = dirs - ["vhosts"]
    return names.map { |name| Application.new(name) }
  end
  alias_method :applications, :branches
  
  # TODO: spec it
  def branch(name)
    self.branches.find { |branch| branch.name == name }
  end
  alias_method :application, :branch
  
  # TODO: spec it
  def master
    self.branch(:master)
  end
  
  # TODO: spec it
  def alpha
    self.branch(:alpha)
  end
  
  # TODO: spec it
  def create_branch(name)
    info "Cloning #{config.branch} ..."
    git "clone repo.git #{config.branch}"
    Dir.chdir(config.branch)
    git "checkout #{config.branch}"
    # freeze global configuration and write project-specific one
    # configurace globalni se kopiruje do project (project create), lokalni je v branch, merguje se to online
    File.open("deploy_config.yml", "w") do |file|
      file.puts(config.marshal_dump.to_yaml)
    end
    mkdir "log"
    # global hook
    # /webs/static/hooks/update
    sh "#{config.root}/../hooks/clone"
    hook(config.global_clone_hook)
    run_hook "clone"
    
    # 101ideas.cz vs. dytrych
    # if branch == "master" && not project.match(/\./)
    #   config.env = "production"
    # else
    #   config.env = "development"
    # end

    # vhosts
    unless File.exist?(config.vhost)
      info "Creating vhost file ..."
      mkdir "-p", File.dirname(config.vhost)
      sh "vhost-gen.rb #{config.root} #{config.branch} > #{config.vhost}"
      restart_server
    end
  end
end
