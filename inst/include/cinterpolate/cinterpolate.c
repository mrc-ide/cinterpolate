// This construction is to help odin
#ifndef _CINTERPOLATE_H_
#include <cinterpolate/cinterpolate.h>
#endif

#include <R_ext/Rdynload.h>

typedef void* interpolate_alloc_t(const char *, size_t, size_t,
                                   double*, double*);
typedef int interpolate_eval_t(double, void*, double*);

void * cinterpolate_alloc(const char *type, size_t n, size_t ny,
                          double *x, double *y) {
  static interpolate_alloc_t *fun;
  if (fun == NULL) {
    fun = (interpolate_alloc_t*)
      R_GetCCallable("cinterpolate", "interpolate_alloc");
  }
  return fun(type, n, ny, x, y);
}

int cinterpolate_eval(double x, void *obj, double *y) {
  static interpolate_eval_t *fun;
  if (fun == NULL) {
    fun = (interpolate_eval_t*)
      R_GetCCallable("cinterpolate", "interpolate_eval");
  }
  return fun(x, obj, y);
}
