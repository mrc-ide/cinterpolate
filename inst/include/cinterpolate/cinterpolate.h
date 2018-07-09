#ifndef CINTERPOLTE_CINTERPOLATE_H_
#define CINTERPOLTE_CINTERPOLATE_H_

// Allow use from C++
#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h> // size_t

void *cinterpolate_alloc(const char *type, size_t n, size_t ny,
                         double *x, double *y);
int cinterpolate_eval(double x, void *obj, double *y);
void cinterpolate_free(void *obj);

#ifdef __cplusplus
}
#endif

#endif
