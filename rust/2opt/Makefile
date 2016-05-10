SRC:=2opt.rs
OBJ:=2opt
EXTENSION:=.tsp


# Optional: For array output, add -printarray to RUNFLAGS
# RUNFLAGS:=-printarray


compile: $(SRC)
	rustc $<

run: compile
	./2opt $(RUNFLAGS) a280.tsp

.PHONY: clean
clean:
	\rm 2opt


# If attempting to make and run from this directory (rust/2opt/)
# Then the following include will have to be removed.
include ../Rules.mk
