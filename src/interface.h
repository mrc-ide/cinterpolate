#include <R.h>
#include <Rinternals.h>
SEXP r_interpolate_prepare(SEXP r_x, SEXP r_y, SEXP r_type);
SEXP r_interpolate_eval(SEXP r_ptr, SEXP r_x);
SEXP r_interpolate_data_info(SEXP r_ptr);
