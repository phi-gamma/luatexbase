# Makefile for luatexbase

NAME = luatexbase
DTX = $(wildcard luatexbase*.dtx)
DOC = $(patsubst %.dtx, %.pdf, $(DTX))
DTXSTY = lltxb-dtxstyle.tex

# Files grouped by generation mode
UNPACKED_MCB = luatexbase-mcb.sty mcb.lua \
			test-mcb-latex.tex test-mcb-plain.tex \
			test-mcb.lua $(TEST_MCB)
UNPACKED_REGS = luatexbase-regs.sty \
			test-regs-plain.tex test-regs-latex.tex
UNPACKED_ATTR = luatexbase-attr.sty attr.lua \
			test-attr-plain.tex test-attr-latex.tex
UNPACKED_CCTB = luatexbase-cctb.sty cctb.lua \
			test-cctb-plain.tex test-cctb-latex.tex
UNPACKED_LOADER = luatexbase-loader.sty luatexbase.loader.lua \
			test-loader-plain.tex test-loader-latex.tex \
			$(TEST_LOADER).lua test-loader.sub.lua
UNPACKED_MODUTILS = luatexbase-modutils.sty modutils.lua test-modutils.lua \
			test-modutils-plain.tex test-modutils-latex.tex
UNPACKED_COMPAT = luatexbase-compat.sty \
			test-compat-plain.tex test-compat-latex.tex
UNPACKED_BASE = luatexbase.sty test-base-plain.tex test-base-latex.tex
UNPACKED_LUATEX = luatex.sty test-luatex1.tex test-luatex2.tex \
		  test-luatex3.tex test-luatex4.tex test-luatex5.tex
UNPACKED = $(UNPACKED_MCB) $(UNPACKED_REGS) $(UNPACKED_ATTR) $(UNPACKED_CCTB) \
		   $(UNPACKED_LOADER) $(UNPACKED_MODUTILS) $(UNPACKED_COMPAT) \
		   $(UNPACKED_BASE) $(UNPACKED_LUATEX)
UNPACKEDTL = $(UNPACKED_MCB) $(UNPACKED_REGS) $(UNPACKED_ATTR) $(UNPACKED_CCTB) \
		   $(UNPACKED_LOADER) $(UNPACKED_MODUTILS) $(UNPACKED_COMPAT) \
		   $(UNPACKED_BASE)
COMPILED = $(DOC)
GENERATED = $(COMPILED) $(UNPACKED)
SOURCE = $(DTX) $(DTXSTY) README TODO NEWS Makefile

# used for check
TEST_LOADER = test-loader
TMP_LOADER = $(TEST_LOADER).tex
TEST_MCB = test-mcb-aux.tex

# Files grouped by installation location
RUNFILES = $(filter-out test-%, $(UNPACKEDTL))
DOCFILES = $(DOC) $(filter test-%, $(UNPACKEDTL)) README TODO NEWS
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

INSTALL_RUNFILES = @mkdir -p $(RUNDIR) && cp $(RUNFILES) $(RUNDIR)
INSTALL_DOCFILES = @mkdir -p $(DOCDIR) && cp $(DOCFILES) $(DOCDIR)
INSTALL_SRCFILES = @mkdir -p $(SRCDIR) && cp $(SRCFILES) $(SRCDIR)

TESTENV = TEXINPUTS=.:$(TEXMFROOT)/tex//:

CTAN_ZIP = $(NAME).zip
TDS_ZIP = $(NAME).tds.zip
ZIPS = $(CTAN_ZIP) $(TDS_ZIP)

DO_TEX = tex --interaction=batchmode $< >/dev/null
DO_LATEXMK = latexmk -pdf -silent $< >/dev/null

# Main targets definition
all: $(GENERATED)
check: check-regs check-attr check-cctb check-loader check-modutils check-mcb \
       check-compat check-base check-luatex
doc: $(COMPILED)
unpack: $(UNPACKED)
ctan: check $(CTAN_ZIP)
tds: $(TDS_ZIP) Makefile
world: all ctan

%.pdf: %.dtx $(DTXSTY)
	$(DO_LATEXMK)

luatexbase.%.lua: %.lua
	ln -sf $< $@

$(UNPACKED_MCB): luatexbase-mcb.dtx
	$(DO_TEX)
	echo "\\\relax" > $(TEST_MCB)

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

