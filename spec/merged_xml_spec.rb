require_relative '../lib/rspec_junit/merged_xml'
require_relative 'fake_foreach_patch'

module RspecJunit
  describe MergedXml do

    # -- Helper code

    def list_files_in_fakefs
      root      = FakeFS::FileSystem.fs
      dirs      = FakeFS::FileSystem.send(:directories_under, root)
      all_files = dirs.flatten.map(&:entries).flatten.reject { |d| d.class == FakeFS::FakeDir }
      all_files
    end

    def merged_xml_file
      @merged_xml_file ||= File.expand_path(File.join(__dir__, 'xml', 'merged_xml.xml'))
    end

    def expected_files
      return @expected_files if @expected_files
      @expected_files = []
      base_dir = File.dirname merged_xml_file
      1.upto(19) { |i| @expected_files << File.join(base_dir, "junit_#{i}.xml") }
      @expected_files
    end

    before(:all) do
      FakeFS.activate!
      # Read xml data from real FS and use it to populate the fake file system
      fake_file         = FakeFS::FakeFile.new
      fake_file.content = FakeFS.without { File.read merged_xml_file }

      FakeFS::FileSystem.add(merged_xml_file, fake_file)
    end

    after(:all) { FakeFS.deactivate! }

    # -- Start testing

    it 'rejects invalid paths' do
      invalid_path   = 'does not exist'
      expected_error = "Invalid path to xml file: #{invalid_path}"

      expect { MergedXml.new invalid_path }.to raise_error expected_error
    end

    it 'splits merged xml correctly' do
      expected_files.each { |file| expect(File.exist?(file)).to eq(false) }

      merged_xml = MergedXml.new merged_xml_file
      merged_xml.split

      expected_files.each do |file|
        expect(File.exist?(file)).to eq(true)
        expect(File.size(file)).to be > 400
      end
    end
  end
end
