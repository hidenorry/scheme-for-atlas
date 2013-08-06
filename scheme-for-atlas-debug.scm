#!/usr/bin/env gosh

(define-module scheme-for-atlas-debug
  (push! *load-path* (string-append (sys-getenv "HOME") "/apl/at"))
  (use srfi-1)
  (use srfi-13)
  (export file-name-check))
(select-module scheme-for-atlas-debug)


(use slib)
(require 'format)

(define (invoke-error)
  (error "debug error"))
(define (file-name-error name)
  (error (format #f "file name | ~{~%~a~}~% | are used more than one."  name)))
;; (define (file-name-error name)
;;   (errorf "file name | ~a | are used more times than one.~%"  name))

(define (list-walk lis walker fun)
  (if (and (pair? lis) (every (complement pair?) lis))
      (fun lis)
      (walker (lambda (l) (list-walk l walker fun)) lis)))

(define (flatten lis)
  (letrec ((rec (lambda (lis acc)
                  (cond ((null? lis) (reverse acc))
                        ((pair? lis)
                         (rec (car lis) (rec (cdr lis) acc)))
                        (#t (cons lis acc))))))
    (rec lis '())))

(define (search-not-uniq-element lis)
  (letrec ((rec (lambda (lis acc)
                  (if (pair? lis)
                      (if-let1 it (member (car lis) (cdr lis))
                          (if (member (car it) (cdr it))
                              (rec (cdr lis) acc)
                              (rec (cdr lis) (cons (car lis) acc)))
                          (rec (cdr lis) (cons (car lis) acc)))
                      acc))))
    (let ((result (rec lis '())))
      (if (null? result)
          #f
          result))))


(define (get-file-name inplis)
  (define (string-bomb str)
    (map string-trim-both (string-split str " ")))
  (define (symplify lis)
    (apply append
           (map (lambda (l)
                  (if (string? l)
                      (filter (lambda (w) (not (string=? w ""))) (string-bomb l))
                      (list l)))
                lis)))
  (let ((lis (symplify inplis)))
    (cond ((or (string=? (first lis) "save") (string=? (first lis) "log"))
           (cond  ((string=? (second lis) "outf=")
                   (third lis))
                  ((string=? (second lis) "outf")
                   (cond ((equal? (third lis) "=")
                          (fourth lis))))
                  (#t (invoke-error))))
          (#t '()))))

;; (search-not-uniq-element (list (list "save " " outf=  " "ffoo")
;;                                (list "save " " outf=  " "ffoo")
;;                                (list "save " " outf=  " "ffo ")
;;                                (list "log " " outf=  " "ffo")))
;; (file-name-check (list (list "save " " outf=  " "ffoo")
;;                        (list "save " " outf=  " "ffoo")
;;                        (list "save " " outf=  " "ffo ")
;;                        (list "log " " outf=  " "ffo")))
(define (file-name-check . lis)
  (if-let1 it (search-not-uniq-element
               (flatten
                (list-walk lis map get-file-name)))
           (file-name-error it)
           lis))
