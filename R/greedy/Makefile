.SUFFIXES: .R


TSPLIB_MIRROR:=http://comopt.ifi.uni-heidelberg.de/software/TSPLIB95
TSPLIB:=$(TSPLIB_MIRROR)/tsp
TSPLIB_XML:=$(TSPLIB_MIRROR)/XML-TSPLIB/instances
TSPLIB_280:=a280

DATA_DIR:=data

TEST_FILE:=$(CURDIR)/$(DATA_DIR)/$(TSPLIB_280)


MAIN = master
RFILES = $(RNWINCLUDES:=.R)

R: $(RFILES)

view: all
    acroread $(MAIN).pdf &

.Rnw.R:
    R CMD Stangle $<

clean:
    rm -fv $(RFILES)
    rm -fv *.aux *.dvi *.log *.toc *.bak *~ *.blg *.bbl *.lot *.lof
    rm -fv *.nav *.snm *.out *.pyc \#*\# _region_* _tmp.* *.vrb
    rm -fv Rplots.pdf *.RData
