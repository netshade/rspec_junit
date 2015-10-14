require 'fakefs/safe'
require 'fakefs/file'

# adds foreach support to fakefs
# code from: https://github.com/defunkt/fakefs/pull/294
module FakeFS
  # FakeFS File class inherit StringIO
  class File < StringIO
    def self.foreach(path, *args, &block)
      file = new(path)
      if file.exists?
        FileSystem.find(path).atime = Time.now
        if block_given?
          file.each_line(*args, &block)
        else
          file.each_line(*args)
        end
      else
        fail Errno::ENOENT
      end
    end
  end
end
