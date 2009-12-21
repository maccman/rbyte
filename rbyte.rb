require "iseq_ext"

module Rbyte
  module KernelMethods
    def self.included()
      alias :require_without_rbyte, :require
      alias :require, :require_with_rbyte
    end
  
    def require_with_rbyte(path)
      # Alias...
    end
  end
  
  def decompile_file(path)
    res = Marshall.load(File.read(path))
    RubyVM::InstructionSequence.load2(res).eval
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