#ifndef CINTERPOLTE_CINTERPOLATE_H_
#define CINTERPOLTE_CINTERPOLATE_H_
#include <stddef.h> // size_t
#include <stdbool.h> // bool

// Allow use from C++
#ifdef __cplusplus
extern "C" {
#endif

// There are only three functions in the interface; allocation,
// evaluation and freeing.

// Allocate an interpolation object.
//
//   type: The mode of interpolation. Must be one of "constant",
//       "linear" or "spline" (an R error is thrown if a different
//       value is given).
//
//   n: The number of `x` points to interpolate over
//
//   ny: the number of `y` points per `x` point.  This is 1 in the
//       case of zimple interpolation as used by Rs `interpolate()`
//
//   x: an array of `x` values of length `n`
//
//   y: an array of `ny` sets of `y` values.  This is in R's matrix
//       order (i.e., the first `n` values are the first series to
//       interpolate over).
//
//   fail_on_extrapolate: if true, when an extrapolation occurs throw
//       an error; if false return NA_REAL
//
//   auto_free: automatically clean up the interpolation object on
//       return to R. This uses `R_alloc` for allocations rather than
//       `Calloc` so freeing will always happen (even on error
//       elsewhere in the code). However, this prevents returning back
//       a pointer to R that will last longer than the call into C
//       code.
//
// The return value is an opaque pointer that can be passed through to
// `cinterpolate_eval` and `cinterpolate_free`
void *cinterpolate_alloc(const char *type, size_t n, size_t ny,
                         double *x, double *y, bool fail_on_extrapolate,
                         bool auto_free);

// Evaluate the interpolated function at a new `x` point.
//
//   x: A new, single, `x` point to interpolate `y` values to
//
//   obj: The interpolation object, as returned by `cinterpolate_alloc`
//
//   y: An array of length `ny` to store the interpolated values
//
// The return value is 0 if the interpolation is successful (with x
// lying within the range of values that the interpolation function
// supports), -1 otherwise
int cinterpolate_eval(double x, void *obj, double *y);

// Clean up all allocated memory
//
//   obj: The interpolation object, as returned by `cinterpolate_alloc`
void cinterpolate_free(void *obj);

#ifdef __cplusplus
}
#endif

#endif
