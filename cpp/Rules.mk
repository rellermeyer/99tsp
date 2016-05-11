CC:=g++
OBJ:=$(SRC:.cpp=)
CFLAGS:= -o $(OBJ)
RUNCMD:= $(OBJ)
RUNFLAGS:=

include ../../Rules.mk
