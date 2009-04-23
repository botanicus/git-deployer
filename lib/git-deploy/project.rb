# coding: utf-8

class Project
  include FileUtils
  include MetadataMixin
  include ChdirMixin
  include HooksMixin
  # array of full paths
  def self.all
    YAML::load_file(Config.apps)
  end
  
  def self.create(path, options)
    raise "Not Found" unless File.directory?(File.dirname(path))
    if File.directory?(path)
      abort "Application #{path} already exists!".red
    end
    project = Project.new(path)
    project.create(options)
  end
  
  def destroy(options)
    @options = options
    rm_rf(self.root)
    self.remove_from_vhost
    self.remove_backups
    self.hook(:destroy)
  end
  
  def remove_from_vhost
    # green "Removing  from $vhost ..."
    # sh "grep -v include #{@project.root}/vhosts/\* $vhost > $vhost.new"
    # mv "$vhost.new" $vhost
  end
  
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
  def setup_privilegies
    sh "chown -R #{@user}:#{@group} #{self.root}"
  end
  
  def create_vhost
    green "Registering #{self.root}/vhosts to $vhost ..."
    sh "echo include #{self.root}/vhosts/*; >> #{@vhost}"
  end

  def create_directories
    mkdir_p("vhosts")
    mkdir_p("repo.git")
  end

  def init_repo
    green "Creating git repo"
    Dir.chdir("repo.git") do
      sh("git init --bare")
    end
  end

  def symlink_hooks
    if File.executable?("/webs/support/git-deploy/post-receive")
      sh "ln -s /webs/support/git-deploy/post-receive #{self.root}/repo.git/hooks/post-receive"
    else
      red "Can't find /webs/support/git-deploy/post-receive hook! Please symlink it by hand."
    end
  end

  def setup_ssh_keys
    green ".ssh/authorized_keys ..."
    mkdir_p "#{self.root}/.ssh"
    File.open("#{self.root}/.ssh/authorized_keys", "w") do |file|
      file.puts(Config.keys.join("\n"))
    end
  end

  def write_metadata
    @project = ::Project.new(self.root)
    @project.metadata = @metadata
    @project.save_metadata
  end

  def register_application
    paths = YAML::load_file("/webs/apps.yml")
    paths.push(self.root)
    File.open("/webs/apps.yml", "w") do |file|
      file.puts(paths.to_yaml)
    end
  end

  def create_user
    sh "useradd -md #{self.root} -g #{@group} -s /usr/bin/zsh #{@user}"
    password = Array.new(16) { rand(256) }.pack("C*").unpack("H*").first
    red "Please run passwd #{@user} and set it to #{password}"
  end
  
  def create(metadata = Hash.new)
    @user  = File.basename(path)
    @group = metadata[:group] || "webservd"
    @vhost = File.join(File.dirname(self.root), "vhost.conf")
    @metadata = metadata.merge(group: Config.group)
    Dir.chdir(path) do
      self.create_directories
      self.init_repo
      self.symlink_hooks
      self.setup_ssh_keys
      self.create_vhost
      self.write_metadata
      self.create_user
      self.setup_privilegies
      self.run_hook(:create)
      blue "git remote add origin $1@77.93.194.146:$2/repo.git"
    end
  end
  
  attr_reader :root, :name
  def initialize(root)
    raise "Not Found" unless File.directory?(root)
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
  
  def branches
    files = Dir["#{self.root}/*"]
    dirs  = files.select { |file| File.directory?(file) }
    names = dirs - ["vhosts"]
    return names.map { |name| Application.new(name) }
  end
  alias_method :applications, :branches
  
  def branch(name)
    self.branches.find { |branch| branch.name == name }
  end
  alias_method :application, :branch
  
  def master
    self.branch(:master)
  end
  
  def alpha
    self.branch(:alpha)
  end
  
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
    run "#{config.root}/../hooks/clone"
    hook(config.global_clone_hook)
    run_hook "clone"
    
    # 101ideas.cz vs. dytrych
    if branch == "master" && not project.match(/\./)
      config.env = "production"
    else
      config.env = "development"
    end

    # vhosts
    unless File.exist?(config.vhost)
      info "Creating vhost file ..."
      mkdir "-p", File.dirname(config.vhost)
      run "vhost-gen.rb #{config.root} #{config.branch} > #{config.vhost}"
      restart_server
    end
  end
end
