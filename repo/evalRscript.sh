#!/bin/sh
#See:
#   http://stat.ethz.ch/R-manual/R-devel/library/utils/html/Rscript.html
#and:
#   http://stackoverflow.com/questions/16005261/how-to-source-an-r-script-that-read-stdin

cat $1 |R -q --vanilla --slave -e "source(\"${2}\")"

