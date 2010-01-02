# coding: utf-8

require "git-deployer/data_struct"

# main config:
# :static: /webs/static

# static/metadata.yml:
# :user: static
# :group: webservd

class Static < DataStruct
  def self.create
    super(CONFIG.static)
  end
  
  def initialize(root = CONFIG.static)
    @root = root
  end
  
  def framework_hooks_root
    File.join(File.dirname(__FILE__), "hooks", "static", "hooks")
  end
  
  # === Create === #
  # - mkdir /webs/static (data_struct)
  # - create user static
  # - setup SSH keys
  # - write metadata
  # - register vhost
  # - write hooks
  # - chown -R static:webservd
  def create(metadata = Hash.new)
    Dir.chdir(self.root) do
      self.create_user
      self.setup_ssh_keys
      metadata = {group: self.group, user: self.user}.merge(metadata)
      self.write_init_metadata(metadata)
      self.register_vhost
      self.write_hooks("project-create", "project-destroy")
      self.setup_privilegies
    end
  end
  
  # === Destroy === #
  # - rm -rf /webs/static
  # - unregister vhost
  # - userdel static
  def destroy(options = Hash.new)
    rm_rf(self.root)
    self.destroy_user
    self.remove_from_vhost
  end
  
  # TODO: spec it
  def create_project(name)
    path = File.join(self.root, name)
    Project.create(path)
  end
end
