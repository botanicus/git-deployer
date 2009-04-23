require "thor-utils"

class Server < Thor
  def initialize
    @config = ...
  end

  def ssh(command)
    puts command.blue
    puts %x(ssh #{SERVER} 'zsh <<EOF\nsource /etc/profile\n#{command}\nEOF')
  end

  def run(command, *args)
    ssh "#{command} #{args.join(" ")}"
  end

  def sudo(command, *args)
    # TODO became root
    ssh "#{command} #{args.join(" ")}"
  end

  desc "project", "Run project.sh from git-deploy. Run thor server:project --help for more informations"
  def project(*args)
    sudo "project.sh", *args
  end

  desc "backup", "Run backup.sh from git-deploy. Example: thor server:backup /etc database"
  def backup(*args)
    sudo "backup.sh", *args
  end

  desc "probe", "Run http-probe.rb from git-deploy"
  def probe
    run "http-probe.rb"
  end
end
