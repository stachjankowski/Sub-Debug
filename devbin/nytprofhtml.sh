#!/bin/bash

export NYTPROF=file=tmp/nytprof.out.bind_in_vars
perl -d:NYTProf t/bind_in_vars.t

export NYTPROF=file=tmp/nytprof.out.catch_error
perl -d:NYTProf t/catch_error.t 

export NYTPROF=file=tmp/nytprof.out.exclude
perl -d:NYTProf t/exclude.t 

export NYTPROF=file=tmp/nytprof.out.filter_variables
perl -d:NYTProf t/filter_variables.t  

export NYTPROF=file=tmp/nytprof.out.get_assignment_line
perl -d:NYTProf t/get_assignment_line.t  

export NYTPROF=file=tmp/nytprof.out.get_sort_sub
perl -d:NYTProf t/get_sort_sub.t  

export NYTPROF=file=tmp/nytprof.out.include
perl -d:NYTProf t/include.t  

export NYTPROF=file=tmp/nytprof.out.in_names
perl -d:NYTProf t/in_names.t  

export NYTPROF=file=tmp/nytprof.out.parse_line
perl -d:NYTProf t/parse_line.t

export NYTPROF=file=tmp/nytprof.out.return
perl -d:NYTProf t/return.t

nytprofmerge --out=nytprof.out tmp/nytprof.out.*
nytprofhtml --open
