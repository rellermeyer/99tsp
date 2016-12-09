# Specify how to compile + how to run
OBJ:=tsp.jar
CC:=kotlinc
CFLAGS:=-include-runtime -d $(OBJ)
RUNCMD:=java
RUNFLAGS:=-jar $(OBJ)

# include the top level Rules.mk (note this is called from the context
# of the Makefile in a directory below this one)
include ../../Rules.mk