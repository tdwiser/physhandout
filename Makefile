.DEFAULT_GOAL = all
OUTDIR = aux
PDFDIR = pdfs
PDFDIR_SOLN = pdfs/solns

LATEXMK = latexmk -pdf -outdir=$(OUTDIR)

TEXS := $(shell find . -type f -name '*.tex')

-include .targets
SOLN_TARGETS := $(TARGETS:.pdf=_soln.pdf)

.PHONY: all, clean, FORCE_MAKE
	
$(OUTDIR)/main.toh: $(TEXS) physhandout.sty | $(OUTDIR)
	@echo Rebuilding handout index...
	@pdflatex -output-directory=$(OUTDIR) main

.targets: $(OUTDIR)/main.toh | $(OUTDIR)
	@echo hello from .targets: $(TARGETS)
	@echo TARGETS := \\ > .targets
	@sed -e 's/^\\@handoutentry{\([^}]*\)}{\([^}]*\)}{\([^}]*\)}{\([^}]*\)}{\(.*\)}$$/\1_\4_\2.pdf\\/' $(OUTDIR)/main.toh >> .targets
	@echo >> .targets
	@echo >> .targets
	@echo \\n CLASSES := $$\(sort \\ >> .targets
	@sed -e 's/^\\@handoutentry{\([^}]*\)}{\([^}]*\)}{\([^}]*\)}{\([^}]*\)}{\(.*\)}$$/\1\\/' $(OUTDIR)/main.toh >> .targets
	@echo \) >> .targets

all: $(TARGETS) $(SOLN_TARGETS)

$(OUTDIR):
	@mkdir -p $(OUTDIR)

$(PDFDIR):
	@mkdir -p $(PDFDIR)

$(PDFDIR_SOLN):
	@mkdir -p $(PDFDIR_SOLN)

clean:
	for f in $(TARGETS:.pdf=) $(SOLN_TARGETS:.pdf=); do $(LATEXMK) -C -jobname=$$f main.tex; done
	$(LATEXMK) -C main.tex
	rm $(OUTDIR)/*.toh

.SECONDEXPANSION:
$(CLASSES): $$(filter $$@_%, $(TARGETS)) $$(filter $$@, $(SOLN_TARGETS))

main.pdf: FORCE_MAKE | $(OUTDIR) $(PDFDIR)
	@$(LATEXMK) main.tex
	@echo Copying pdf...
	@cp -a $(OUTDIR)/main.pdf $(PDFDIR)

%_soln.pdf: FORCE_MAKE | $(OUTDIR) $(PDFDIR_SOLN)
	@$(LATEXMK) -jobname=$*_soln -pdflatex="pdflatex %O '\AtBeginDocument{$(shell class=`echo $@ | sed -e 's/^\([^_]*\)_.*$$/\1/'`;tag=`echo $@ | sed -e 's/^[^_]*_[^_]*_\(.*\)_soln.pdf$$/\1/'`; for c in $(CLASSES); do echo \\\\only$$c{}; done; echo \\\\only$$class{$$tag})}\PassOptionsToPackage{show}{solution}\input{main.tex}'" main.tex
	@cp -a $(OUTDIR)/$@ $(PDFDIR_SOLN)
	
%.pdf: FORCE_MAKE | $(OUTDIR) $(PDFDIR)
	@$(LATEXMK) -jobname=$* -pdflatex="pdflatex %O '\AtBeginDocument{$(shell class=`echo $@ | sed -e 's/^\([^_]*\)_.*$$/\1/'`;tag=`echo $@ | sed -e 's/^[^_]*_[^_]*_\(.*\).pdf$$/\1/'`; for c in $(CLASSES); do echo \\\\only$$c{}; done; echo \\\\only$$class{$$tag})}\PassOptionsToPackage{hide}{solution}\input{main.tex}'" main.tex
	@cp -a $(OUTDIR)/$@ $(PDFDIR)