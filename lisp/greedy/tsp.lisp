; Terminal Command
; clisp -q -q -on-error abort -x '(progn (load "tsp.lisp") (tsp-solve "a280.tsp") (quit))'

(defun tsp-solve (input-file)
	(let ((in (open input-file :if-does-not-exist nil)))
		(when in
			(loop for x from 0 to 5 do
				(read-line in nil))
			(setq start (string-to-list (read-line in nil)))
			(setq data
				(loop for line = (read-line in nil)
					while line
					collect (string-to-list line)) )
			(close in)))
	(setq data (remove '(EOF) data :test #'equal))
	(setq solution (list (nth 0 start)))
	(setq length 0)
	(setq current start)
	(loop while data do
		(setq next-closest (get-min-elem data current))
		(setq data (delete (nth 0 next-closest) data))
		(setq solution (append solution (list (nth 0 (nth 0 next-closest)))))
		(setq current (nth 0 next-closest))
		(setq length (+ length (nth 1 next-closest))))
	(setq length (+ length (get-distance current start)))
	(setq solution (append solution (list (nth 0 start))))
	(format t "Length: ")
	(write length)
	(format t "~%Order: ")
	(loop while solution do
		(print (car solution))
		(setq solution (cdr solution))))

(defun string-to-list (str)
    (if (not (streamp str))
       (string-to-list (make-string-input-stream str))
       (if (listen str)
           (cons (read str) (string-to-list str))
           nil)))

(defun get-min-elem (lst elem)
	(setq min-distance -1)
	(setq min-elem nil)
	(loop for item in lst do
		(setq dist (get-distance item elem))
		(if (or (< dist min-distance) (< min-distance 0))
			(progn
				(setq min-distance dist)
				(setq min-elem item))))
	(setq result (list min-elem min-distance))
	(return-from get-min-elem result)
)

(defun get-distance (item1 item2)
	(sqrt (+ (* (- (nth 1 item2) (nth 1 item1)) (- (nth 1 item2) (nth 1 item1)) ) (* (- (nth 2 item2) (nth 2 item1)) (- (nth 2 item2) (nth 2 item1) ) ) ) ))

