#!/usr/bin/Rscript --vanilla

# Compiles all .Rmd files in _R directory into .md files in Pages directory, if the input file is older than the output file.

# This script is a modified version of an example here: http://varianceexplained.org/pages/workflow/

rm(list = ls())

setwd('~/site')

KnitPost <- function(input, outfile, base.url="/") {
  require(knitr);
  opts_knit$set(base.url = base.url)
  fig.path <- paste0("img/", sub(".Rmd$", "", basename(input)), "/")
  opts_chunk$set(fig.path = fig.path)
  opts_chunk$set(fig.cap = "")
  render_jekyll(highlight = 'pygments')
  knit(input, outfile, envir = parent.frame())
}

for (infile in list.files("_rmd", pattern="*.Rmd", full.names=TRUE)) {
  outfile = paste0("_posts/", Sys.Date(), "-", sub(".Rmd$", ".md", basename(infile)))
  
  # knit only if the input file is the last one modified
  if (!file.exists(outfile) | file.info(infile)$mtime > file.info(outfile)$mtime) {
    KnitPost(infile, outfile)
  }
}
