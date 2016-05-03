compile: $(SRC)
	$(CC) $(CFLAGS) $<

run: compile
	$(RUNCMD) $(RUNFLAGS)

clean:
	rm -f $(OBJ)	
