require File.join(File.dirname(__FILE__), *%w[iseq_ext])

module Rbyte
  module RequirePatch
    def self.included(base)
      base.class_eval do
        alias :require_without_rbyte :require
        alias :require :require_with_rbyte
      end
    end
    
    # Searches load path for rbc files. 
    # If a normal Ruby file exists with with a
    # more recent mtime, then that will be loaded 
    # instead. Delegates to Ruby's normal require 
    # if a file can't be found.
    def require_with_rbyte(name)
      path = Rbyte.search_for_rbc_file(name)
      unless path
        return require_without_rbyte(name)
      end
      
      # File already loaded?
      return false if $".include?(path)
      
      # File is plain ruby
      if path =~ /\.rb\Z/
        return require_without_rbyte(path)
      end
      
      # Find out if rbc file is out of date
      rb_path = path.gsub(/\.rbc\Z/, ".rb")
      if File.file?(rb_path) && 
           mtime = File.mtime(rb_path)
        if File.mtime(path) < mtime
          return require_without_rbyte(rb_path)
        end
      end
      
      # Evaluate rbc file
      Rbyte.decompile_file(path)
      
      # Add to loaded files
      $" << File.expand_path(path)
      
      true
    end
  end
  
  def search_for_rbc_file(path) #:nodoc:
    return unless supported_file?(path)
    path.gsub!(/\.rbc\Z/, "")
    $LOAD_PATH.each do |root|
      test_path = File.join(root, path)

      # Test for rbc files
      rbc_test_path = test_path + ".rbc"
      return rbc_test_path if File.file?(rbc_test_path)

      # Test for rb files
      rb_test_path = test_path + ".rb"
      return rb_test_path if File.file?(rb_test_path)
    end
    nil
  end
  module_function :search_for_rbc_file
  
  # Read a rbc file and evaluate it
  def decompile_file(path)
    res = Marshal.load(File.read(path))
    RubyVM::InstructionSequence.load_array(res).eval
  end
  module_function :decompile_file
  
  # Compile a Ruby file to a Ruby byte code (rbc) file.
  # The rbc file will be placed next to the Ruby file.
  # If the method returns false, than compilation failed.
  def compile_file(path)
    path = "#{path}.rb" unless path =~ /\.rb\Z/
    res  = RubyVM::InstructionSequence.compile_file(path)
    data = Marshal.dump(res.to_a)
    rbc_path = path + "c"
    File.open(rbc_path, "w+") {|f| f.write data }
  rescue NotImplementedError
    # Ruby bug with terminated objects
    false
  end
  module_function :compile_file
  
  private
    # Only paths without a extension
    # or with an extension of .rbc are
    # are supported. If you require a file
    # with a rb extension, it's assumed you
    # only want plain ruby files.
    def supported_file?(path)
      ext = File.extname(path)
      return true if ext.empty?
      ext =~ /\.rbc\Z/
    end
    module_function :supported_file?
end