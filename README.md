# cinterpolate

<!-- badges: start -->
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/)
[![R-CMD-check](https://github.com/mrc-ide/cinterpolate/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mrc-ide/cinterpolate/actions/workflows/R-CMD-check.yaml)
[![codecov.io](https://codecov.io/github/mrc-ide/cinterpolate/coverage.svg?branch=master)](https://app.codecov.io/github/mrc-ide/cinterpolate?branch=master)
[![](http://www.r-pkg.org/badges/version/cinterpolate)](https://cran.r-project.org/package=cinterpolate)
<!-- badges: end -->

Simple interpolation functions designed to be used from C.  There is essentially no R support in this package, save code designed to be used by the package's own testing.  `cinterpolate` is designed to be used in package code only and modification for use outside of a package is not explicitly supported.

## Installation

`cinterpolate` is now on CRAN and can be installed with

```r
install.packages("cinterpolate")
```

### Development version


After that, install with

```r
install.packages(
  "orderly2",
  repos = c("https://mrc-ide.r-universe.dev", "https://cloud.r-project.org"))
```

If you install from source, this package requires a fortran compiler because it uses LAPACK and BLAS, despite being only C code.

* **macOS** Install Xcode, confirm the command line tools are installed and then install gfortran following [these instructions](https://cran.r-project.org/bin/macosx/tools/)
* **windows** [Rtools](https://cran.r-project.org/bin/windows/Rtools/) includes gfortran
* **linux** Something like `apt-get install gfortran` depending on your platform

## Usage

``` c
#include <cinterpolate/cinterpolate.h>
```

Allocate an object to perform interpolation with.  `nx` and `x` are the size and values of the function to be interpolated, while `ny` is the number of functions to be simultaneously (but independently) interpolateed and `y` is the values for these.  If `ny > 1`, then the values of `y` are as an R matrix with `nx` rows and `ny` columns (the first `nx` values are the first function, the second `nx` are the second, and so on).  The final two are booleans: `fail_on_extrapolate` throws an error if extrapolation is requested, and `auto_free` uses `R_alloc()` rather than `Calloc` allowing automatic cleanup.

``` c
void *obj = cinterpolate_alloc(type, nx, ny, x, y,
                               fail_on_extrapolate, auto_free);
```

With the interpolation function, an input value of `xout` and given some storage `yout` of length `ny`, determine `f(xout)` with

``` c
cinterpolate_eval(xout, obj, yout);
```

Once done the object must be freed with


```
cinterpolate_free(obj);
```

### Further package setup

Somewhere in the package you must include `cinterpolate.c` as

``` c
#include <cinterpolate/cinterpolate.h>
```

but this must be included **only once** or linking will fail.  If you only use the interpolation in one place, you can use `cinterpolate.c` rather than `cinterpolate.h`.  If you use interpolation in more than once place, I recommend a file `src/cinterpolate.c` containing

``` c
#include <cinterpolate/cinterpolate.c>
```

Be sure to include in your `DESCRIPTION` a line

```
LinkingTo: cinterpolate
```

`cinterpolate` takes advantage of BLAS for matrix multiplication, so you may need a Makevars that includes

```make
PKG_LIBS = ${LAPACK_LIBS} ${BLAS_LIBS} ${FLIBS}
```

### Example

See [`inst/example`](inst/example) for a full example of using `cinterpolate` within a package

## License

MIT + file LICENSE © Imperial College of Science, Technology and Medicine

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md).
By participating in this project you agree to abide by its terms.
