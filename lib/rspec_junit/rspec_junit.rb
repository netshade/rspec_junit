require 'digest/md5'
# RSpec formatter for generating results in JUnit format
# Inherit from BaseFormatter like the JSON rspec-core formatter.
class RSpecJUnit < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self, :example_passed, :example_failed,
                                   :example_pending, :dump_summary,
                                   :close

  def initialize(output)
    super
    @test_suite_results = {}
    @builder            = Builder::XmlMarkup.new indent: 2
  end

  def example_passed(example_notification)
    add_to_test_suite_results example_notification
  end

  def example_failed(example_notification)
    add_to_test_suite_results example_notification
  end

  def example_pending(example_notification)
    add_to_test_suite_results example_notification
  end

  def dump_summary(summary)
    build_results(summary.duration, summary.examples.size, summary.failed_examples.size, summary.pending_examples.size)
    @output.puts @builder.target!
  end

  # close is required to output files correctly.
  # Use with Process.pid to have unique names
  # close code modified from: lib/rspec/core/formatters/base_text_formatter.rb
  def close(_notification)
    return unless IO === output
    return if output.closed?

    output.flush
    output.close unless output == $stdout
  end

  protected

  def add_to_test_suite_results(example_notification)
    suite_name                      = RSpecJUnit.root_group_name_for example_notification
    file_name                       = example_notification.example.example_group.id
    key                             = [suite_name, file_name]
    @test_suite_results[key]      ||= []
    @test_suite_results[key]       << example_notification.example
  end

  def failure_details_for(example)
    exception = example.exception
    return '' if exception.nil?
    backtrace = ''
    if exception.backtrace # may be nil
      # Use the configured backtrace formatter instead of creating a new one.
      backtrace = RSpec.configuration.backtrace_formatter.format_backtrace exception.backtrace
      backtrace = "\n#{backtrace.join("\n")}"
    end

    # avoid duplicating the link if the message already contains it
    # this happens when SauceDocumentation is used.
    sauce_test_link = example.metadata[:sauce_test_link]
    message         = exception.message || ''
    print_link      = sauce_test_link && !message.include?(sauce_test_link)

    result = "\n#{exception.class.name}\n#{message}"
    result += "\n#{sauce_test_link}\n" if print_link
    "#{result}#{backtrace}"
  end

  # utility methods

  def self.count_in_suite_of_type(suite, test_case_result_type)
    suite.select { |example| example.metadata[:execution_result].status == test_case_result_type }.size
  end

  def self.root_group_name_for(example_notification)
    example_notification.example.metadata[:example_group][:full_description]
  end

  # methods to build the xml for test suites and individual tests

  def build_results(duration, example_count, failure_count, pending_count)
    @builder.instruct! :xml, version: '1.0', encoding: 'UTF-8'
    @builder.testsuites(
      errors:    0,
      failures:  failure_count,
      skipped:   pending_count,
      tests:     example_count,
      time:      duration,
      timestamp: Time.now.iso8601) do
      build_all_suites
    end
  end

  def build_all_suites
    @test_suite_results.each do |(suite_name, file_path), tests|
      build_test_suite(suite_name, file_path, tests)
    end
  end

  def class_from_file_path(file_path)
    components = file_path.split(/[\.\/\\]+/i).map(&:strip).compact.reject(&:empty?)
    components.map do |component|
      if component =~ /\[[^\]]+\]\Z/
        index          = component.index("[")
        if index
          _, position = component[0..index - 1], component[index..-1]
          "testId#{position}"
        else
          component.split(".")[0..-2].join(".")
        end
      elsif component =~/:\d+\Z/
        file, position = component.split(":")
        name_parts     = file.split(".")
        "line#{position}"
      else
        if component.index(".")
          component.split(".")[0..-2].join(".")
        else
          component
        end
      end
    end.join(".")
  end

  def build_test_suite(suite_name, file_path, tests)
    failure_count = RSpecJUnit.count_in_suite_of_type(tests, :failed)
    skipped_count = RSpecJUnit.count_in_suite_of_type(tests, :pending)

    @builder.testsuite(
                       location:  file_path,
                       id:        Digest::MD5.hexdigest(file_path),
                       name:      suite_name,
                       classname: class_from_file_path(file_path),
                       tests:     tests.size,
                       errors:    0,
                       failures:  failure_count,
                       skipped:   skipped_count) do
      @builder.properties
      build_all_tests tests
    end
  end

  def build_all_tests(tests)
    tests.each do |test|
      build_test test
    end
  end

  def build_test(test)
    test_name      = test.metadata[:full_description]
    execution_time = test.metadata[:execution_result].run_time
    test_status    = test.metadata[:execution_result].status
    location       = test.location

    @builder.testcase(name: test_name, time: execution_time, location: test.id, id: Digest::MD5.hexdigest(test.id), classname: class_from_file_path(test.id)) do
      case test_status
        when :pending
          @builder.skipped
        when :failed
          build_failed_test test
      end
    end
  end

  def build_failed_test(test)
    failure_message = "failed #{test.metadata[:full_description]}"

    @builder.failure(message: failure_message, type: 'failed') do
      @builder.cdata!(failure_details_for(test))
    end
  end

end
