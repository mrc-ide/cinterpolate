// This construction is to help odin
#ifndef _CINTERPOLATE_H_
#include <cinterpolate/cinterpolate.h>
#endif

#include <R_ext/Rdynload.h>

void * cinterpolate_alloc(const char *type, size_t n, size_t ny,
                          double *x, double *y) {
  typedef void* interpolate_alloc_t(const char *, size_t, size_t,
                                    double*, double*);
  static interpolate_alloc_t *fun;
  if (fun == NULL) {
    fun = (interpolate_alloc_t*)
      R_GetCCallable("cinterpolate", "interpolate_alloc");
  }
  return fun(type, n, ny, x, y);
}

int cinterpolate_eval(double x, void *obj, double *y) {
  typedef int interpolate_eval_t(double, void*, double*);
  static interpolate_eval_t *fun;
  if (fun == NULL) {
    fun = (interpolate_eval_t*)
      R_GetCCallable("cinterpolate", "interpolate_eval");
  }
  return fun(x, obj, y);
}

void cinterpolate_free(void *obj) {
  typedef int interpolate_free_t(void*);
  static interpolate_free_t *fun;
  if (fun == NULL) {
    fun = (interpolate_free_t*)
      R_GetCCallable("cinterpolate", "interpolate_free");
  }
  return fun(obj);
}
