require 'rubygems'
require 'rspec'
require_relative '../lib/rspec_junit'

require 'simplecov'
require 'coveralls'
SimpleCov.start { add_filter 'spec/' }
