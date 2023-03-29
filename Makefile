
doc: 
	R -s -e "pkgload::load_all('pkg');roxygen2::roxygenize('pkg')"

pkg: doc
	rm -f *.tar.gz
	R CMD build --compact-vignettes="gs+qpdf" pkg

check: doc
	rm -rf *.tar.gz
	R CMD build --compact-vignettes="gs+qpdf" pkg
	R CMD check *.tar.gz

cran: doc
	rm -rf *.tar.gz
	R CMD build --compact-vignettes="gs+qpdf" ./pkg
	R CMD check --as-cran *.tar.gz

install: doc
	rm -rf *.tar.gz
	R CMD build pkg
	R CMD INSTALL *.tar.gz

test: doc
	R -s -e "tinytest::build_install_test('pkg')"

manual: doc
	R CMD Rd2pdf --force -o manual.pdf ./pkg

revdep: pkg
	rm -rf revdep
	mkdir revdep
	mv *.tar.gz revdep
	R -s -e "out <- tools::check_packages_in_dir('revdep',reverse=list(which='most'),Ncpus=3); print(summary(out)); saveRDS(out, file='revdep/output.RDS')"


clean:
	rm -f pkg/vignettes/*.aux
	rm -f pkg/vignettes/*.log
	rm -f pkg/vignettes/*.out
	rm -f pkg/vignettes/using_lumberjack.pdf
	rm -f pkg/vignettes/*.toc
	rm -f pkg/vignettes/*.csv
	rm -rf *.Rcheck
	rm -rf revdep
	rm -f *.tar.gz

using:
	./using_lumberjack.sh


