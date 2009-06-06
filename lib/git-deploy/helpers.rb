# coding: utf-8

module Kernel
  def sh(command)
    puts "> #{command}"
    # puts %x[#{command}]
    system(command) #|| raise("Command failed".red)
  end
  
  def red(string)
    puts string.red
  end
  
  def green(string)
    puts string.green
  end
  
  def blue(string)
    puts string.blue
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
    "httpd -k restart"
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
end
