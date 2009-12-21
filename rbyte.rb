require "iseq_ext"

module Rbyte
  module KernelMethods
    def self.included(base)
      base.class_eval do
        alias :require_without_rbyte, :require
        alias :require, :require_with_rbyte
      end
    end
  
    def require_with_rbyte(path)
      # Search load path for files with extensions .rbc
      # Find corresponding .rb file (if it exists) 
      # Compare mtimes. If the .rpc file is up to date, 
      # eval it and add to 'loaded_feature'.
      # Otherwise, normal require.
    end
  end
  
  def decompile_file(path)
    res = Marshall.load(File.read(path))
    RubyVM::InstructionSequence.load_array(res).eval
  end
  module_function :decompile_file
  
  def compile_file(path)
    npath = File.join(File.dirname(path), File.basename(path, ".rb") + ".rbc")
    return if File.exist?(npath)
    res  = RubyVM::InstructionSequence.compile_file(path)
    data = Marshall.dump(res.to_a)
    File.open(npath, "w+") {|f| f.write data }
  end
  module_function :compile_file
end