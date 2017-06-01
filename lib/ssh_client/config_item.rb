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
      @listeners = { stdout: Set.new, stderr: Set.new }

      add_listener { |data| logger.info "<< #{data}" } if default?
    end

    def listeners
      @cached_listeners ||= if default?
        @listeners
      else
        @listeners.each { |k, l| l += SSHClient.config.listeners[k] }
      end
    end

    def add_listener(*args, &blk)
      Array(args || @listeners.keys).each do |k|
        @listeners[k] << blk
      end
      @cached_listeners = nil
      blk
    end

    def remove_listener(listener, io_type = nil)
      Array(io_type || @listeners.keys).each do |k|
        @listeners[k].delete listener
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
        @errors_listener = add_listener(:stderr) do |data|
          Thread.main.raise CommandExitWithError.new(data) if data
        end
      else
        remove_listener(@errors_listener, :stderr) if @errors_listener
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
