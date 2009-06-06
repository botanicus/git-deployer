# coding: utf-8

require "fileutils"
require "git-deploy/data_struct"

# === Create === #
# - git clone repo.git master
# - write metadata
# - generate vhost
# - register vhost
# - symlink hooks

# === Destroy === #
# - rm -rf master
# - remove vhost
# - unregister vhost

# represents a branch
class Application < DataStruct
  attr_accessor :project
  def setup
    server_module = Object.full_const_get(self.config.server.camel_case)
    self.class.send(:include, server_module)
  end
  
  def restart
    self.stop
    self.start
  end
  
  def update
    Dir.chdir(config.branch)
    info "Updating sources ..."
    git "reset --hard"
    git "pull" # TODO: rebase will be better
    # HOOKS
    # Run first found hook
    run_hook "update"
  end
end
