;;;; diesel.lisp

(in-package #:diesel)

;;; "diesel" goes here. Hacks and glory await!

(defparameter *diesel-data-filename* "c:/users/serge.demarre/appdata/roaming/dieselverbruik.txt")
(defparameter *diesel-line-tokenizer-rx* "([^\" ]+)|(\"[^\"]+\")")
(defparameter *diesel-line-decoders*
  (macrolet ((rule (selector-name handler)
	       (let ((selector (gensym "SELECTOR-")))
		 `(list #'(lambda (,selector) (eq ,selector ,selector-name)) #'(lambda (line-items) ,handler)))))
    (list 
     (rule :datum (first line-items))
     (rule :km (parse-integer (second line-items) :junk-allowed t))
     (rule :volume (parse-float (third line-items) :junk-allowed t))
     (rule :prijs-per-liter (parse-float (fourth line-items) :junk-allowed t))
     (rule :prijs (parse-float (fifth line-items) :junk-allowed t))
     (rule :locatie (sixth line-items))
     (rule :tijd (seventh line-items)))))
(defun diesel-data-lines ()
  (iter (for line in-file *diesel-data-filename* using #'read-line)
	(collect (remove #\Return line))))
(defun diesel-data ()
  (iter (for line in (diesel-data-lines))
	(collect (cl-ppcre:all-matches-as-strings *diesel-line-tokenizer-rx* line))))
(defun find-item-rule (item)
  (let ((rule (iter (for rule in *diesel-line-decoders*)
	       (when (funcall (car rule) item)
		 (return (cadr rule))))))
    (if rule rule (error "Couldn't find rule which matches ~a" item))))
(defun diesel-select (items)
  (let ((items (if (consp items) items (list items))))
    (let ((extractors (mapcar #'find-item-rule items)))
      (let ((result
	     (iter (for line in (diesel-data))
		   (collect 
		       (iter (for extractor in extractors)
			     (collect (funcall extractor line)))))))
	(if (not (cdr items))
	    (mapcar #'car result)
	    result)))))
