require 'logger'

module SSHClient
  class ConfigItem
    DEFAULT_NAME = :default
    CMD = proc { |conf| "ssh #{conf.username}@#{conf.hostname}" }
    CMD_PASSWD = proc { |conf| "sshpass -p#{conf.password} #{CMD.call(conf)}" }
    READ_BLOCK_SIZE = 4096
    READ_TIMEOUT = 10

    attr_accessor :hostname, :username, :password
    attr_reader :name
    attr_writer :ssh_command, :read_block_size, :max_buffer_size, :read_timeout, :logger, :transport

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

    def ssh_command(conf = nil)
      command = @ssh_command || default_config_ssh_command(conf || self)
      command.respond_to?(:call) ? command.call(conf || self) : command
    end

    def read_block_size
      @read_block_size || (default? ? READ_BLOCK_SIZE : SSHClient.config.read_block_size)
    end

    def read_timeout
      @read_timeout || (default? ? READ_TIMEOUT : SSHClient.config.read_timeout)
    end

    def transport
      (@transport || (default? ? Transport::NetSSH : SSHClient.config.transport)).new self
    end

    def default_ssh_command(conf)
      conf.password ? CMD_PASSWD : CMD
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

    def default_config_ssh_command(conf)
      default? ? default_ssh_command(conf) : SSHClient.config.ssh_command(self)
    end

    def logger
      @logger || (default? ? Logger.new(STDOUT) : SSHClient.config.logger)
    end

    def default?
      name == DEFAULT_NAME
    end
  end
end
