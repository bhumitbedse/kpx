PREFIX     ?= $(HOME)/.local
SYSTEM_PREFIX ?= /usr/local
BINARY     = kpx
BINDIR     = $(PREFIX)/bin
SYSTEM_BINDIR = $(SYSTEM_PREFIX)/bin

.PHONY: all install install-system uninstall uninstall-system check help

all: check

# ── Check script syntax ───────────────────────────────────────────────────────
check:
	@echo "Checking script syntax..."
	@bash -n $(BINARY) && echo "✔  $(BINARY): syntax OK"

# ── Install to user local bin (~/.local/bin) ──────────────────────────────────
install: check
	@mkdir -p $(BINDIR)
	@install -m 755 $(BINARY) $(BINDIR)/$(BINARY)
	@echo "✔  Installed to $(BINDIR)/$(BINARY)"
	@echo ""
	@echo "Make sure $(BINDIR) is in your PATH:"
	@echo "  export PATH=\"\$$HOME/.local/bin:\$$PATH\""
	@echo ""
	@echo "Run 'kpx --init' to create your config file."

# ── Install to system bin (/usr/local/bin) — requires sudo ───────────────────
install-system: check
	@install -m 755 $(BINARY) $(SYSTEM_BINDIR)/$(BINARY)
	@echo "✔  Installed to $(SYSTEM_BINDIR)/$(BINARY)"

# ── Uninstall from user local bin ─────────────────────────────────────────────
uninstall:
	@rm -f $(BINDIR)/$(BINARY)
	@echo "✔  Removed $(BINDIR)/$(BINARY)"

# ── Uninstall from system bin ─────────────────────────────────────────────────
uninstall-system:
	@rm -f $(SYSTEM_BINDIR)/$(BINARY)
	@echo "✔  Removed $(SYSTEM_BINDIR)/$(BINARY)"

# ── Show help ─────────────────────────────────────────────────────────────────
help:
	@echo "kpx Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make install          Install to ~/.local/bin (no sudo)"
	@echo "  make install-system   Install to /usr/local/bin (requires sudo)"
	@echo "  make uninstall        Remove from ~/.local/bin"
	@echo "  make uninstall-system Remove from /usr/local/bin"
	@echo "  make check            Check script syntax"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX=$(PREFIX)  (override with: make install PREFIX=/custom/path)"
