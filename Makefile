.PHONY: build test lint format format-check sim help clean release

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

clean:
	rm -rf $(BUILD_DIR)
