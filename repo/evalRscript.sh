#!/bin/sh
#See: http://stat.ethz.ch/R-manual/R-devel/library/utils/html/Rscript.html
ARG=( "$@" )
echo $ARG[0] | RScript $ARG[1] - 
