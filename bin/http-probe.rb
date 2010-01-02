#!/usr/bin/env ruby
# coding: utf-8

# TODO: base = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
begin
  require "yaml"
  require "term/ansicolor"
rescue LoadError
  STDERR.puts("Run gem install term-ansicolor first.")
end

String.send(:include, Term::ANSIColor)

class Curl
  def initialize(url)
    @output = %x[/usr/bin/curl -A 'HttpProbe/1.0' -I #{url} -s].split("\n")
  end

  def status
    @output.first.split(" ")[1].to_i
  end
end

class Checker
  def initialize(url, site_config, config)
    @url    = url
    @curl   = Curl.new(url)
    @config = config
    @site_config = site_config
  end

  def notifiers
    @site_config.map do |notifier, addresses|
      options = @config[notifier] || Hash.new
      const_name = "#{notifier.capitalize}Notifier"
      notifier_klass = Object.const_get(const_name)
      notifier = notifier_klass.new(@url, options, *addresses)
      notifier
    end
  end

  def run
    self.log
    unless succeed?
      notifiers.each do |notifier|
        if notifier.run(@curl.status)
          STDERR.puts("#{notifier.class.to_s.green.bold} suceed")
        end
      end
    end
  end

  def succeed?
    @curl.status == 200
  end

  def log
    status = succeed? ? "OK".green : "FAILED".red
    STDERR.puts("#{status.bold} ... #@url")
  end
end

class Notifier
  attr_reader :url, :status, :addresses
  def initialize(url, config, *addresses)
    @url       = url
    @config    = config
    @addresses = addresses
    self.setup if self.respond_to?(:setup)
  end

  def run(status)
    @status = status
    addresses.all? do |address|
      unless (status = self.send(address))
        STDERR.puts("#{self.class.to_s.red.bold}: sending message to #{address} failed")
      end
      status
    end
  end

  def subject
    "HTTP Probe: #@url returns status #@status"
  end

  def body
    "HTTP probe for response #@status on #@url FAILED"
  end

  def send
    raise "This method must be redefined in subclasses!"
  end
end

class MailNotifier < Notifier
  def send(address)
    system(%[/usr/gnu/bin/echo "#{self.body}" | /usr/bin/mailx -s "#{subject}" -r "HttpProbe" #{address}])
  end
end

class XmppNotifier < Notifier
  def setup
    require "xmpp4r"
  rescue LoadError
    STDERR.puts("Run gem install xmpp4r if you like to use xmpp notification.".red.bold)
  end

  def client
    jid = Jabber::JID::new("#{@config.username}/notifier")
    client = Jabber::Client::new(jid)
    client.connect
    client.auth(@config.password)
    return client
  end

  def message(to)
    Jabber::Message::new(to, body).set_type(:normal).set_id('1').set_subject(subject)
  end

  def send(address)
    client.send(message(address))
    return true # client.send returns nil
  rescue Exception => exception
    STDERR.puts(exception.message)
    return false
  end
end

config = OpenStruct.new(YAML::load_file("/etc/http-probe.yml"))

config.sites.each do |url, setup|
  setup = Hash.new if setup.nil?
  if (default = config.default)
    setup = default.merge(setup)
  end
  checker = Checker.new(url, setup, config.setup)
  checker.run
end

__END__
setup:
  xmpp:
    username: botanicus@njs.netlab.cz
    password: mypassword
default:
  xmpp: [+420725590595@sms.netlab.cz, botanicus@njs.netlab.cz]
  mail: knava.bestvinensis@gmail.com
sites:
  101ideas.cz/cs/:
    # xmpp:
    # mail:
  botablog.cz
