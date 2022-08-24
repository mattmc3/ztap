.DEFAULT_GOAL := help
all : test test3 failtest help
.PHONY : all

test:
	./tools/runtests

test3:
	./tools/runtests3

failtest:
	./tools/runtests ./tests/fail*.zsh

help:
	@echo "Usage:  make <command>"
	@echo ""
	@echo "Commands:"
	@echo "  help   shows this message"
	@echo "  test   run unit tests"
	@echo "  test3  run ztap3 unit tests"
