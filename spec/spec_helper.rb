$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ssh_client'
require 'rspec'
require 'pry'

ENV['BUNDLED_GROUPS'] = 'test'

require 'coveralls'
Coveralls.wear! { add_filter '/spec/' }

SSHClient.configure do |conf|
  conf.hostname = 'localhost'
  conf.username = ENV['SSHUSER']
  conf.password = ENV['SSHPASS']
  conf.logger = Logger.new 'log/test.log'
  conf.read_timeout = 3
end
