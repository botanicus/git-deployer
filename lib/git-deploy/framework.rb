# coding: utf-8

require "fileutils"
require "git-deploy/data_struct"

# rango/metadata.yml
# :ruby: ruby1.9

# django/metadata.yml
# :python: python2.6

# === Create === #
# - mkdir /webs/apps/rango (data_struct)
# - write metadata
# - register vhost
# - symlink hooks

# === Destroy === #
# - rm -rf /webs/static
# - unregister vhost
# - remove backups

class Framework < DataStruct
  def self.all
    Dir["/webs/apps/*"].map { |directory| Framework.new(directory) }
  end
  
  def framework_hooks_root
    File.join(File.dirname(__FILE__), "hooks", "apps", File.basename(self.root), "hooks")
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
  def create_directories
    mkdir_p("vhosts")
    mkdir_p("repo.git")
  end
  
  def remove_backups
    run "rm -rf /backups/static"
  end

  def write_init_metadata
    # - ruby (ruby1.9) / python (python 2.6) => interpret
    # - ports (4000, 4001, 4002) => vezme se posledni projekt v projects.yml a vezme se jeho last port
    @config = Config.save("metadata.yml", ports: self.get_ports.to_a, server: @type.config.server, interpret: @type.config.server)
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
  def create_project(name)
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
  
  # TODO: spec it
  def create_project(name)
    path = File.join(self.root, name)
    Project.create(path)
  end
end
