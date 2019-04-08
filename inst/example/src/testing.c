#include <cinterpolate/cinterpolate.c>
#include <stdbool.h>
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Utils.h>

SEXP test(SEXP r_x, SEXP r_y, SEXP r_xout, SEXP r_type) {
  const char * type = CHAR(STRING_ELT(r_type, 0));

  bool is_matrix = isMatrix(r_y);

  size_t n = length(r_x);
  size_t ny = is_matrix ? ncols(r_y) : 1;
  void *obj = cinterpolate_alloc(type, n, ny, REAL(r_x), REAL(r_y),
                                 false, true);

  size_t nxout = length(r_xout);
  SEXP r_yout = PROTECT(is_matrix ?
                        allocMatrix(REALSXP, ny, nxout) :
                        allocVector(REALSXP, nxout));
  double *xout = REAL(r_xout), *yout = REAL(r_yout);
  for (size_t i = 0; i < nxout; ++i) {
    cinterpolate_eval(xout[i], obj, yout);
    yout += ny;
  }

  UNPROTECT(1);
  return r_yout;
}
