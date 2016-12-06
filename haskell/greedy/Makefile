TEST_FILE:=a280.tsp

compile:
	ghc -o tsp tsp.hs

# Runs the code.
run: compile
	./tsp $(TEST_FILE)

clean:
	rm tsp
	rm tsp.o
	rm tsp.hi
	