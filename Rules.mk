compile: $(SRC)
	$(CC) $(CFLAGS) $<

run: compile
	$(RUNCMD) $(RUNFLAGS) $(TEST_FILE)

clean:
	rm -f $(OBJ)
