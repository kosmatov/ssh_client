# SSHClient

Ruby SSH client uses Open3 and OpenSSH to interact with any remote shell

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ssh_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ssh_client

## Usage

### Configure client

```ruby

# Default config
SSHClient.configure do |conf|
  conf.hostname = 'example.com'
  conf.username = 'sample'
  conf.password = 'sample'
  conf.logger = Logger.new('log/my.log') # default log to STDOUT
  conf.read_timeout = 10 # default 30, see http://ruby-doc.org/core/IO.html#method-c-select
end

# Custom config
SSHClient.configure(:custom) do |conf|
  conf.hostname = 'custom.example.com'
  conf.username = 'custom'
  conf.password = 'custom'
end
```

### Execute commands

Using connection instance

```ruby
connection = SSHClient.connect

connection.add_listener do |data|
  puts data
end

connection.exec 'hostname'
connection.close
```

Using connection with custom config

```ruby
connection = SSHClient.connect :custom
```

Pass hostname, username and password to connection

```ruby
connection = SSHClient.connect hostname: 'example.com', username: 'sample', password: 'sample'
```

Multiply commands run with block. Connection closed after block execution

```ruby
SSHClient.connect do
  hostname
  uname '-a'
  run 'cat /proc/cpuinfo | grep model'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ssh_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

