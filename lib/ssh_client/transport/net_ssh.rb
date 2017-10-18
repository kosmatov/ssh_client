require 'net/ssh'
require_relative 'base'

module SSHClient
  module Transport
    class NetSSH < Base
      attr_reader :ssh

      def send_message(command, close: false)
        open if closed?
        last_read_time = nil

        ssh.open_channel do |channel|
          channel.send_channel_request 'shell' do |ch, success|
            channel.on_data do |c, data|
              handle_listeners :stdout, data
              last_read_time = Time.now
            end

            channel.on_extended_data do |c, type, data|
              handle_listeners :stderr, data
            end

            channel.send_data "#{command}\n"
          end
        end

        ssh.loop(0.1) do
          read_timeout = Time.now - last_read_time if last_read_time
          ssh.busy? && (!read_timeout || read_timeout < config.read_timeout)
        end

        ssh.close if close
      end

      def open
        @ssh = Net::SSH.start config.hostname, config.username,
          password: config.password, logger: config.debug? && config.logger
      end

      def closed?
        ssh.nil? || ssh.closed?
      end

      def close
        @ssh.close if !closed?
      end
    end
  end
end
