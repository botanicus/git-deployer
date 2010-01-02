class Nginx < Thor
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
