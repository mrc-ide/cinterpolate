# cinterpolate

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Linux Build Status](https://travis-ci.org/mrc-ide/cinterpolate.svg?branch=master)](https://travis-ci.org/mrc-ide/cinterpolate)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/mrc-ide/cinterpolate?svg=true)](https://ci.appveyor.com/project/mrc-ide/cinterpolate)
[![codecov.io](https://codecov.io/github/mrc-ide/cinterpolate/coverage.svg?branch=master)](https://codecov.io/github/mrc-ide/cinterpolate?branch=master)

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
