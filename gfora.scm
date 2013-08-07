#!/usr/bin/env

(define-module gfora
  (push! *load-path* (string-append (sys-getenv "HOME") "/apl/at"))
  (use scheme-for-atlas-debug)
  (use slib-wrapper)
  (export <main>
          &quit
          <-
          &&
          define-block
          define-atlas-block
          loop
          local
          local*
          block
          symbols->string
          symbol-append
          mkstr
          %
          >>
          <start>
          variable?
          remove-from-top
          read-symols
          var-append
   ))
(select-module gfora)

(define (flatten ls)
  (cond ((null? ls) '())
        ((not (pair? ls)) (list ls))
        (else (append (flatten (car ls)) (flatten (cdr ls))))))

(define (<main> . lis)
  (apply print
         (flatten
          (file-name-check lis)
          ;; lis
          )))

(define (&quit)
  ($ #`"quit"))

(define <- "\n")
(define && " ")

(define-macro (define-block name&var . body)
  `(define ,name&var (list ,@body)))

(define-macro (define-atlas-block name&vars . body)
  (let ((fname (car name&vars))
        (fvars (cdr name&vars)))
    `(define (,(symbol-append '! fname) ,@fvars)
       (list ,@body))))

(define-macro (loop variables nums . body)
  `(map (lambda (,variables) (list ,@body))
        ,nums))

(define-macro (local var . body)
  `(let ,var (list ,@body)))

(define-macro (local* var . body)
  `(let* ,var (list ,@body)))

(define-macro (block . body)
  `(list ,@body))

(define (symbols->string  . args)
  (with-output-to-string 
    (lambda ()
      (if (null? args)
          (format #t "")
          (dolist (s args)
            (format #t " ~a " s))))))

(define (symbol-append . syms)
  (string->symbol (apply mkstr syms)))

(define (mkstr  . args)
  (with-output-to-string 
    (lambda ()
      (dolist (s args)
        (write s)))))

(define-macro (% . args)
  `(list  "\n"
          ,@(apply read-symols args)))
(define-macro (>> . args)
  `(list " "
         ,@(apply read-symols args)))
(define-macro (<start> . args)
  `(list ,@(apply read-symols args)))

(define (variable? s)
    (and (symbol? s)
         (> (string-length (symbol->string s)) 1)
         (char=? (string-ref (symbol->string s) 0)
                 #\$)))

(define (remove-from-top w num)
  (string->symbol
   (string-copy
    (symbol->string w)
    num
    (string-length (symbol->string w)))))

(define (read-symols . lis)
  (let loop ((l lis) (tmpacc '()) (allacc '()))
    (if (null? l)
        (reverse
         (cons (apply symbols->string (reverse tmpacc))
               allacc))
        (cond
         ((list? (car l))
          (let* ((allacc (cons
                         (map (lambda (x) (if (variable? x)
                                              (remove-from-top x 1)
                                              x)) (car l))
                         (cons (apply symbols->string (reverse tmpacc))
                                allacc))))
            (loop (cdr l) '() allacc)))
         ((variable? (car l))
          (let* ((var (remove-from-top (car l) 1))
                 (allacc (cons
                          var
                          (cons (apply symbols->string (reverse tmpacc))
                                allacc))))
            (loop (cdr l) '() allacc)))
         (#t (loop (cdr l) (cons (car l) tmpacc) allacc))))))

(define (var-append . lis)
  (letrec ((rec (lambda (l acc)
                  (if (null? l)
                      (reverse acc)
                      (if (string? (car l))
                          (rec (cdr l) (cons (car l) acc))
                          (rec (cdr l) (cons (x->string (car l)) acc)))))))
          (apply string-append (rec lis '()))))
