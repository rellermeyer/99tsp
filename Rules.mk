# Compiles the source file using the specified compiler + flags
# Note $< is the first specified dependency, in this case the source
compile: $(SRC)
	$(CC) $(CFLAGS) $<

# Runs the code.
run: compile
	$(RUNCMD) $(RUNFLAGS) $(TEST_FILE)

clean:
	rm -f $(OBJ)
