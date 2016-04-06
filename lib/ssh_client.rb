require 'ssh_client/version'

module SSHClient
  autoload 'Config', 'ssh_client/config'
  autoload 'ConfigItem', 'ssh_client/config_item'
  autoload 'Connection', 'ssh_client/connection'
  autoload 'CommandBuilder', 'ssh_client/command_builder'

  def self.configure(name = :default)
    yield config.build(name)
  end

  def self.config
    @config ||= Config.new
  end

  def self.connect(*args, &blk)
    @current_connection = Connection.new(*args, &blk)
  end

  def self.close
    @current_connection.close
  end
end
