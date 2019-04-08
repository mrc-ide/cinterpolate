#ifndef CINTERPOLTE_INTERPOLATE_H_
#define CINTERPOLTE_INTERPOLATE_H_

#include <stddef.h>
#include <stdbool.h>

typedef enum {
  CONSTANT,
  LINEAR,
  SPLINE
} interpolate_type;

typedef struct interpolate_data_t interpolate_data;

typedef int (*interpolate_eval_t)(double, interpolate_data*, double*);

struct interpolate_data_t  {
  interpolate_type type;
  size_t n;     // number of points
  size_t ny;    // number of y entries per 'x' point
  size_t i;     // index of last point checked
  double *x;    // x points of interpolation
  double *y;    // y points of interpolation
  double *k;    // knots when using spline interpolation
  interpolate_eval_t eval;
  bool fail_on_extrapolate;
  bool auto_free;
};

interpolate_data * interpolate_alloc(const char *name, size_t n, size_t ny,
                                     double *x, double *y,
                                     bool fail_on_extrapolate,
                                     bool auto_clean);
interpolate_type interpolate_type_from_name(const char *name);

interpolate_data * interpolate_alloc2(interpolate_type type, size_t n,
                                      size_t ny, double *x, double *y,
                                      bool fail_on_extrapolate,
                                      bool auto_clean);
void interpolate_free(interpolate_data* obj);
int interpolate_eval(double x, interpolate_data *obj, double *y);
int interpolate_eval_fail(double x, interpolate_data *obj, double *y);
int interpolate_constant_eval(double x, interpolate_data* obj, double *y);
int interpolate_linear_eval(double x, interpolate_data* obj, double *y);
int interpolate_spline_eval(double x, interpolate_data* obj, double *y);

// Utility:
int interpolate_search(double target, interpolate_data *obj);

// Splines
double spline_eval_i(size_t i, double x, double *xs, double *ys, double *ks);
void spline_calc_A(size_t n, double *x, double *A);
void spline_calc_B(size_t n, size_t ny, double *x, double *y, double *B);
void spline_calc_solve(int n, int ny, double *A, double *B);

#endif
