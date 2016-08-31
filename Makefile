.DEFAULT_GOAL = all
OUTDIR = aux
PDFDIR = pdfs
PDFDIR_SOLN = pdfs/solns

LATEXMK = latexmk -pdf -outdir=$(OUTDIR)
LATEXMK_SOLN = $(LATEXMK) -pdflatex="pdflatex %O '\PassOptionsToPackage{solution}{physhandout}\input{%S}'"

TEXS := $(shell find . -type f -name '*.tex')

-include .targets
SOLN_TARGETS := $(TARGETS:.pdf=_soln.pdf)

.PHONY: all, clean, FORCE_MAKE
	
$(OUTDIR)/main.toh: $(TEXS) physhandout.sty
	@echo Rebuilding handout index...
	@pdflatex -output-directory=$(OUTDIR) main

.targets: $(OUTDIR)/main.toh
	@echo hello from .targets: $(TARGETS)
	@echo TARGETS := \\ > .targets
	@sed -e 's/^\\@handoutentry{\([^}]*\)}{\([^}]*\)}{\([^}]*\)}{\([^}]*\)}{\([^}]*\)}$$/\1_\4_\2.pdf\\/' $(OUTDIR)/main.toh >> .targets
	@echo \\n CLASSES := $$\(sort \\ >> .targets
	@sed -e 's/^\\@handoutentry{\([^}]*\)}{\([^}]*\)}{\([^}]*\)}{\([^}]*\)}{\([^}]*\)}$$/\1\\/' $(OUTDIR)/main.toh >> .targets
	@echo \) >> .targets

all: $(TARGETS) $(SOLN_TARGETS)
	@mkdir -p $(PDFDIR)
	@mkdir -p $(PDFDIR_SOLN)
	@echo Copying pdfs...
	@for f in $(TARGETS); do cp -a $(OUTDIR)/$$f $(PDFDIR); done
	@for f in $(SOLN_TARGETS); do cp -a $(OUTDIR)/$$f $(PDFDIR_SOLN); done

clean:
	for f in $(TARGETS:.pdf=) $(SOLN_TARGETS:.pdf=); do $(LATEXMK) -C -jobname=$$f main.tex; done
	$(LATEXMK) -C main.tex
	rm $(OUTDIR)/*.toh

.SECONDEXPANSION:
$(CLASSES): $$(filter $$@_%, $(TARGETS)) $$(filter $$@, $(SOLN_TARGETS))

main.pdf: FORCE_MAKE

%_soln.pdf: FORCE_MAKE
	@$(LATEXMK) -jobname=$*_soln -pdflatex="pdflatex %O '\AtBeginDocument{$(shell class=`echo $@ | sed -e 's/^\([^_]*\)_.*$$/\1/'`;tag=`echo $@ | sed -e 's/^[^_]*_[^_]*_\(.*\)_soln.pdf$$/\1/'`; for c in $(CLASSES); do echo \\\\only$$c{}; done; echo \\\\only$$class{$$tag})}\PassOptionsToPackage{solution}{physhandout}\input{main.tex}'" main.tex
	
%.pdf: FORCE_MAKE
	@$(LATEXMK) -jobname=$* -pdflatex="pdflatex %O '\AtBeginDocument{$(shell class=`echo $@ | sed -e 's/^\([^_]*\)_.*$$/\1/'`;tag=`echo $@ | sed -e 's/^[^_]*_[^_]*_\(.*\).pdf$$/\1/'`; for c in $(CLASSES); do echo \\\\only$$c{}; done; echo \\\\only$$class{$$tag})}\input{main.tex}'" main.tex