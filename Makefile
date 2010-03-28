# Makefile for luatexbase

NAME = luatexbase
DTX = $(wildcard *.dtx)
DOC = $(patsubst %.dtx, %.pdf, $(DTX))
DTXSTY = lltxb-dtxstyle.tex
LOADER_RUN = luatexbase-loader.sty luatexbase.loader.lua
MOD_RUN = luatexbase-modutils.sty modutils.lua
LINKS = luatexbase.attr.lua luatexbase.cctb.lua luatexbase.modutils.lua

# Files grouped by generation mode
UNPACKED_MCB = luamcallbacks.lua \
			   test-callbacks-latex.tex test-callbacks-plain.tex
UNPACKED_REGS = luatexbase-regs.sty \
				test-regs-plain.tex test-regs-latex.tex
UNPACKED_ATTR = luatexbase-attr.sty attr.lua \
				test-attr-plain.tex test-attr-latex.tex
UNPACKED_CCTB = luatexbase-cctb.sty cctb.lua \
				test-cctb-plain.tex test-cctb-latex.tex
UNPACKED_LOADER = $(LOADER_RUN) \
				test-loader-plain.tex test-loader-latex.tex
UNPACKED_MODUTILS = $(MOD_RUN) test-modutils.lua \
				test-modutils-plain.tex test-modutils-latex.tex
UNPACKED = $(UNPACKED_MCB) $(UNPACKED_REGS) $(UNPACKED_ATTR) $(UNPACKED_CCTB) \
		   $(UNPACKED_LOADER) $(UNPACKED_MODUTILS)
COMPILED = $(DOC)
GENERATED = $(COMPILED) $(UNPACKED)
SOURCE = $(DTX) $(DTXSTY) README TODO Changes Makefile

# Files grouped by installation location
RUNFILES = $(filter-out test-%, $(UNPACKED))
DOCFILES = $(DOC) $(filter test-%, $(UNPACKED)) README TODO Changes
SRCFILES = $(DTX) Makefile

# The following definitions should be equivalent
# ALL_FILES = $(RUNFILES) $(DOCFILES) $(SRCFILES)
ALL_FILES = $(GENERATED) $(SOURCE)

# Installation locations
FORMAT = luatex
RUNDIR = $(TEXMFROOT)/tex/$(FORMAT)/$(NAME)
DOCDIR = $(TEXMFROOT)/doc/$(FORMAT)/$(NAME)
SRCDIR = $(TEXMFROOT)/source/$(FORMAT)/$(NAME)
TEXMFROOT = ./texmf

CTAN_ZIP = $(NAME).zip
TDS_ZIP = $(NAME).tds.zip
ZIPS = $(CTAN_ZIP) $(TDS_ZIP)

DO_TEX = tex --interaction=batchmode $< >/dev/null
DO_PDFLATEX = pdflatex --interaction=batchmode $< >/dev/null
DO_MAKEINDEX = makeindex -s gind.ist $(subst .dtx,,$<) >/dev/null 2>&1

# Main targets definition
all: $(GENERATED)
check: check-regs check-attr check-cctb check-loader check-modutils check-mcb
doc: $(COMPILED)
unpack: $(UNPACKED)
ctan: check $(CTAN_ZIP)
tds: $(TDS_ZIP) Makefile
world: all ctan

%.pdf: %.dtx $(DTXSTY)
	$(DO_PDFLATEX)
	$(DO_MAKEINDEX) || true
	$(DO_PDFLATEX)
	$(DO_PDFLATEX)

luatexbase.%.lua: %.lua
	ln -s $< $@

$(UNPACKED_MCB): luamcallbacks.dtx
	$(DO_TEX)

$(UNPACKED_REGS): luatexbase-regs.dtx
	$(DO_TEX)

$(UNPACKED_ATTR): luatexbase-attr.dtx
	$(DO_TEX)

$(UNPACKED_CCTB): luatexbase-cctb.dtx
	$(DO_TEX)

$(UNPACKED_LOADER): luatexbase-loader.dtx
	$(DO_TEX)

$(UNPACKED_MODUTILS): luatexbase-modutils.dtx
	$(DO_TEX)

check-regs: $(UNPACKED_REGS)
	luatex --interaction=batchmode test-regs-plain.tex >/dev/null
	lualatex --interaction=batchmode test-regs-latex.tex >/dev/null

check-attr: $(UNPACKED_ATTR) $(LOADER_RUN) $(LINKS)
	luatex --interaction=batchmode test-attr-plain.tex >/dev/null
	lualatex --interaction=batchmode test-attr-latex.tex >/dev/null

check-cctb: $(UNPACKED_CCTB) $(LOADER_RUN) $(LINKS)
	luatex --interaction=batchmode test-cctb-plain.tex >/dev/null
	lualatex --interaction=batchmode test-cctb-latex.tex >/dev/null

check-loader: $(UNPACKED_LOADER)
	luatex --interaction=batchmode test-loader-plain.tex >/dev/null
	lualatex --interaction=batchmode test-loader-latex.tex >/dev/null

check-modutils: $(UNPACKED_MODUTILS) $(LOADER_RUN) $(LINKS)
	luatex --interaction=batchmode test-modutils-plain.tex >/dev/null
	lualatex --interaction=batchmode test-modutils-latex.tex >/dev/null

check-mcb: $(UNPACKED_MCB) $(LOADER_RUN) $(MOD_RUN) $(LINKS)
	luatex --interaction=batchmode test-callbacks-plain.tex >/dev/null
	lualatex --interaction=batchmode test-callbacks-latex.tex >/dev/null

$(CTAN_ZIP): $(SOURCE) $(COMPILED) $(TDS_ZIP)
	@echo "Making $@ for CTAN upload."
	@$(RM) -- $@
	@zip -9 $@ $^ >/dev/null

define run-install
@mkdir -p $(RUNDIR) && cp $(RUNFILES) $(RUNDIR)
@mkdir -p $(DOCDIR) && cp $(DOCFILES) $(DOCDIR)
@mkdir -p $(SRCDIR) && cp $(SRCFILES) $(SRCDIR)
endef

$(TDS_ZIP): TEXMFROOT=./tmp-texmf
$(TDS_ZIP): $(ALL_FILES)
	@echo "Making TDS-ready archive $@."
	@$(RM) -- $@
	$(run-install)
	@cd $(TEXMFROOT) && zip -9 ../$@ -r . >/dev/null
	@$(RM) -r -- $(TEXMFROOT)

.PHONY: install manifest clean mrproper

install: $(ALL_FILES)
	@echo "Installing in '$(TEXMFROOT)'."
	$(run-install)

manifest: 
	@echo "Source files:"
	@for f in $(SOURCE); do echo $$f; done
	@echo ""
	@echo "Derived files:"
	@for f in $(GENERATED); do echo $$f; done

clean: 
	@$(RM) -- *.log *.aux *.toc *.idx *.ind *.ilg *.out test-*.pdf

mrproper: clean
	@$(RM) -- $(GENERATED) $(ZIPS) $(LINKS)

