$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ssh_client'
require 'rspec'
require 'pry'

ENV['BUNDLED_GROUPS'] = 'test'

require 'coveralls'
Coveralls.wear! { add_filter '/spec/' }

