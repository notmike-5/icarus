.DELETE_ON_ERROR:

SHELL := /bin/bash
IVERILOG := iverilog -g2005-sv
VVP := vvp

RTL_SOURCES := $(wildcard *.sv)
RTL_TESTS := $(wildcard tb/*_tb.sv)
RTL_SIMS := $(patsubst tb/%.sv,build/%,$(RTL_TESTS))
RUN_ALL := $(RTL_SIMS:build/%=run/%)

all: $(RTL_SIMS)

build/%: tb/%.sv $(RTL_SOURCES) | build/waves
	$(IVERILOG) -o $@ $< $(RTL_SOURCES)

build/waves:
	mkdir -p $@

test: $(RUN_ALL)

$(RUN_ALL): run/%: build/%
	@echo "=== $* ==="
	@cd build && $(VVP) $*

clean:
	rm -rf build

.PHONY: all test clean $(RUN_ALL)
