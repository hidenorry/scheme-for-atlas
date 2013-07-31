#!/usr/bin/env gosh

(define (remove-extension str ext)
    (let ((str-len (string-length str))
          (ext-len (string-length ext)))
      (if (string=? (string-copy str (- str-len ext-len) str-len) ext)
          (string-copy str 0 (- str-len ext-len)) ; (string-copy str 0 4) <-- 4 is not contained.
          (error "unkown file" str))))
(define (remove-str-extension str)
  (remove-extension str ".str"))
