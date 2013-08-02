#!/usr/bin/env gosh

(define (remove-extension str ext)
    (let ((str-len (string-length str))
          (ext-len (string-length ext)))
      (if (string=? (string-copy str (- str-len ext-len) str-len) ext)
          (string-copy str 0 (- str-len ext-len)) ; (string-copy str 0 4) <-- 4 is not contained.
          (error "unkown file" str))))
(define (remove-str-extension str)
  (remove-extension str ".str"))

(define (add-variables-name device str var lis)
  ;;(add-variables-name "fo" "_nsub" 3.0 (list 3.0 4.0)) => "fo_nsub3.0"
  (if (> (length lis) 1)
      (string-append device str (x->string var))
      device))
