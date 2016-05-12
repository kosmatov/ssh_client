require 'forwardable'

module SSHClient
  class Connection
    extend Forwardable
    def_delegators :transport, :open, :close, :closed?

    attr_reader :config, :transport

    def initialize(config_name = nil, hostname: nil, username: nil, password: nil, &blk)
      build_config hostname, username, password if hostname
      @config ||= SSHClient.config(config_name)
      @transport = config.transport

      open
      batch_exec(&blk) if block_given?

      ObjectSpace.define_finalizer(self) { transport.close }
    end

    def build_config(hostname, username, password)
      @config ||= SSHClient.configure(hostname) do |conf|
        conf.hostname = hostname
        conf.username = username
        conf.password = password
      end
    end

    def add_listener(name, io_type = nil, &blk)
      config.add_listener(name, io_type, &blk)
    end

    def remove_listener(name, io_type = nil)
      config.remove_listener name, io_type
    end

    def exec(command)
      transport.send_message command
    end

    def exec!(command = nil, &blk)
      buffer = String.new
      add_listener(:buffer, :stdout) { |data| buffer << data }
      block_given? ? batch_exec(&blk) : exec(command)
      remove_listener(:buffer, :stdout)
      buffer
    end

    def batch_exec(&blk)
      exec CommandBuilder.new(&blk).to_a.join("\n")
    end

  end
end
