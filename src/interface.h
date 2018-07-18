#ifndef CINTERPOLTE_INTERFACE_H_
#define CINTERPOLTE_INTERFACE_H_

#include "interpolate.h"
#include <R.h>
#include <Rinternals.h>
SEXP r_interpolate_prepare(SEXP r_x, SEXP r_y, SEXP r_type);
SEXP r_interpolate_eval(SEXP r_ptr, SEXP r_x);
SEXP r_interpolate_data_info(SEXP r_ptr);
interpolate_data* interpolate_data_get(SEXP r_ptr, bool closed_error);
static void interpolate_data_finalize(SEXP r_ptr);

#endif
