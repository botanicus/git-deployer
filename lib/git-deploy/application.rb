# coding: utf-8

# represents a branch
class Application
  include FileUtils
  include MetadataMixin
  include ChdirMixin
  include HooksMixin
  attr_reader :root, :name
  def initialize(root)
    raise "Not Found" unless File.directory?(root)
    @root = root
    @name = File.basename(root)
    self.include_server_tasks
  end
  
  def include_server_tasks
    server_module = Object.full_const_get(self.metadata[:server].camel_case)
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
