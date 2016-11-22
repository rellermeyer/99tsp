# Specify how to compile + how to run
CC:=javac
CFLAGS:=
OBJ:=$(SRC:.java=.class)
RUNCMD:=java
RUNFLAGS:=-cp . $(OBJ:.class=)

# include the top level Rules.mk (note this is called from the context
# of the Makefile in a directory below this one)
include ../../Rules.mk
