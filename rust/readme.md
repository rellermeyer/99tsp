/rust/Rules.mk overrides the definition of RUNCMDS and adds RUNFLAGS and TESTFILE and EXTENSION to RUNCMDS.
```Makefile
RUNCMD:=./2opt $(RUNFLAGS) $(TEST_FILE)$(EXTENSION)
```

This way, EXTENSION can be specified in the Makefile for the implementation.
Running make from the root directory (/99tsp) will add the extension.
Since RUNCMD now contains RUNFLAGS and TEST_FILE, the full run command will look like:
```Shell
./2opt -printarray /Users/K/Documents/CS345/99tsp/data/a280.tsp -printarray /Users/K/Documents/CS345/99tsp/data/a280
```
(The run flags and testfile path are repeated)
This only applies to Rust implementations.
