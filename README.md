# SSHClient

[![Build Status](https://travis-ci.org/kosmatov/ssh_client.svg?branch=master)](https://travis-ci.org/kosmatov/ssh_client)
[![Coverage Status](https://coveralls.io/repos/github/kosmatov/ssh_client/badge.svg?branch=master)](https://coveralls.io/github/kosmatov/ssh_client?branch=master)

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

Note that gem uses `sshpass` utility to open connection authenticated by password, `sshpass` can be present in u system, or set `config.ssh_command` other way.

### Configure client

```ruby

# Default config
SSHClient.configure do |conf|
  conf.hostname = 'example.com'
  conf.username = 'sample'
  conf.password = 'sample'
  conf.logger = Logger.new('log/my.log') # default log to STDOUT
  conf.read_timeout = 10 # default 30
end

# Custom config
SSHClient.configure(:custom) do |conf|
  conf.hostname = '127.0.0.1'
  conf.ssh_command = proc { |config| "ssh #{config.hostname} -i $HOME/.ssh/id_rsa" }
end
```

See [IO.select](http://ruby-doc.org/core/IO.html#method-c-select) to understand `read_timeout` option.
See [ConfigItem](https://github.com/kosmatov/ssh_client/blob/master/lib/ssh_client/config_item.rb) to understand how `ssh_command` option work.

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

