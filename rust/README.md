Rules.mk overrides the definition of RUNCMDS and adds RUNFLAGS and TESTFILE and EXTENSION to RUNCMDS.
```Makefile
RUNCMD:=./2opt $(RUNFLAGS) $(TEST_FILE)$(EXTENSION)
```

This way, EXTENSION can be specified in the Makefile for the implementation.
Running make from the root directory (/99tsp) will add the extension.
