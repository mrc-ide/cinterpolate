#ifndef _CINTERPOLATE_H_
#define _CINTERPOLATE_H_

#include <stddef.h> // size_t

void *cinterpolate_alloc(const char *type, size_t n, size_t ny,
                         double *x, double *y);
int cinterpolate_eval(double x, void *obj, double *y);

#endif
