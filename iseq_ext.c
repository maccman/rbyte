#include "ruby.h"

RUBY_EXTERN VALUE rb_cISeq;
VALUE ruby_iseq_load(VALUE data, VALUE parent, VALUE opt);

static VALUE
iseq_s_load(int argc, VALUE *argv, VALUE self)
{
    VALUE data, opt=Qnil;
    rb_scan_args(argc, argv, "11", &data, &opt);

    return ruby_iseq_load(data, 0, opt);
}

void 
Init_iseq_ext()
{
	// Load method is commented out in iseq.c
	rb_define_singleton_method(rb_cISeq, "load_array", iseq_s_load, -1);
}
