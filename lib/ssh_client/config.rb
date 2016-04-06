module SSHClient
  class Config
    attr_reader :configurations

    def initialize
      @configurations = {}
    end

    def build(name)
      configurations[name] = ConfigItem.new name
    end

    def method_missing(*args, &blk)
      configurations[ConfigItem::DEFAULT_NAME].public_send(*args, &blk)
    end
  end
end
