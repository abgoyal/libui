# 22 april 2015

OUTBASE = new
OUTDIR = out
OBJDIR = .obj

xHFILES = \
	ui.h \
	$(baseHFILES)

OFILES = \
	$(baseCFILES:%.c=$(OBJDIR)/%.o) \
	$(baseMFILES:%.m=$(OBJDIR)/%.o)

xCFLAGS = \
	-g \
	-Wall -Wextra \
	-Wno-unused-parameter \
	-Wno-switch \
	--std=c99 \
	$(CFLAGS) \
	$(archmflag) \
	$(baseCFLAGS)

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

# see http://www.cmcrossroads.com/article/making-directories-gnu-make
%/.phony:
	@mkdir -p $(dir $@)
	@touch $@
.PRECIOUS: %/.phony

ui.h: ui.idl
	@go run tools/idl2h.go -extern _UI_EXTERN -guard __UI_UI_H__ < ui.idl > ui.h
	@echo ====== Generated ui.h

clean:
	rm -rf $(OUTDIR) $(OBJDIR) ui.h
.PHONY: clean
