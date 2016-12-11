# Runs the code.
run: tsp.lisp a280.tsp
	clisp -q -q -on-error abort -x '(progn (load "tsp.lisp") (tsp-solve "a280.tsp") (quit))'

clean:
	rm -f $(OBJ)