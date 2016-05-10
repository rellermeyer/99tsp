CC:=scalac
CFLAGS:=
OBJ:=$(SRC:.scala=.class)
RUNCMD:=scala
RUNFLAGS:=-cp . $(OBJ:.class=)

include ../../Rules.mk