# coding: utf-8

module Servers
  module Thin
    def start
      config = File.join(self.root, "config", "thin.yml")
      if File.exist?(config)
        system "thin start -C #{config}"
      else
        system "thin start -p #{self.ports.first} -P tmp/pids/thin.pid"
      end
    end

    def stop
    end
  end
  
  module ThinCluster
    def start
      system "thin start -s3 -p #{self.ports.first} -P tmp/pids/thin.pid"
    end

    def stop
    end
  end
  
  module Django
    def start
    end

    def stop
    end
  end
end
