## From orderly:R/util.R
system3 <- function(command, args) {
  res <- suppressWarnings(system2(command, args, stdout = TRUE, stderr = TRUE))
  code <- attr(res, "status") %||% 0
  attr(res, "status") <- NULL
  list(success = code == 0,
       code = code,
       output = res)
}

`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}

with_wd <- function(path, code) {
  owd <- setwd(path)
  on.exit(setwd(owd))
  force(code)
}
