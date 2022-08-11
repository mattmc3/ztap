.DEFAULT_GOAL := help

.PHONY: test
test:
	./tests/runtests

.PHONY: failtest
failtest:
	./tests/runtests ./tests/fail*.zsh

.PHONY: help
help:
	@echo "Usage:  make <command>"
	@echo ""
	@echo "Commands:"
	@echo "  help  shows this message"
	@echo "  test  run unit tests"
