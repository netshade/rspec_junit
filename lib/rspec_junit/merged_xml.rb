module RspecJunit
  class MergedXml
    attr_reader :xml_path, :base_path

    def initialize(xml_path)
      fail "Invalid path to xml file: #{xml_path}" unless File.file?(xml_path)
      @xml_path  = xml_path
      @base_path = File.dirname xml_path
      reset
    end

    def split
      reset

      File.foreach(xml_path) do |line|
        if line.match XML_START
          dump_file unless xml_count == 0
          @data      = ''
          @xml_count += 1
        end

        @data += "#{line}"
      end
    end

    private

    XML_START = /^#{Regexp.escape('<?xml version="1.0" encoding="UTF-8"?>')}$/

    attr_reader :xml_count, :data

    def reset
      @xml_count = 0
      @data      = ''
    end

    def dump_file
      file_name = File.join(base_path, "junit_#{xml_count}.xml")
      File.open(file_name, 'w') { |f| f.write data }
    end
  end
end
