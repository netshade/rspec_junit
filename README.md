# rspec_junit 
[![Gem Version](https://badge.fury.io/rb/rspec_junit.svg)](https://rubygems.org/gems/rspec_junit)
[![Build Status](https://travis-ci.org/bootstraponline/rspec_junit.svg)](https://travis-ci.org/bootstraponline/rspec_junit)[![Dependency Status](https://gemnasium.com/bootstraponline/rspec_junit.svg)](https://gemnasium.com/bootstraponline/rspec_junit)
[![Coverage Status](https://coveralls.io/repos/bootstraponline/rspec_junit/badge.svg?nocache2)](https://coveralls.io/r/bootstraponline/rspec_junit)

A fork of [yarjuf](https://github.com/natritmeyer/yarjuf) containing additional features and bug fixes.
Another popular junit formatter is [rspec_junit_formatter](https://github.com/sj26/rspec_junit_formatter).

## Usage

```ruby
# spec_helper.rb
require 'rspec_junit'

RSpec.configure do |config|
  config.before(:suite) do
    # Must register the formatter here and not in an options file. The options
    # file uses the master process pid and globs all the xml files into one
    # instead of the worker pids which output to individual files.
    config.add_formatter RSpecJUnit, "junit_#{Process.pid}.xml"
  end
end
```

## Sauce Labs Jenkins notes

- If the values for `Job Name	OS/Browser	Pass/Fail	Job Links` aren't autopopulated, ensure that
  the Sauce username and API key have been provided to the Sauce Plugin. Under
  **Sauce Labs Options** in the job configure menu check `Override default authentication`
  and then provide the user and access key.
- If the JUnit results report doesn't auto link to Sauce Labs jobs, ensure that
  the **Post-build Actions** lists **Publish JUnit test results report** as the first action
  and that **Run Sauce Labs Test Publisher** is after the JUnit action.

--

## Intro

I've never found a gem that can be relied on to generate JUnit
output from [RSpec](https://www.relishapp.com/rspec/rspec-core/docs). Previously, I'd cobbled together a [formatter](http://www.natontesting.com/2012/05/25/rspec-junit-formatter-for-jenkins/) that worked for me for a couple of years and seems to have proved
useful to others. But it was a hack and thought I'd rewrite it, make it
conform to the JUnit format spec a bit better, and make it
distributable as a gem. Thus: [yet-another-rspec-junit-formatter](https://github.com/natritmeyer/yarjuf)

## Installation

Using rubygems:

`gem install rspec_junit`

Using bundler:

Add the following line to your `Gemfile`:

`gem 'rspec_junit'`
 
## Usage

There are a few ways to use custom formatters in RSpec; what follows is
the 'best' way...

### Loading rspec_junit

Before you can use rspec_junit, RSpec needs to know about it. The best way to
do that is to use the functionality that RSpec provides to load
libraries. 

#### Modifying the `.rspec` file

When RSpec executes, it looks for a file in the current working
directory (project root) called `.rspec` that contains rspec
configuration. It is a good idea to add the following to it:

`--require spec_helper`

Doing so will make sure that the `spec/spec_helper.rb` file will get
required when RSpec starts.

#### Modifying the `spec/spec_helper.rb` file

Add the following to your `spec/spec_helper.rb`:

```ruby
require 'rspec_junit'
```

That will make sure that rspec_junit is loaded when RSpec starts and can be
used as a formatter.

### Generating JUnit output using rspec_junit

RSpec tests can be executed in a number of ways. Here's how to get JUnit
output for each of those different ways - assuming you've loaded rspec_junit
as specified above).

#### Running rspec tests from the command line

In this scenario, you just want to run `rspec` from the command line and
get JUnit output. To do that you'll need to use the `-f JUnit` option
to generate JUnit output and to write it to a file you can use the
`-o results.xml` option. So to run all your tests and get JUnit output
written to a file, execute the following:

`rspec -f JUnit -o results.xml`

#### Running rspec tests using Rake

In this scenario, you want to run your rspec tests using rake. To do
that you'll need to add an option to your rake task:

```ruby
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[-f JUnit -o results.xml]
end
```

That will write out JUnit formatted results to a file called
`results.xml`. 

#### Jenkins integration

To use rspec_junit with Jenkins(/Hudson), simply tick the 'Publish JUnit test
result report' option in the Jenkins task configuration page and in the
'Test report XMLs' field specify the file name that you expect the JUnit
formatted results to be written to, ie: the file path and name specified
in the `-o` option above.

## Acknowledgements

* Thanks to [@bsnape](https://github.com/bsnape) for the rspec 3 compatibility patch
* Thanks to [@adeoke](https://github.com/adeoke) for suggesting a slightly less sucky gem name than the
one I originally came up with
* Thanks to [@dchamb84](https://github.com/dchamb84) for helping me debug the original hack
* Thanks to [@nathanbain](https://github.com/nathanbain) for spurring me on to write the original hack

--

Design Notes

The gem [isn't compliant](http://www.freeformatter.com/xml-validator-xsd.html) with the [junit-4.xsd](https://svn.jenkins-ci.org/trunk/hudson/dtkit/dtkit-format/dtkit-junit-model/src/main/resources/com/thalesgroup/dtkit/junit/model/xsd/junit-4.xsd). Additional properties are added that aren't in the junit xsd.
