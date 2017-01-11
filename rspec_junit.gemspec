require_relative 'lib/rspec_junit/version'

Gem::Specification.new do |gem|
  gem.name        = 'rspec_junit'
  gem.version     = RspecJunit::VERSION
  gem.authors     = ['Nat Ritmeyer', 'Ben Snape']
  gem.email       = ['nat@natontesting.com']
  gem.homepage    = 'http://github.com/bootstraponline/rspec_junit'
  gem.summary     = 'Yet Another RSpec JUnit Formatter (for Hudson/Jenkins)'
  gem.description = 'Yet Another RSpec JUnit Formatter (for Hudson/Jenkins)'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency('rspec', '>= 3.3.0')
  gem.add_runtime_dependency('builder', '~> 3.0.0')

  gem.add_development_dependency('pry', '~> 0.10.2')
  gem.add_development_dependency('fakefs', '~> 0.6.7')
  gem.add_development_dependency('rubocop', '~> 0.34.2')
  gem.add_development_dependency('appium_thor', '~> 1.0.1')
  gem.add_development_dependency('nokogiri', '~> 1.6.6.2') # for Ruby 1.8.7
  gem.add_development_dependency('cucumber', '~> 1.3.16')
  gem.add_development_dependency('aruba', '~> 0.6.0')
  gem.add_development_dependency('simplecov', '~> 0.10.0')
  gem.add_development_dependency('coveralls', '~> 0.8.3')
  gem.add_development_dependency('reek', ['= 1.3.7']) # for Ruby 1.8.7
  gem.add_development_dependency('rainbow', '~> 1.99.2') # for Ruby 1.8.7
end
