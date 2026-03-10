.PHONY: build test lint format format-check sim help clean

PDC = pdc
SIMULATOR = $(PLAYDATE_SDK_PATH)/bin/Playdate Simulator.app/Contents/MacOS/Playdate Simulator
SOURCE_DIR = source
BUILD_DIR = builds
PDX_FILE = $(BUILD_DIR)/stillwater-approach.pdx

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

clean:
	rm -rf $(BUILD_DIR)
