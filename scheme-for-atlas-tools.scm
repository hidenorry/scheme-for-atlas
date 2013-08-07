#!/usr/bin/env gosh

(define-module scheme-for-atlas-tools
  (use slib-wrapper)
  (use srfi-13)
  (export remove-extension
          remove-str-extension
          add-variables-name
          f))
(select-module scheme-for-atlas-tools)

(define (remove-extension str ext)
    (let ((str-len (string-length str))
          (ext-len (string-length ext)))
      (if (string=? (string-copy str (- str-len ext-len) str-len) ext)
          (string-copy str 0 (- str-len ext-len))
          ;; (string-copy str 0 4) <-- 4 is not contained.
          (error "unkown file" str))))
(define (remove-str-extension str)
  (remove-extension str ".str"))

(define (add-variables-name device str var lis)
  ;;(add-variables-name "fo" "_nsub" 3.0 (list 3.0 4.0)) => "fo_nsub3.0"
  (if (> (length lis) 1)
      (string-append device str (x->string var))
      device))

(define (f num)
  (x->number (string-trim-both (format #f "~10,5f" num))))
