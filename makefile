.DEFAULT_GOAL := help

.PHONY: test
test:
	./bin/runtests

.PHONY: failtest
failtest:
	./bin/runtests ./tests/fail*.zsh

.PHONY: help
help:
	@echo "Usage:  make <command>"
	@echo ""
	@echo "Commands:"
	@echo "  help  shows this message"
	@echo "  test  run unit tests"
