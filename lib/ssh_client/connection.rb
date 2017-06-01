require 'forwardable'

module SSHClient
  class Connection
    extend Forwardable
    def_delegators :transport, :open, :close, :closed?
    def_delegators :config, :add_listener, :remove_listener

    attr_reader :config, :transport

    def initialize(config_name = nil, hostname: nil, username: nil, password: nil, logger: nil, &blk)
      build_config hostname, username, password, logger: logger if hostname
      @config ||= SSHClient.config config_name
      @transport = config.transport

      open
      batch_exec(&blk) if block_given?

      ObjectSpace.define_finalizer(self) { transport.close }
    end

    def build_config(hostname, username, password, logger: nil)
      @config ||= SSHClient.configure(hostname) do |conf|
        conf.hostname = hostname
        conf.username = username
        conf.password = password
        conf.logger = logger
      end
    end

    def exec(command, close: false)
      config.logger.info ">> #{command}"
      transport.send_message command, close: close
    end

    def exec!(command = nil, &blk)
      buffer = String.new
      listener = add_listener(:stdout) { |data| buffer << data }
      block_given? ? batch_exec(&blk) : exec(command, close: true)
      remove_listener listener
      buffer
    end

    def batch_exec(&blk)
      exec CommandBuilder.new(&blk).to_a.join("\n"), close: true
    end

  end
end
