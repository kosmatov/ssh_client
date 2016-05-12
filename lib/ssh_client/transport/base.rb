module SSHClient
  module Transport
    class Base
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def handle_listeners(io_type, data)
        config.listeners[io_type].each { |_, l| l.call data }
      end
    end
  end
end
