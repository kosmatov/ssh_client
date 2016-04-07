require 'logger'

module SSHClient
  class ConfigItem
    DEFAULT_NAME = :default
    CMD = proc { |conf| "ssh #{conf.username}@#{conf.hostname}" }
    CMD_PASSWD = proc { |conf| "sshpass -p#{conf.password} #{CMD.call(conf)}" }
    READ_BLOCK_SIZE = 4096
    MAX_BUFFER_SIZE = 65536
    READ_TIMEOUT = 30

    attr_accessor :hostname, :username, :password
    attr_reader :name
    attr_writer :ssh_command, :read_block_size, :max_buffer_size, :read_timeout, :logger

    def initialize(name = nil)
      @name = name || DEFAULT_NAME
      @listeners = Hash.new
      add_listener(:logger) { |data| logger.info "<< #{data}" } if default?
    end

    def listeners
      @cached_listeners ||=
        default? ? @listeners : @listeners.merge(SSHClient.config.listeners)
    end

    def add_listener(name, &blk)
      @listeners[name] = blk
      @cached_listeners = nil
    end

    def remove_listener(name)
      @listeners.delete name
      @cached_listeners = nil
    end

    def host=(host)
      uri = URI.parse(host)
      @hostname, @username, @password = uri.host, uri.user, uri.password
    end

    def ssh_command
      command = @ssh_command || default_config_ssh_command
      command.respond_to?(:call) ? command.call(self) : command
    end

    def read_block_size
      @read_block_size || (default? ? READ_BLOCK_SIZE : SSHClient.config.read_block_size)
    end

    def max_buffer_size
      @max_buffer_size || (default? ? MAX_BUFFER_SIZE : SSHClient.config.max_buffer_size)
    end

    def read_timeout
      @read_timeout || (default? ? READ_TIMEOUT : SSHClient.config.read_timeout)
    end

    def default_ssh_command
      password ? CMD_PASSWD : CMD
    end

    def default_config_ssh_command
      default? ? default_ssh_command : SSHClient.config.ssh_command
    end

    def logger
      @logger || (default? ? Logger.new(STDOUT) : SSHClient.config.logger)
    end

    def default?
      name == DEFAULT_NAME
    end
  end
end
