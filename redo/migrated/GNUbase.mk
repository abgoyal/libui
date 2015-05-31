# 22 april 2015

OUTBASE = new
OUTDIR = out
OBJDIR = .obj

IDLFILES = \
	$(baseIDLFILES)

xHFILES = \
	uipriv.h \
	$(IDLFILES:%.idl=$(OUTDIR)/%.h) \
	$(baseHFILES)

OFILES = \
	$(baseCFILES:%.c=$(OBJDIR)/%.o) \
	$(baseMFILES:%.m=$(OBJDIR)/%.o) \
	$(baseRCFILES:%.rc=$(OBJDIR)/%.o)

xCFLAGS = \
	-g \
	-Wall -Wextra \
	-Wno-unused-parameter \
	-Wno-switch \
	--std=c99 \
	$(CFLAGS) \
	$(archmflag) \
	$(baseCFLAGS)

# windres doesn't support -m
xRCFLAGS = \
	$(RCFLAGS) \
	$(baseRCFLAGS)

xLDFLAGS = \
	-g \
	$(LDFLAGS) \
	$(archmflag) \
	$(baseLDFLAGS)

OUT = $(OUTDIR)/$(OUTBASE)$(baseSUFFIX)

$(OUT): $(OFILES) | $(OUTDIR)/.phony
	@$(CC) -o $(OUT) $(OFILES) $(xLDFLAGS)
	@echo ====== Linked $(OUT)

.SECONDEXPANSION:
$(OBJDIR)/%.o: %.c $(xHFILES) | $$(dir $$@).phony
	@$(CC) -o $@ -c $< $(xCFLAGS)
	@echo ====== Compiled $<

$(OBJDIR)/%.o: %.m $(xHFILES) | $$(dir $$@).phony
	@$(CC) -o $@ -c $< $(xCFLAGS)
	@echo ====== Compiled $<

$(OBJDIR)/%.o: %.rc $(xHFILES) | $$(dir $$@).phony
	@$(RC) $(xRCFLAGS) $< $@
	@echo ====== Compiled $<

# see http://www.cmcrossroads.com/article/making-directories-gnu-make
%/.phony:
	@mkdir -p $(dir $@)
	@touch $@
.PRECIOUS: %/.phony

$(OUTDIR)/%.h: %.idl tools/idl2h.go | $(OUTDIR)/.phony
	@go run tools/idl2h.go -extern _UI_EXTERN -guard __UI_UI_H__ < $< > $@
	@echo ====== Generated `basename $@`
.PRECIOUS: $(OUTDIR)/%.h

clean:
	rm -rf $(OUTDIR) $(OBJDIR) z*
.PHONY: clean