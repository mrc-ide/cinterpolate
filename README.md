# cinterpolate

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Linux Build Status](https://travis-ci.org/mrc-ide/cinterpolate.svg?branch=master)](https://travis-ci.org/mrc-ide/cinterpolate)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/mrc-ide/cinterpolate?svg=true)](https://ci.appveyor.com/project/richfitz/cinterpolate)
[![codecov.io](https://codecov.io/github/mrc-ide/cinterpolate/coverage.svg?branch=master)](https://codecov.io/github/mrc-ide/cinterpolate?branch=master)

Simple interpolation functions designed to be used from C.  There is essentially no R support in this package, save code designed to be used by the package's own testing.  `cinterpolate` is designed to be used in package code only and modification for use outside of a package is not explicitly supported.

## Installation

Despite being only C code, this package requires a fortran compiler because it uses LAPACK and BLAS.

* **macOS** Install Xcode, confirm the command line tools are installed and rthen install gfortran following [these instructions](https://cran.r-project.org/bin/macosx/tools/)
* **windows** [Rtools](https://cran.r-project.org/bin/windows/Rtools/) includes gfortran
* **linux** Something like `apt-get install gfortran` depending on your platform

After that, install with

```r
drat:::add("mrc-ide")
install.packages("cinterpolate")
```

## Usage

``` c
#include <cinterpolate/cinterpolate.h>
```

Allocate an object to perform interpolation with.  `nx` and `x` are the size and values of the function to be interpolated, while `ny` is the number of functions to be simultaneously (but independently) interpolateed and `y` is the values for these.  If `ny > 1`, then the values of `y` are as an R matrix with `nx` rows and `ny` columns (the first `nx` values are the first function, the second `nx` are the second, and so on).

``` c
void *obj = cinterpolate_alloc(type, nx, ny, x, y);
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

MIT + file LICENSE © [Rich FitzJohn](https://github.com/richfitz).

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md).
By participating in this project you agree to abide by its terms.
