;;;; diesel.asd

(asdf:defsystem #:diesel
  :serial t
  :description "Describe diesel here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (:iterate :split-sequence :parse-float)
  :components ((:file "package")
               (:file "diesel")))

