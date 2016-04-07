$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ssh_client'
require 'rspec'
require 'pry'

ENV['BUNDLED_GROUPS'] = 'test'

require 'coveralls'
Coveralls.wear! { add_filter '/spec/' }

SSHClient.configure do |conf|
  conf.ssh_command = proc { |_| "ssh localhost -i $HOME/.ssh/id_rsa" }
  conf.read_timeout = 3
end
