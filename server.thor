require "thor-utils"

# TODO: config
class Server < Thor
  SERVER = "solaris"
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

  desc "project", "Run project.sh from server-tools. Run thor server:project --help for more informations"
  def project(*args)
    sudo "project.sh", *args
  end

  desc "backup", "Run backup.sh from server-tools. Example: thor server:backup /etc database"
  def backup(*args)
    sudo "backup.sh", *args
  end

  desc "probe", "Run http-probe.rb from server-tools"
  def probe
    run "http-probe.rb"
  end

  class Apache < Thor
    LOG = "/opt/coolstack/apache2/logs/error_log"
    desc "restart", "Restart apache"
    def restart
      Log.new.clear
      run "httpd -k restart"
    end

    class Log < Thor
      desc "clear", ""
      def clear
        run "cat > #{LOG} < /dev/null"
      end

      desc "show", ""
      def show
        run "cat #{LOG}"
      end
    end
  end
end
