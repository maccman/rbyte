unless defined?(RubyVM)
  raise "Current Ruby version is not supported"
end

require "mkmf"
create_makefile("iseq_ext")