$(UNPACKED_COMPAT): luatexbase-compat.dtx
	$(DO_TEX)

$(UNPACKED_BASE): luatexbase.dtx
	$(DO_TEX)

$(UNPACKED_LUATEX): luatex.dtx
	$(DO_TEX)

check-regs: $(UNPACKED_REGS)
	luatex --interaction=batchmode test-regs-plain.tex >/dev/null
	lualatex --interaction=batchmode test-regs-latex.tex >/dev/null

check-attr: install-runfiles
	$(TESTENV) luatex --interaction=batchmode test-attr-plain.tex >/dev/null
	$(TESTENV) lualatex --interaction=batchmode test-attr-latex.tex >/dev/null

check-cctb: install-runfiles
	$(TESTENV) luatex --interaction=batchmode test-cctb-plain.tex >/dev/null
	$(TESTENV) lualatex --interaction=batchmode test-cctb-latex.tex >/dev/null

check-loader: install-runfiles
	echo "this is no lua code" > $(TMP_LOADER)
	$(TESTENV) luatex --interaction=batchmode test-loader-plain.tex >/dev/null
	$(TESTENV) lualatex --interaction=batchmode test-loader-latex.tex >/dev/null

check-modutils: install-runfiles
	$(TESTENV) luatex --interaction=batchmode test-modutils-plain.tex >/dev/null
	$(TESTENV) lualatex --interaction=batchmode test-modutils-latex.tex >/dev/null

check-mcb: install-runfiles $(UNPACKED_MCB)
	$(TESTENV) luatex --interaction=batchmode test-mcb-plain.tex >/dev/null
	$(TESTENV) lualatex --interaction=batchmode test-mcb-latex.tex >/dev/null

check-compat: $(UNPACKED_COMPAT)
	luatex --interaction=batchmode test-compat-plain.tex >/dev/null
	lualatex --interaction=batchmode test-compat-latex.tex >/dev/null

check-base: $(UNPACKED_BASE)
	luatex --interaction=batchmode test-base-plain.tex >/dev/null
	lualatex --interaction=batchmode test-base-latex.tex >/dev/null

check-luatex: install-runfiles
	$(TESTENV) luatex --interaction=batchmode test-luatex1.tex >/dev/null
	$(TESTENV) lualatex --interaction=batchmode test-luatex2.tex >/dev/null
	#$(TESTENV) lualatex --interaction=batchmode test-luatex3.tex >/dev/null
	$(TESTENV) lualatex --interaction=batchmode test-luatex4.tex >/dev/null
	$(TESTENV) luatex --interaction=batchmode test-luatex5.tex >/dev/null

$(CTAN_ZIP): $(SOURCE) $(COMPILED) $(TDS_ZIP)
	@echo "Making $@ for CTAN upload."
	@$(RM) -rf -- $@ ./luatexbase
	@mkdir ./luatexbase
	@cp $(filter-out $(TDS_ZIP),$^) ./luatexbase/
	@zip -r9 $@ luatexbase/ $(TDS_ZIP) >/dev/null

$(TDS_ZIP): TEXMFROOT=./tmp-texmf
$(TDS_ZIP): $(ALL_FILES)
	@echo "Making TDS-ready archive $@."
	@$(RM) -- $@
	$(INSTALL_RUNFILES)
	$(INSTALL_DOCFILES)
	$(INSTALL_SRCFILES)
	@cd $(TEXMFROOT) && zip -9 ../$@ -r . >/dev/null
	@$(RM) -r -- $(TEXMFROOT)

.PHONY: install manifest clean mrproper install-runfiles

install: $(ALL_FILES)
	@echo "Installing in '$(TEXMFROOT)'."
	$(INSTALL_RUNFILES)
	$(INSTALL_DOCFILES)
	$(INSTALL_SRCFILES)

install-runfiles: $(RUNFILES)
	$(INSTALL_RUNFILES)

manifest: 
	@echo "Source files:"
	@for f in $(SOURCE); do echo $$f; done
	@echo ""
	@echo "Derived files:"
	@for f in $(GENERATED); do echo $$f; done

clean: 
	@latexmk -silent -c *.dtx >/dev/null
	@#for non-latexmk runs
	@$(RM) -- *.log

mrproper: clean
	@$(RM) -- $(GENERATED) $(ZIPS) $(TMP_LOADER)
	@$(RM) -r $(TEXMFROOT)

