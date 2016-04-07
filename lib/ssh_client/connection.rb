require 'open3'

module SSHClient
  class Connection
    attr_reader :config, :logger, :stdin, :stdout, :stderr, :ctrl_thrd

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

    def add_listener(name, io_type = nil, &blk)
      config.add_listener(name, io_type, &blk)
    end

    def remove_listener(name, io_type = nil)
      config.remove_listener name, io_type
    end

    def exec(command, close_connection = false)
      config.logger.info ">> #{command}"
      stdin.puts command
      close if close_connection
    end

    def exec!(command = nil, &blk)
      buffer = String.new
      add_listener(:buffer, :stdout) { |data| buffer << data }
      block_given? ? batch_exec(&blk) : exec(command, true)
      remove_listener(:buffer, :stdout)
      buffer
    end

    def batch_exec(&blk)
      CommandBuilder.new(&blk).to_a.map { |cmd| exec cmd }
      close
    end

    def open
      @stdin, @stdout, @stderr, @ctrl_thrd = Open3.popen3 config.ssh_command
      handle_startup_errors
      @read_thrd = Thread.new { read_loop stdout, :stdout }
      @errs_thrd = Thread.new { read_loop stderr, :stderr }
    end

    def close
      stdin.close

      @errs_thrd.thread_variable_set(:terminate, true)
      @read_thrd.thread_variable_set(:terminate, true)

      loop { break if !(@errs_thrd.alive? || @read_thrd.alive?) }
      stderr.close
      stdout.close

      ctrl_thrd.exit
    end

    private

    def wait_io(io, io_type)
      args = io_type == :stdout ? [[stdout], nil, nil] : [nil, nil, [stderr]]
      args.push config.read_timeout
      IO.select(*args)
    end

    def handle_startup_errors
      wait_io stderr, :stderr
      stderr.read_nonblock(config.read_block_size)
    end

    def handle_listeners(io, io_type, data)
      config.listeners[io_type].each { |_, l| l.call data }
    end

    def can_read?(io, io_type)
      return io.ready? && !io.eof? if io.respond_to?(:ready?)
      ready = !Thread.current.thread_variable_get(io_type)
      Thread.current.thread_variable_set(io_type, false)
      ready
    end

    def read(io, io_type)
      wait_io io, io_type
      if can_read? io, io_type
        handle_listeners io, io_type, io.read_nonblock(config.read_block_size)
      end
    rescue StandardError => e
      config.logger.debug "#{io_type}: #{e.inspect}"
      raise
    rescue IO::WaitReadable, EOFError => e
      Thread.current.thread_variable_set(io_type, true)
      retry
    end

    def read_loop(io, io_type)
      loop do
        next if read io, io_type

        if Thread.current.thread_variable_get(:terminate)
          config.logger.debug "#{io_type}: exit from thread"
          Thread.exit
        end
      end
    end

  end
end
