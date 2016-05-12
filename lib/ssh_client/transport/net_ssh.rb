require 'net/ssh'
require_relative 'base'

module SSHClient
  module Transport
    class NetSSH < Base
      attr_reader :ssh

      def send_message(command, wait: false)
        open if closed?
        time = Time.now

        ssh.open_channel do |channel|
          channel.send_channel_request 'shell' do |ch, success|
            channel.on_data do |c, data|
              handle_listeners :stdout, data
              time = Time.now
            end

            channel.on_extended_data do |c, data|
              handle_listeners :stderr, data
            end

            channel.send_data "#{command}\n"
            channel.eof!
          end
        end

        ssh.loop(0.1) do
          ssh.busy? && Time.now - time < config.read_timeout
        end
      end

      def open
        @ssh = Net::SSH.start config.hostname, config.username,
          password: config.password, logger: config.logger
      end

      def closed?
        ssh.nil? || ssh.closed?
      end

      def close
        @ssh.close
      end
    end
  end
end
