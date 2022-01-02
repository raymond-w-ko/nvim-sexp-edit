.PHONY: deps compile test

default: compile

deps:
	scripts/dep.sh Olical aniseed origin/master

compile:
	deps/aniseed/scripts/compile.sh
	deps/aniseed/scripts/embed.sh aniseed nvim-sexp-edit

test:
	deps/aniseed/scripts/test.sh
