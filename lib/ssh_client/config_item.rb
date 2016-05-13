require 'logger'

module SSHClient
  class ConfigItem
    DEFAULT_NAME = :default
    READ_TIMEOUT = 0.5

    attr_accessor :hostname, :username, :password
    attr_reader :name
    attr_writer :read_timeout, :logger, :transport, :debug

    def initialize(name = nil)
      @name = name || DEFAULT_NAME
      @listeners = { stdout: {}, stderr: {} }

      add_listener(:logger) { |data| logger.info "<< #{data}" } if default?
    end

    def listeners
      @cached_listeners ||= if default?
        @listeners
      else
        @listeners.each { |k, l| l.merge SSHClient.config.listeners[k] }
      end
    end

    def add_listener(name, io_type = nil, &blk)
      Array(io_type || @listeners.keys).each do |k|
        @listeners[k][name] = blk
      end
      @cached_listeners = nil
    end

    def remove_listener(name, io_type = nil)
      Array(io_type || @listeners.keys).each do |k|
        @listeners[k].delete name
      end
      @cached_listeners = nil
    end

    def read_timeout
      @read_timeout || (default? ? READ_TIMEOUT : SSHClient.config.read_timeout)
    end

    def transport
      transport_klass.new self
    end

    def transport_klass
      @transport || (default? ? Transport::NetSSH : SSHClient.config.transport_klass)
    end

    def raise_on_errors=(value)
      if value
        add_listener(:raise_on_errors, :stderr) do |data|
          Thread.main.raise CommandExitWithError if data
        end
      else
        remove_listener(:raise_on_errors, :stderr)
      end
    end

    def logger
      @logger || (default? ? Logger.new(STDOUT) : SSHClient.config.logger)
    end

    def debug?
      @debug || (default? ? false : SSHClient.config.debug?)
    end

    def default?
      name == DEFAULT_NAME
    end
  end
end
