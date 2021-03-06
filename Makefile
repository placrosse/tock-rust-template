
# various configurations
ARCH = cortex-m4
BUILDDIR = target/$(TARGET)/release/
PACKAGE_NAME ?= tock-template
TARGET = thumbv7em-tock-eabi

# verbose/quiet mode. If environment variable V is non-empty, be verbose
ifneq ($(V),)
Q=
VERBOSE = --verbose
else
Q=@
VERBOSE =
endif

# create_tab script
CREATE_TAB ?= tools/tab/create_tab.py

# ELF2TBF tool and arguments
ELF2TBF ?= cargo run --manifest-path tools/elf2tbf/Cargo.toml --
ELF2TBF_ARGS += -n $(PACKAGE_NAME)

# xargo tool
XARGO ?= xargo

# build rules
.PHONY: all
all: $(BUILDDIR)/$(PACKAGE_NAME).tab

# Make can't reasonably find all dependencies (i.e. changhing Cargo.toml
# requires a rebuild), just let xargo do it's job every time
.PHONY: FORCE_XARGO

.PHONY: clean
clean:
	$(Q)$(XARGO) clean $(VERBOSE)

.PHONY: debug
debug:
	@echo Sorry, relocation-aware debug information is only available for the
	@echo C runtime presently. Apologies for the misleading kernel message

$(BUILDDIR)/$(PACKAGE_NAME): src/main.rs FORCE_XARGO
	$(Q)$(XARGO) build --target $(TARGET) $(VERBOSE) --release

$(BUILDDIR)/$(PACKAGE_NAME).elf: $(BUILDDIR)/$(PACKAGE_NAME)
	$(Q)cp $< $@

$(BUILDDIR)/$(ARCH).bin: $(BUILDDIR)/$(PACKAGE_NAME).elf
	$(Q)$(ELF2TBF) $(ELF2TBF_ARGS) -o $@ $< $(VERBOSE)

$(BUILDDIR)/$(PACKAGE_NAME).tab: $(BUILDDIR)/$(ARCH).bin
	$(Q)$(CREATE_TAB) $@ $(PACKAGE_NAME) $^

