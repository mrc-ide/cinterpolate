PACKAGE := $(shell grep '^Package:' DESCRIPTION | sed -E 's/^Package:[[:space:]]+//')
RSCRIPT = Rscript --no-init-file

all: install

test:
	${RSCRIPT} -e 'library(methods); devtools::test()'

test_leaks: .valgrind_ignore
	R -d 'valgrind --leak-check=full --suppressions=.valgrind_ignore' -e 'devtools::test()'

.valgrind_ignore:
	R -d 'valgrind --leak-check=full --gen-suppressions=all --log-file=$@' -e 'library(testthat)'
	sed -i '/^=/ d' $@

roxygen:
	@mkdir -p man
	${RSCRIPT} -e "library(methods); devtools::document()"

install:
	R CMD INSTALL .

build:
	R CMD build .

check:
	_R_CHECK_CRAN_INCOMING_=FALSE make check_all

check_all:
	${RSCRIPT} -e "rcmdcheck::rcmdcheck(args = c('--as-cran', '--no-manual'))"

clean:
	rm -f src/*.o src/*.so src/*.dll
	rm -rf src/cinterpolate.so.dSYM
	rm -f tests/testthat/testing/*.o tests/testthat/testing/*.so tests/testthat/testing/*.dll

autodoc:
	${RSCRIPT} autodoc.R process

pkgdown:
	${RSCRIPT} -e "library(methods); pkgdown::build_site()"

website: pkgdown
	./scripts/update_web.sh

README.md: README.Rmd
	Rscript -e 'library(methods); devtools::load_all(); knitr::knit("README.Rmd")'
	sed -i.bak 's/[[:space:]]*$$//' $@
	rm -f $@.bak

vignettes/%.Rmd: vignettes_src/%.R
	${RSCRIPT} -e 'library(sowsear); sowsear("$<", output="$@")'
vignettes: vignettes/cinterpolate.Rmd
	${RSCRIPT} -e 'library(methods); devtools::build_vignettes()'

# No real targets!
.PHONY: all test document install vignettes
