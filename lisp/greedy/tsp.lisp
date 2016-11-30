; clisp -q -q -on-error abort -x '(progn (load "tsp.lisp") (tsp-solve "sample.txt") (quit))'

(defun tsp-solve (input_file)
	(let ((in (open input_file :if-does-not-exist nil)))
	(when in
		(read-line in)
		(read-line in)
		(read-line in)
		(read-line in)
		(read-line in)
		(read-line in)
		(setq data
		(loop for line = (read-line in nil)
			while line
			collect (string-to-list line)) )
		(close in)
		(print data)
		)
	)
)

(defun string-to-list (str)
        (if (not (streamp str))
           (string-to-list (make-string-input-stream str))
           (if (listen str)
               (cons (read str) (string-to-list str))
               nil)))

