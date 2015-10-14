require 'rubygems'

require 'simplecov'
require 'coveralls'
SimpleCov.start { add_filter 'spec/' }

require 'rspec'
require_relative '../lib/rspec_junit'
