.PHONY: build test lint format format-check sim help clean release install install-hooks

PDC = pdc
SIMULATOR = $(PLAYDATE_SDK_PATH)/bin/Playdate Simulator.app/Contents/MacOS/Playdate Simulator
SOURCE_DIR = source
BUILD_DIR = builds
PDX_FILE = $(BUILD_DIR)/stillwater-approach.pdx
PDXINFO = $(SOURCE_DIR)/pdxinfo

# Default target
help:
	@echo "Stillwater Approach — Makefile targets:"
	@echo ""
	@echo "  make build          Build the .pdx file"
	@echo "  make test           Run test suite (busted)"
	@echo "  make lint           Run static analysis (luacheck)"
	@echo "  make format         Format code with stylua"
	@echo "  make format-check   Check formatting without changes"
	@echo "  make sim            Build and run simulator with logs"
	@echo "  make release        Bump version and tag release (requires VERSION=x.y.z)"
	@echo "  make install        Install dev dependencies (macOS/Linux)"
	@echo "  make install-hooks  Install git hooks (run once after cloning)"
	@echo "  make clean          Remove build artifacts"
	@echo "  make help           Show this message"

build:
	mkdir -p $(BUILD_DIR)
	$(PDC) $(SOURCE_DIR) $(PDX_FILE)

test:
	busted

lint:
	luacheck $(SOURCE_DIR) spec/

format:
	stylua $(SOURCE_DIR) spec/

format-check:
	stylua --check $(SOURCE_DIR) spec/

sim: build
	"$(SIMULATOR)" $(PDX_FILE)

release:
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION not specified. Usage: make release VERSION=x.y.z"; \
		exit 1; \
	fi
	@current_build=$$(grep buildNumber $(PDXINFO) | sed 's/buildNumber=//'); \
	new_build=$$(($$current_build + 1)); \
	sed -i.bak 's/version=.*/version=$(VERSION)/' $(PDXINFO); \
	sed -i.bak "s/buildNumber=.*/buildNumber=$$new_build/" $(PDXINFO); \
	rm $(PDXINFO).bak; \
	git add $(PDXINFO); \
	git commit -m "Release v$(VERSION)"; \
	git tag v$(VERSION); \
	echo ""; \
	echo "✓ v$(VERSION) tagged. To push:"; \
	echo "  git push origin HEAD && git push origin v$(VERSION)"

install: install-hooks
	@OS=$$(uname -s); \
	if [ "$$OS" = "Darwin" ]; then \
		echo "Installing via Homebrew..."; \
		brew install lua luarocks stylua jq; \
		luarocks install luacheck; \
		luarocks install busted; \
	elif [ "$$OS" = "Linux" ]; then \
		echo "Installing via apt + luarocks..."; \
		apt-get install -y lua5.4 luarocks jq unzip; \
		luarocks install luacheck; \
		luarocks install busted; \
		if ! command -v stylua >/dev/null 2>&1; then \
			STYLUA_VERSION=$$(curl -s https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest \
				| grep '"tag_name"' | sed 's/.*"tag_name": "\(.*\)".*/\1/'); \
			curl -sL "https://github.com/JohnnyMorganz/StyLua/releases/download/$${STYLUA_VERSION}/stylua-linux-x86_64.zip" \
				-o /tmp/stylua.zip; \
			unzip -o /tmp/stylua.zip -d /usr/local/bin/ stylua; \
			chmod +x /usr/local/bin/stylua; \
			rm /tmp/stylua.zip; \
		fi; \
	else \
		echo "Unsupported OS: $$OS"; exit 1; \
	fi

install-hooks:
	ln -sf ../../.claude/hooks/pre-commit.sh .git/hooks/pre-commit

clean:
	rm -rf $(BUILD_DIR)
