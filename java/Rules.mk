CC:=javac
CFLAGS:=
OBJ:=$(SRC:.java=.class)
RUNCMD:=java
RUNFLAGS:=-cp . $(OBJ:.class=)

include ../../Rules.mk
