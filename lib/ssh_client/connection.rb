require 'open3'

module SSHClient
  class Connection
    attr_reader :config, :logger, :stdin, :stdout, :ctrl_thrd

    def initialize(config_name = nil, hostname: nil, username: nil, password: nil, &blk)
      build_config hostname, username, password if hostname
      @config ||= SSHClient.config(config_name)

      open
      batch_exec(&blk) if block_given?

      ObjectSpace.define_finalizer(self) { close }
    end

    def build_config(hostname, username, password)
      @config ||= SSHClient.configure(hostname) do |conf|
        conf.hostname = hostname
        conf.username = username
        conf.password = password
      end
    end

    def add_listener(name, &blk)
      config.add_listener(name, &blk)
    end

    def remove_listener(name)
      config.remove_listener name
    end

    def exec(command)
      config.logger.info ">> #{command}"
      stdin.puts command
    end

    def batch_exec(&blk)
      CommandBuilder.new(&blk).to_a.map { |cmd| exec cmd }
      close
    end

    def open
      @stdin, @stdout, @ctrl_thrd = Open3.popen2e config.ssh_command
      @read_thrd = Thread.new { read_loop }
    end

    def close
      stdin.close

      @read_thrd.thread_variable_set(:terminate, true)
      loop { return stdout.close unless @read_thrd.alive? }
    end

    private

    def wait_stdout
      IO.select [stdout], nil, nil, config.read_timeout
    end

    def handle_listeners(data)
      config.listeners.each { |_, l| l.call data }
    end

    def can_read?
      return stdout.ready? && !stdout.eof? if stdout.respond_to?(:ready?)
      ready = !@wait
      @wait = false
      ready
    end

    def read_loop
      loop do
        wait_stdout
        if can_read?
          handle_listeners stdout.read_nonblock(config.read_block_size)
        elsif Thread.current.thread_variable_get(:terminate)
          config.logger.debug 'Exit from read thread'
          Thread.exit
        end
      end
    rescue => e
      config.logger.debug e.inspect
      @wait = true
      retry
    end

  end
end
