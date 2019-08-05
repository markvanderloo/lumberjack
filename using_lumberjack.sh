#!/bin/bash

function finish {
  cd ${oldwd}
}
trap finish EXIT

oldwd=`pwd`

cd pkg/vignettes

R -e "Sweave('using_lumberjack.Rnw')"
pdflatex using_lumberjack.tex
pdflatex using_lumberjack.tex
pdflatex using_lumberjack.tex

evince using_lumberjack.pdf &



