require 'simplecov'
require 'coveralls'

# Omit coveralls formatter since we're merging suite results via a Rake task
# https://coveralls.zendesk.com/hc/en-us/articles/201769485-Ruby-Rails
SimpleCov.start { add_filter 'spec/' }

require 'aruba/cucumber'
require 'nokogiri'

