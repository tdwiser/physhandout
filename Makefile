# IGNORE = main.tex ax_template.tex aY_test.tex
# TEXS = $(filter-out $(IGNORE), $(wildcard *.tex))
# PDFS := $(TEXS:.tex=.pdf)
# SOLNS := $(TEXS:.tex=_soln.pdf)

JOBS := $(shell ./outfiles.sh < main.tex)
TEXS := $(JOBS:=.tex)
PDFS := $(JOBS:=.pdf)
SOLNS := $(JOBS:=_soln.pdf)

OUTDIR = aux
PDFDIR = pdfs
PDFDIR_SOLN = pdfs/solns
LATEXMK = latexmk -pdf -outdir=$(OUTDIR)
LATEXMK_SOLN = $(LATEXMK) -pdflatex="pdflatex %O '\PassOptionsToPackage{solution}{physhandout}\input{%S}'"

SUBTEXS := $(addprefix $(OUTDIR)/, $(TEXS))

.SECONDARY: $(SUBTEXS)

all: $(PDFS) $(SOLNS)

$(OUTDIR)/%.tex: main.tex
	mkdir -p $(OUTDIR)
	./selectfile.sh -v jobname=$* < main.tex > $(OUTDIR)/$*.tex

%_soln.pdf: $(OUTDIR)/%.tex FORCE_MAKE
	$(LATEXMK_SOLN) -jobname="$*_soln" $(OUTDIR)/$* #latexmk -pdf -pdflatex="pdflatex %O '\PassOptionsToPackage{solution}{physhandout}\input{%S}'" -jobname="$*_soln" $*

%.pdf: $(OUTDIR)/%.tex FORCE_MAKE
	$(LATEXMK) $(OUTDIR)/$* #latexmk -pdf $*

pdfs: $(PDFS) $(SOLNS)
	mkdir -p $(PDFDIR)
	mkdir -p $(PDFDIR_SOLN)
	for f in $(PDFS); do cp -a $(OUTDIR)/$$f $(PDFDIR); done
	for f in $(SOLNS); do cp -a $(OUTDIR)/$$f $(PDFDIR_SOLN); done

# clean:
# 	$(LATEXMK) -c $(TEXS:.tex=)
# 	for tex in $(TEXS:.tex=); do $(LATEXMK_SOLN) -jobname=$${tex}_soln -c $$tex; done;

.PHONY: all, clean, pdfs, FORCE_MAKE
