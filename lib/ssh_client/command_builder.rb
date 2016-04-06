module SSHClient
  class CommandBuilder
    SEPARATOR = ' '.freeze

    def initialize(&blk)
      @paths = []
      @context = eval 'self', blk.binding
      instance_eval(&blk)
    end

    def to_a
      @paths
    end

    def run(*args)
      @paths << to_path(*args)
    end

    private

    def method_missing(*args)
      return @context.send(*args) if @context.respond_to?(args.first, true)
      name = args.shift
      value = to_path args.map { |a| to_path a }
      @paths.pop if @paths.last == value
      @paths << to_path(name, value)
      @paths.last
    end

    def /(path)
      "/#{path}"
    end

    def to_path(*args)
      val = args.is_a?(Hash) ? args.to_a : args
      Array(val).flatten.compact.join SEPARATOR
    end

  end
end
