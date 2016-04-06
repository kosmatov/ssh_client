require 'ssh_client/version'

module SSHClient
  autoload 'ConfigItem', 'ssh_client/config_item'
  autoload 'Connection', 'ssh_client/connection'
  autoload 'CommandBuilder', 'ssh_client/command_builder'

  def self.configure(name = nil)
    yield config(name)
  end

  def self.config(name = nil)
    @configurations ||= Hash.new
    @configurations[name] ||= ConfigItem.new name
  end

  def self.connect(*args, &blk)
    @current_connection = Connection.new(*args, &blk)
  end

  def self.close
    @current_connection.close
  end
end
