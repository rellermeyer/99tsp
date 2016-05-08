CC:=rustc
CFLAGS:=
RUNCMD:=./2opt $(TEST_FILE).tsp
RUNFLAGS:=

include ../../Rules.mk
