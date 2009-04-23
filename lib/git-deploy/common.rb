class YamlStruct
  attr_reader :properties
  def initialize(file, properties)
    @file = file
    @properties = properties
  end
  
  def merge(another)
    OpenStruct.new(@properties.merge(another.properties))
  end
  
  def to_s
    @properties.map do |key, value|
      "#{key}: #{value}"
    end
  end
  
  def method_missing(method, value = nil)
    if method.match(/^(.+)=$/) && not value.nil?
      @properties[$1] = value
      File.open(@file, "w") do |file|
        file.puts(@properties.to_yaml)
      end
    else
      @properties[method]
    end
  end
end

class Object
  def global
    file = File.join(File.dirname(__FILE__), "configuration.yml")
    YamlStruct.new("deploy_config.yml", YAML::load_file(file))
  end
  
  # local.branch = "master"
  def local
    file = File.join("deploy_config.yml")
    YamlStruct.new("deploy_config.yml", YAML::load_file(file))
  end

  # config.branch
  # config.python
  def config
    global.merge(local)
  end

  def command(command, *arguments)
    arguments.map! { |argument| "'#{argument}'" }
    system "#{command} #{arguments.join(" ")}"
  end

  def python(*arguments)
    command("#{config.python}", *arguments)
  end
  
  def ruby(*arguments)
    command("#{config.ruby}", *arguments)
  end
  
  def touch(*files)
    command("touch", *files)
  end
  
  def mkdir(directories)
    system("mkdir #{directories.join(" ")} 2> /dev/null")
  end
  
  def rm(*files)
    system("rm #{files.join(" ")} 2> /dev/null")
  end
  
  def git(*arguments)
    command("git", *arguments)
  end
  
  def restart_server
    info "Restarting Apache ..."
    httpd -k restart
  end
  
  def restart_application
    info "Restarting application ..."
    touch "tmp/restart.txt"
  end
  
  # run_hook "update"
  def run_hook(type)
    run_global_hook || run_local_hook
  end
  
  def run_global_hook(type)
    hook = config["global_#{type}_hook"]
    if File.executable?(hook)
      info "Running global #{type} hook ..."
      run hook
      return true
    else
      return false
    end
  end
  
  # run_local_hook "update"
  def run_local_hook(type)
    hook = config["local_#{type}_hook"]
    if File.executable?(hook)
      info "Running local #{type} hook ..."
      run hook
      return true
    else
      return false
    end
  end
  
  alias_method :run, :`
  
  def note(message)
    puts message.blue.bold
  end
  
  def info(message)
    puts message.green.bold
  end
end

__END__
debug() {
  [ "$DEBUG" = "yes" ] && echo $1
  [ "$#" != 0 ] && $*
}
info() # gray bold
note()  { echo -e "\e[1;34m$*\e[0m"; } # blue
success() { echo -e "\e[1;32m$*\e[0m"; }
warning() # yellow
error() { echo -e "\e[1;31m$*\e[0m"; }
fatal() { echo -e "\e[1;31m$*\e[0m"; exit 1; }