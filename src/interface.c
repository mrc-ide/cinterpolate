#include "interface.h"
#include "interpolate.h"
#include <stdbool.h>


SEXP r_interpolate_prepare(SEXP r_x, SEXP r_y, SEXP r_type) {
  const char *type_name = CHAR(STRING_ELT(r_type, 0));
  size_t n = (size_t)length(r_x), ny;
  double *x = REAL(r_x), *y = REAL(r_y);
  if (isMatrix(r_y)) {
    ny = ncols(r_y);
  } else {
    ny = 1;
  }
  if ((size_t)length(r_y) != ny * n) {
    Rf_error("Expected 'y' to have total length of %d (%d x %d)",
             ny * n, n, ny);
  }
  interpolate_data * data = interpolate_alloc(type_name, n, ny, x, y, false);

  SEXP r_ptr = R_MakeExternalPtr(data, R_NilValue, R_NilValue);
  R_RegisterCFinalizer(r_ptr, interpolate_data_finalize);

  return r_ptr;
}


SEXP r_interpolate_eval(SEXP r_ptr, SEXP r_x) {
  interpolate_data * obj = interpolate_data_get(r_ptr, true);
  size_t nx = (size_t) length(r_x), ny = obj->ny;
  const double *x = REAL(r_x);
  SEXP r_y = PROTECT(allocVector(REALSXP, nx * ny));
  double * y = REAL(r_y);
  double *tmp = (double*) R_alloc(obj->ny, sizeof(double));

  for (size_t i = 0; i < nx; ++i) {
    interpolate_eval(x[i], obj, tmp);
    for (size_t j = 0, k = i; j < obj->ny; ++j) {
      y[k] = tmp[j];
      k += nx;
    }
  }

  UNPROTECT(1);
  return r_y;
}


void interpolate_data_finalize(SEXP r_ptr) {
  interpolate_data *data = interpolate_data_get(r_ptr, false);
  if (data) {
    interpolate_free(data);
    R_ClearExternalPtr(r_ptr);
  }
}


interpolate_data* interpolate_data_get(SEXP r_ptr, bool closed_error) {
  interpolate_data *data = NULL;
  if (TYPEOF(r_ptr) != EXTPTRSXP) {
    Rf_error("Expected an external pointer");
  }
  data = (interpolate_data*) R_ExternalPtrAddr(r_ptr);
  if (!data && closed_error) {
    Rf_error("interpolate_data already freed");
  }
  return data;
}


SEXP r_interpolate_data_info(SEXP r_ptr) {
  interpolate_data *data = interpolate_data_get(r_ptr, true);
  size_t n = data->n, ny = data->ny;
  SEXP ret = PROTECT(allocVector(VECSXP, 6));
  SEXP nms = PROTECT(allocVector(STRSXP, 6));

  SEXP r_x = PROTECT(allocVector(REALSXP, n));
  SEXP r_y = PROTECT(allocMatrix(REALSXP, n, ny));
  SEXP r_k = R_NilValue;

  memcpy(REAL(r_x), data->x, n * sizeof(double));
  memcpy(REAL(r_y), data->y, n * ny * sizeof(double));
  if (data->type == SPLINE) {
    r_k = PROTECT(allocMatrix(REALSXP, n, ny));
    memcpy(REAL(r_k), data->k, n * ny * sizeof(double));
  }

  SET_VECTOR_ELT(ret, 0, ScalarInteger(data->n));
  SET_STRING_ELT(nms, 0, mkChar("n"));

  SET_VECTOR_ELT(ret, 1, ScalarInteger(data->ny));
  SET_STRING_ELT(nms, 1, mkChar("ny"));

  SET_VECTOR_ELT(ret, 2, ScalarInteger(data->i));
  SET_STRING_ELT(nms, 2, mkChar("i"));

  SET_VECTOR_ELT(ret, 3, r_x);
  SET_STRING_ELT(nms, 3, mkChar("x"));

  SET_VECTOR_ELT(ret, 4, r_y);
  SET_STRING_ELT(nms, 4, mkChar("y"));

  SET_VECTOR_ELT(ret, 5, r_k);
  SET_STRING_ELT(nms, 5, mkChar("k"));

  setAttrib(ret, R_NamesSymbol, nms);
  UNPROTECT(data->type == SPLINE ? 5 : 4);
  return ret;
}


#include <R_ext/Rdynload.h>
#include <Rversion.h>

static const R_CallMethodDef call_methods[] = {
  {"Cinterpolate_prepare",     (DL_FUNC) &r_interpolate_prepare,     3},
  {"Cinterpolate_eval",        (DL_FUNC) &r_interpolate_eval,        2},
  {"Cinterpolate_data_info",   (DL_FUNC) &r_interpolate_data_info,   1},
  {NULL,                       NULL,                                 0}
};


// Package initialisation, required for the registration
void R_init_cinterpolate(DllInfo *dll) {
  R_registerRoutines(dll, NULL, call_methods, NULL, NULL);

  R_RegisterCCallable("cinterpolate", "interpolate_alloc",
                      (DL_FUNC) &interpolate_alloc);
  R_RegisterCCallable("cinterpolate", "interpolate_eval",
                      (DL_FUNC) &interpolate_eval);
  R_RegisterCCallable("cinterpolate", "interpolate_free",
                      (DL_FUNC) &interpolate_free);

#if defined(R_VERSION) && R_VERSION >= R_Version(3, 3, 0)
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
#endif
}
