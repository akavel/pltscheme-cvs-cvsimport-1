#|

Make sure there are tests that cover these parameters:

 (read-case-sensitive #f) 
 (read-square-bracket-as-paren #f)  -- test: (symbol? '[])
 (read-curly-brace-as-paren #f)
 (print-vector-length #f)

the settings above should match r5rs

|#

(module language-test mzscheme
  (require "drscheme-test-util.ss"
           (lib "gui.ss" "tests" "utils")
           (lib "class.ss")
           (lib "list.ss")
           (lib "mred.ss" "mred")
           (lib "framework.ss" "framework")
           (prefix fw: (lib "framework.ss" "framework")))
  
  (provide run-test)

  (define language (make-parameter "<<not a language>>"))
  
  ;; set-language : boolean -> void
  (define (set-language close-dialog?)
    (set-language-level! (language) close-dialog?))

  
                            
                         ;; 
                          ; 
                          ; 
;;; ;   ; ;;;   ;;;    ;;;; 
 ; ; ;   ;     ;   ;  ;   ; 
 ; ; ;   ;     ;;;;;  ;   ; 
 ; ; ;   ;     ;      ;   ; 
 ; ; ;   ;     ;   ;  ;   ; 
;; ; ;; ;;;;    ;;;    ;;; ;
  

  (define (mred)
    (parameterize ([language (list "PLT" (regexp "Graphical"))])
      (check-top-of-repl)

      (generic-settings #f)
      (generic-output #t #t #t)
      
      (test-hash-bang)
      (test-error-after-definition)
      
      (prepare-for-test-expression)

      (test-expression "'|.|" "|.|")
      
      (test-expression '("(equal? (list " image ") (list " image "))") 
                       "#f")
      (test-expression "(define x 1)(define x 2)" "")
      
      (test-expression 'xml "(a () (b ()))")

      (test-expression "(define-struct spider (legs))(make-spider 4)" "#<struct:spider>")
      
      (test-expression "(sqrt -1)" "0+1i")

      (test-expression "class" (regexp "class: bad syntax in: class"))
      (test-expression "shared" "{bug09.gif} reference to undefined identifier: shared")
      
      (test-expression "(define (. x y) (* x y))" #rx"read: illegal use of \"\\.\"")
      (test-expression "'(1 . 2)" "(1 . 2)")
      
      (test-expression "(define (f define) 1)" "")
      (test-expression "(define (f car) 1)" "")
      (test-expression "(define (f empty) 1)" "")
      
      (test-expression "call/cc" "#<primitive:call-with-current-continuation>")
      
      (test-expression "(error 'a \"~a\" 1)" "{bug09.gif} a: 1")
      (test-expression "(error \"a\" \"a\")" "{bug09.gif} a \"a\"")
      
      (test-expression "(time 1)" 
                       #rx"cpu time: [0-9]+ real time: [0-9]+ gc time: [0-9]+\n1")
            
      (test-expression "true" "{bug09.gif} reference to undefined identifier: true")
      (test-expression "mred^" "{bug09.gif} reference to undefined identifier: mred^")
      (test-expression "(eq? 'a 'A)" "#f")
      (test-expression "(set! x 1)" "{bug09.gif} set!: cannot set undefined identifier: x")
      (test-expression "(cond [(= 1 2) 3])" "")
      (test-expression "(cons 1 2)" "(1 . 2)")
      (test-expression "'(1)" "(1)")
      (test-expression "(define shrd (box 1)) (list shrd shrd)"
                       "(#&1 #&1)")
      (test-expression 
       "(local ((define x x)) 1)"
       #rx"define: not allowed in an expression context")
      (test-expression "(letrec ([x x]) 1)" "1")
      (test-expression "(if 1 1 1)" "1")
      (test-expression "(+ 1)" "1")
      
      (test-expression "(let ([f (lambda (x) x)]) f)" "#<procedure:f>")
      (test-expression ",1" "unquote: not in quasiquote in: (unquote 1)")
      
      (test-expression "1.0" "1.0")
      (test-expression "#i1.0" "1.0")
      (test-expression "4/3" "{number 4/3 \"1 1/3\" mixed}")
      (test-expression "1/3" "{number 1/3 \"1/3\" mixed}")
      (test-expression "-4/3" "{number -4/3 \"-1 1/3\" mixed}")
      (test-expression "-1/3" "{number -1/3 \"-1/3\" mixed}")
      (test-expression "3/2" "{number 3/2 \"1 1/2\" mixed}")
      (test-expression "1/2" "{number 1/2 \"1/2\" mixed}")
      (test-expression "-1/2" "{number -1/2 \"-1/2\" mixed}")
      (test-expression "-3/2" "{number -3/2 \"-1 1/2\" mixed}")
      (test-expression "+1/3i" "0+1/3i")
      (test-expression "+1/2i" "0+1/2i")
      (test-expression "779625/32258" "{number 779625/32258 \"24 5433/32258\" mixed}")
      (test-expression "(exact? 1.5)" "#f")
      
      (test-expression "(list 1)" "(1)")
      (test-expression "(car (list))" "car: expects argument of type <pair>; given ()")

      (test-expression "argv" "#0()")))


                                                        
                            ;;                          
                             ;                          
                             ;                          
;;; ;   ;;;;;   ;;;    ;;;   ; ;;    ;;;  ;;; ;    ;;;  
 ; ; ;  ;  ;   ;   ;  ;   ;  ;;  ;  ;   ;  ; ; ;  ;   ; 
 ; ; ;    ;     ;;;   ;      ;   ;  ;;;;;  ; ; ;  ;;;;; 
 ; ; ;   ;         ;  ;      ;   ;  ;      ; ; ;  ;     
 ; ; ;  ;   ;  ;   ;  ;   ;  ;   ;  ;   ;  ; ; ;  ;   ; 
;; ; ;; ;;;;;   ;;;    ;;;  ;;; ;;;  ;;;  ;; ; ;;  ;;;  
                                                        
                                                        
                                                        

  
  (define (mzscheme)
    (parameterize ([language (list "PLT" (regexp "Textual"))])

      (check-top-of-repl)

      (generic-settings #f)
      (generic-output #t #t #t)
      
      (test-hash-bang)
      (test-error-after-definition)
      
      (prepare-for-test-expression)
      
      (test-expression "'|.|" "|.|")
      (test-expression '("(equal? (list " image ") (list " image "))") 
                       "#f")
      (test-expression "(define x 1)(define x 2)" "")
      
      (test-expression "(define-struct spider (legs))(make-spider 4)" "#<struct:spider>")
      
      (test-expression "(sqrt -1)" "0+1i")

      (test-expression "class" "{bug09.gif} reference to undefined identifier: class")
      (test-expression "shared" "{bug09.gif} reference to undefined identifier: shared")
      
      (test-expression "(define (. x y) (* x y))" #rx"read: illegal use of \"\\.\"")
      (test-expression "'(1 . 2)" "(1 . 2)")
      
      (test-expression "(define (f define) 1)" "")
      (test-expression "(define (f car) 1)" "")
      (test-expression "(define (f empty) 1)" "")
      
      (test-expression "call/cc" "#<primitive:call-with-current-continuation>")
      
      (test-expression "(error 'a \"~a\" 1)" "{bug09.gif} a: 1")
      (test-expression "(error \"a\" \"a\")" "{bug09.gif} a \"a\"")
      
      (test-expression "(time 1)" 
                       #rx"cpu time: [0-9]+ real time: [0-9]+ gc time: [0-9]+\n1")
      
      (test-expression "true" "{bug09.gif} reference to undefined identifier: true")
      (test-expression "mred^" "{bug09.gif} reference to undefined identifier: mred^")
      (test-expression "(eq? 'a 'A)" "#f")
      (test-expression "(set! x 1)" "{bug09.gif} set!: cannot set undefined identifier: x")
      (test-expression "(cond [(= 1 2) 3])" "")
      (test-expression "(cons 1 2)" "(1 . 2)")
      (test-expression "'(1)" "(1)")
      (test-expression "(define shrd (box 1)) (list shrd shrd)"
                       "(#&1 #&1)")
      (test-expression 
       "(local ((define x x)) 1)"
       #rx"define: not allowed in an expression context")
      (test-expression "(letrec ([x x]) 1)" "1")
      (test-expression "(if 1 1 1)" "1")
      (test-expression "(+ 1)" "1")

      (test-expression "1.0" "1.0")
      (test-expression "#i1.0" "1.0")
      (test-expression "4/3" "{number 4/3 \"1 1/3\" mixed}")
      (test-expression "1/3" "{number 1/3 \"1/3\" mixed}")
      (test-expression "-4/3" "{number -4/3 \"-1 1/3\" mixed}")
      (test-expression "-1/3" "{number -1/3 \"-1/3\" mixed}")
      (test-expression "3/2" "{number 3/2 \"1 1/2\" mixed}")
      (test-expression "1/2" "{number 1/2 \"1/2\" mixed}")
      (test-expression "-1/2" "{number -1/2 \"-1/2\" mixed}")
      (test-expression "-3/2" "{number -3/2 \"-1 1/2\" mixed}")
      (test-expression "+1/3i" "0+1/3i")
      (test-expression "+1/2i" "0+1/2i")
      (test-expression "779625/32258" "{number 779625/32258 \"24 5433/32258\" mixed}")
      (test-expression "(exact? 1.5)" "#f")

      (test-expression "(let ([f (lambda (x) x)]) f)" "#<procedure:f>")
      (test-expression ",1" "unquote: not in quasiquote in: (unquote 1)")

      (test-expression "(list 1)" "(1)")
      (test-expression "(car (list))" "car: expects argument of type <pair>; given ()")
      
      (test-expression "argv" "#0()")))

  
  
;                           
;                           
;                           
;        ;;;;;;             
;        ;                  
;        ;                  
;   ; ;  ;       ; ;   ;;;  
;   ;;   ;;;;    ;;   ;     
;   ;        ;   ;    ;;    
;   ;         ;  ;     ;;   
;   ;         ;  ;       ;  
;   ;    ;   ;   ;       ;  
;   ;     ;;;    ;    ;;;   
;                           
;                           
;                           

  
  (define (r5rs)
    (parameterize ([language (list (regexp "R5RS"))])

      (check-top-of-repl)

      (generic-settings #f)
      (generic-output #t #t #t)
      
      (test-hash-bang)
      (test-error-after-definition)
      
      (prepare-for-test-expression)
      
      (test-expression "'|.|" "|.|")
      (test-expression '("(equal? (list " image ") (list " image "))") 
                       "#f")
      (test-expression "(define x 1)(define x 2)" "")
      
      (test-expression "(define-struct spider (legs))(make-spider 4)" "#<struct:spider>")
      
      (test-expression "(sqrt -1)" "0+1i")

      (test-expression "class" "{bug09.gif} reference to undefined identifier: class")
      (test-expression "shared" "{bug09.gif} reference to undefined identifier: shared")
      
      (test-expression "(define (. x y) (* x y))" #rx"read: illegal use of \"\\.\"")
      (test-expression "'(1 . 2)" "(1 . 2)")
      
      (test-expression "(define (f define) 1)" "")
      (test-expression "(define (f car) 1)" "")
      (test-expression "(define (f empty) 1)" "")
      
      (test-expression "call/cc" "#<primitive:call-with-current-continuation>")
      
      (test-expression "(error 'a \"~a\" 1)" "{bug09.gif} a: 1")
      (test-expression "(error \"a\" \"a\")" "{bug09.gif} a \"a\"")
      
      (test-expression "(time 1)" 
                       #rx"cpu time: [0-9]+ real time: [0-9]+ gc time: [0-9]+\n1")
      
      (test-expression "true" "{bug09.gif} reference to undefined identifier: true")
      (test-expression "mred^" "{bug09.gif} reference to undefined identifier: mred^")
      (test-expression "(eq? 'a 'A)" "#t")
      (test-expression "(set! x 1)" "{bug09.gif} set!: cannot set undefined identifier: x")
      (test-expression "(cond [(= 1 2) 3])" "")
      (test-expression "(cons 1 2)" "(1 . 2)")
      (test-expression "'(1)" "(1)")
      (test-expression "(define shrd (box 1)) (list shrd shrd)"
                       "(#&1 #&1)")
      (test-expression 
       "(local ((define x x)) 1)"
       #rx"define: not allowed in an expression context")
      (test-expression "(letrec ([x x]) 1)" "1")
      (test-expression "(if 1 1 1)" "1")
      (test-expression "(+ 1)" "1")

      (test-expression "1.0" "1.0")
      (test-expression "#i1.0" "1.0")
      (test-expression "4/3" "{number 4/3 \"1 1/3\" mixed}")
      (test-expression "1/3" "{number 1/3 \"1/3\" mixed}")
      (test-expression "-4/3" "{number -4/3 \"-1 1/3\" mixed}")
      (test-expression "-1/3" "{number -1/3 \"-1/3\" mixed}")
      (test-expression "3/2" "{number 3/2 \"1 1/2\" mixed}")
      (test-expression "1/2" "{number 1/2 \"1/2\" mixed}")
      (test-expression "-1/2" "{number -1/2 \"-1/2\" mixed}")
      (test-expression "-3/2" "{number -3/2 \"-1 1/2\" mixed}")
      (test-expression "+1/3i" "0+1/3i")
      (test-expression "+1/2i" "0+1/2i")
      (test-expression "779625/32258" "{number 779625/32258 \"24 5433/32258\" mixed}")
      (test-expression "(exact? 1.5)" "#f")

      (test-expression "(let ([f (lambda (x) x)]) f)" "#<procedure:f>")
      (test-expression ",1" "unquote: not in quasiquote in: (unquote 1)")

      (test-expression "(list 1)" "(1)")
      (test-expression "(car (list))" "car: expects argument of type <pair>; given ()")

      (test-expression "argv" "#0()")))
                                                        
;;                      ;                               
 ;                                                      
 ;                                                      
 ;;;;    ;;;    ;;; ; ;;;   ; ;;;  ; ;;;    ;;;   ; ;;; 
 ;   ;  ;   ;  ;   ;    ;    ;;  ;  ;;  ;  ;   ;   ;    
 ;   ;  ;;;;;  ;   ;    ;    ;   ;  ;   ;  ;;;;;   ;    
 ;   ;  ;      ;   ;    ;    ;   ;  ;   ;  ;       ;    
 ;   ;  ;   ;  ;   ;    ;    ;   ;  ;   ;  ;   ;   ;    
; ;;;    ;;;    ;;;;  ;;;;; ;;;  ;;;;;  ;;  ;;;   ;;;;  
                   ;                                    
                   ;                                    
                ;;;                                     

  
  (define (beginner)
    (parameterize ([language (list "How to Design Programs" "Beginning Student")])
      (check-top-of-repl)

      (generic-settings #t)
      (generic-output #f #f #f)
      (teaching-language-fraction-output)
      
      (test-hash-bang)
      (test-error-after-definition)
      
      (prepare-for-test-expression)

      (test-expression "'|.|" "'|.|")
      (test-expression '("(equal? (list " image ") (list " image "))") 
                       "true")
      
      (test-expression "(define x 1)(define x 2)"
                       "x: this name was defined previously and cannot be re-defined"
                       "define: cannot redefine name: x")
      
      (test-expression "(define-struct spider (legs))(make-spider 4)" 
                       "(make-spider 4)"
                       "define-struct: cannot redefine name: spider")
      
      (test-expression "(sqrt -1)" "0+1i")

      (test-expression "class" 
                       "class: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: class")
      (test-expression "shared"
                       "shared: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: shared")

      (test-expression "(define (. x y) (* x y))" "read: illegal use of \".\"")
      (test-expression "'(1 . 2)" "read: illegal use of \".\"")
      
      (test-expression "call/cc"
                       "call/cc: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: call/cc")
      
      (test-expression "(error 'a \"~a\" 1)"
                       "procedure error: expects 2 arguments, given 3: 'a \"~a\" 1")
      (test-expression "(error \"a\" \"a\")"
                       "error: expected a symbol and a string, got \"a\" and \"a\"")
      
      (test-expression "(time 1)"
                       "time: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: time")
      
      (test-expression "true" "true")
      (test-expression "mred^" 
                       "mred^: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: mred^")
      (test-expression "(eq? 'a 'A)" "false")
      (test-expression "(set! x 1)"
                       "set!: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: set!")
      (test-expression "(cond [(= 1 2) 3])" "cond: all question results were false")
      (test-expression "(cons 1 2)" "cons: second argument must be of type <list>, given 1 and 2")
      (test-expression "'(1)" "quote: expected a name after a ', found something else")
      (test-expression "(define shrd (list 1)) (list shrd shrd)"
                       "(cons (cons 1 empty) (cons (cons 1 empty) empty))"
                       "define: cannot redefine name: shrd")
      (test-expression "(local ((define x x)) 1)"
                       "local: name is not defined, not an argument, and not a primitive name"
                       "function call: expected a defined name or a primitive operation name after an open parenthesis, but found something else")
      (test-expression "(letrec ([x x]) 1)"
                       "letrec: name is not defined, not an argument, and not a primitive name"
                       "function call: expected a defined name or a primitive operation name after an open parenthesis, but found something else")
      (test-expression "(if 1 1 1)" "if: question result is not true or false: 1")
      (test-expression "(+ 1)" "procedure +: expects at least 2 arguments, given 1: 1")
      
      (test-expression "1.0" "1")
      (test-expression "#i1.0" "#i1.0")
      (test-expression "4/3" "{number 4/3 \"1.3\" decimal}")
      (test-expression "1/3" "{number 1/3 \"0.3\" decimal}")
      (test-expression "-4/3" "{number -4/3 \"-1.3\" decimal}")
      (test-expression "-1/3" "{number -1/3 \"-0.3\" decimal}")
      (test-expression "3/2" "{number 3/2 \"1.5\" decimal}")
      (test-expression "1/2" "{number 1/2 \"0.5\" decimal}")
      (test-expression "-1/2" "{number -1/2 \"-0.5\" decimal}")
      (test-expression "-3/2" "{number -3/2 \"-1.5\" decimal}")
      (test-expression "+1/3i" "0+1/3i")
      (test-expression "+1/2i" "0+0.5i")
      (test-expression "779625/32258" "{number 779625/32258 \"24.1684233368466736933473866...\" decimal}")
      (test-expression "(exact? 1.5)" "true")
      
      (test-expression "(let ([f (lambda (x) x)]) f)"
                       "let: name is not defined, not an argument, and not a primitive name"
                       "function call: expected a defined name or a primitive operation name after an open parenthesis, but found something else")
      (test-expression ",1"
                       "read: illegal use of comma")

      (test-expression "(list 1)" "(cons 1 empty)")
      (test-expression "(car (list))" "car: expects argument of type <pair>; given empty")

      (test-expression "argv" 
                       "argv: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: argv")))
  

                                                               
;;                         ;       ;;                          
 ;                        ;         ;                          
 ;                        ;         ;                          
 ;;;;    ;;;    ;;; ;    ;   ;;;;   ;;;;   ; ;;;   ;;;  ;;; ;;;
 ;   ;  ;   ;  ;   ;     ;       ;  ;   ;   ;     ;   ;  ;   ; 
 ;   ;  ;;;;;  ;   ;    ;     ;;;;  ;   ;   ;     ;;;;;  ;   ; 
 ;   ;  ;      ;   ;    ;    ;   ;  ;   ;   ;     ;       ; ;  
 ;   ;  ;   ;  ;   ;   ;     ;   ;  ;   ;   ;     ;   ;   ;;;  
; ;;;    ;;;    ;;;;   ;      ;;; ;; ;;;   ;;;;    ;;;     ;   
                   ;  ;                                        
                   ;                                           
                ;;;                                            


  (define (beginner/abbrev)
    (parameterize ([language (list "How to Design Programs" 
                                   "Beginning Student with List Abbreviations")])
      (check-top-of-repl)
  
      (generic-settings #t)
      (generic-output #t #f #f)
      (teaching-language-fraction-output)
      
      (test-hash-bang)
      
      (test-error-after-definition)
      
      (prepare-for-test-expression)
      
      (test-expression "'|.|" "'|.|")      
      (test-expression '("(equal? (list " image ") (list " image "))") 
                       "true")
      
      (test-expression "(define x 1)(define x 2)"
                       "x: this name was defined previously and cannot be re-defined"
                       "define: cannot redefine name: x")
      
      (test-expression "(define-struct spider (legs))(make-spider 4)"
                       "(make-spider 4)"
                       "define-struct: cannot redefine name: spider")
      
      (test-expression "(sqrt -1)" "0+1i")

      (test-expression "class"
                       "class: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: class")
      (test-expression "shared"
                       "shared: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: shared")

      (test-expression "(define (. x y) (* x y))" "read: illegal use of \".\"")
      (test-expression "'(1 . 2)" "read: illegal use of \".\"")
      
      (test-expression "call/cc"
                       "call/cc: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: call/cc")
      
      (test-expression "(error 'a \"~a\" 1)"
                       "procedure error: expects 2 arguments, given 3: 'a \"~a\" 1")
      (test-expression "(error \"a\" \"a\")"
                       "error: expected a symbol and a string, got \"a\" and \"a\"")
      
      (test-expression "(time 1)"
		         "time: name is not defined, not an argument, and not a primitive name"
		         "reference to undefined identifier: time")
      
      (test-expression "true" "true")
      (test-expression "mred^" 
                       "mred^: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: mred^")
      (test-expression "(eq? 'a 'A)" "false")
      (test-expression "(set! x 1)"
                       "set!: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: set!")
      (test-expression "(cond [(= 1 2) 3])" "cond: all question results were false")
      (test-expression "(cons 1 2)" "cons: second argument must be of type <list>, given 1 and 2")
      (test-expression "'(1)" "(list 1)")
      (test-expression "(define shrd (list 1)) (list shrd shrd)"
                       "(list (list 1) (list 1))"
                       "define: cannot redefine name: shrd")
      (test-expression "(local ((define x x)) 1)"
                       "local: name is not defined, not an argument, and not a primitive name"
                       "function call: expected a defined name or a primitive operation name after an open parenthesis, but found something else")
      (test-expression "(letrec ([x x]) 1)"
                       "letrec: name is not defined, not an argument, and not a primitive name"
                       "function call: expected a defined name or a primitive operation name after an open parenthesis, but found something else")
      (test-expression "(if 1 1 1)" "if: question result is not true or false: 1")
      (test-expression "(+ 1)" "procedure +: expects at least 2 arguments, given 1: 1")
      
      (test-expression "1.0" "1")
      (test-expression "#i1.0" "#i1.0")
      (test-expression "4/3" "{number 4/3 \"1.3\" decimal}")
      (test-expression "1/3" "{number 1/3 \"0.3\" decimal}")
      (test-expression "-4/3" "{number -4/3 \"-1.3\" decimal}")
      (test-expression "-1/3" "{number -1/3 \"-0.3\" decimal}")
      (test-expression "3/2" "{number 3/2 \"1.5\" decimal}")
      (test-expression "1/2" "{number 1/2 \"0.5\" decimal}")
      (test-expression "-1/2" "{number -1/2 \"-0.5\" decimal}")
      (test-expression "-3/2" "{number -3/2 \"-1.5\" decimal}")
      (test-expression "+1/3i" "0+1/3i")
      (test-expression "+1/2i" "0+0.5i")
      (test-expression "779625/32258" "{number 779625/32258 \"24.1684233368466736933473866...\" decimal}")
      (test-expression "(exact? 1.5)" "true")
      
      (test-expression "(let ([f (lambda (x) x)]) f)" 
                       "let: name is not defined, not an argument, and not a primitive name"
                       "function call: expected a defined name or a primitive operation name after an open parenthesis, but found something else")
      (test-expression ",1"
                       "unquote: misuse of a comma or `unquote', not under a quasiquoting backquote")

      (test-expression "(list 1)" "(list 1)")
      (test-expression "(car (list))" "car: expects argument of type <pair>; given empty")

      (test-expression "argv" 
                       "argv: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: argv")))


                                                                                    
   ;                                                 ;;    ;                        
                ;                                     ;                 ;           
                ;                                     ;                 ;           
 ;;;   ; ;;;   ;;;;;   ;;;   ; ;;; ;;; ;    ;;;    ;;;;  ;;;    ;;;;   ;;;;;   ;;;  
   ;    ;;  ;   ;     ;   ;   ;     ; ; ;  ;   ;  ;   ;    ;        ;   ;     ;   ; 
   ;    ;   ;   ;     ;;;;;   ;     ; ; ;  ;;;;;  ;   ;    ;     ;;;;   ;     ;;;;; 
   ;    ;   ;   ;     ;       ;     ; ; ;  ;      ;   ;    ;    ;   ;   ;     ;     
   ;    ;   ;   ;   ; ;   ;   ;     ; ; ;  ;   ;  ;   ;    ;    ;   ;   ;   ; ;   ; 
 ;;;;; ;;;  ;;   ;;;   ;;;   ;;;;  ;; ; ;;  ;;;    ;;; ; ;;;;;   ;;; ;   ;;;   ;;;  
                                                                                    
                                                                                    
                                                                                    


  (define (intermediate)
    (parameterize ([language (list "How to Design Programs" "Intermediate Student")])
      (check-top-of-repl)

      (generic-settings #t)
      (generic-output #t #f #f)
      (teaching-language-fraction-output)
      
      (test-hash-bang)
      (test-error-after-definition)
      
      (prepare-for-test-expression)
      
      (test-expression "'|.|" "'|.|")
      (test-expression '("(equal? (list " image ") (list " image "))") 
                       "true")
      
      (test-expression "(define x 1)(define x 2)"
                       "x: this name was defined previously and cannot be re-defined"
                       "define: cannot redefine name: x")
      
      (test-expression "(define-struct spider (legs))(make-spider 4)"
                       "(make-spider 4)"
                       "define-struct: cannot redefine name: spider")
      
      (test-expression "(sqrt -1)" "0+1i")

      (test-expression "class" 
                       "class: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: class")
      (test-expression "shared"
                       "shared: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: shared")
      
      (test-expression "(define (. x y) (* x y))" "read: illegal use of \".\"")
      (test-expression "'(1 . 2)" "read: illegal use of \".\"")
      
      (test-expression "call/cc"
                       "call/cc: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: call/cc")
      
      (test-expression "(error 'a \"~a\" 1)"
                       "procedure error: expects 2 arguments, given 3: 'a \"~a\" 1")
      (test-expression "(error \"a\" \"a\")"
                       "error: expected a symbol and a string, got \"a\" and \"a\"")
      
      (test-expression "(time 1)" 
                       #rx"cpu time: [0-9]+ real time: [0-9]+ gc time: [0-9]+\n1")
            
      (test-expression "true" "true")
      (test-expression "mred^" 
                       "mred^: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: mred^")
      (test-expression "(eq? 'a 'A)" "false")
      (test-expression "(set! x 1)"
                       "set!: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: set!")
      (test-expression "(cond [(= 1 2) 3])" "cond: all question results were false")
      (test-expression "(cons 1 2)" "cons: second argument must be of type <list>, given 1 and 2")
      (test-expression "'(1)" "(list 1)")
      (test-expression "(define shrd (list 1)) (list shrd shrd)"
                       "(list (list 1) (list 1))"
                       "define: cannot redefine name: shrd")
      (test-expression "(local ((define x x)) 1)" "local variable used before its definition: x")
      (test-expression "(letrec ([x x]) 1)" "local variable used before its definition: x")
      (test-expression "(if 1 1 1)" "if: question result is not true or false: 1")
      (test-expression "(+ 1)" "procedure +: expects at least 2 arguments, given 1: 1")
      
      (test-expression "1.0" "1")
      (test-expression "#i1.0" "#i1.0")
      (test-expression "4/3" "{number 4/3 \"1.3\" decimal}")
      (test-expression "1/3" "{number 1/3 \"0.3\" decimal}")
      (test-expression "-4/3" "{number -4/3 \"-1.3\" decimal}")
      (test-expression "-1/3" "{number -1/3 \"-0.3\" decimal}")
      (test-expression "3/2" "{number 3/2 \"1.5\" decimal}")
      (test-expression "1/2" "{number 1/2 \"0.5\" decimal}")
      (test-expression "-1/2" "{number -1/2 \"-0.5\" decimal}")
      (test-expression "-3/2" "{number -3/2 \"-1.5\" decimal}")
      (test-expression "+1/3i" "0+1/3i")
      (test-expression "+1/2i" "0+0.5i")
      (test-expression "779625/32258" "{number 779625/32258 \"24.1684233368466736933473866...\" decimal}")
      (test-expression "(exact? 1.5)" "true")
      
      (test-expression "(let ([f (lambda (x) x)]) f)" "function:f")
      (test-expression ",1"
                       "unquote: misuse of a comma or `unquote', not under a quasiquoting backquote")

      (test-expression "(list 1)" "(list 1)")
      (test-expression "(car (list))" "car: expects argument of type <pair>; given empty")
      (test-expression "argv" 
                       "argv: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: argv")))


                                                                      
   ;                       ; ;;;                 ;;         ;;        
                ;         ;    ;                  ;          ;        
                ;         ;    ;                  ;          ;        
 ;;;   ; ;;;   ;;;;;     ;     ;    ;;;;  ;;; ;   ;;;;    ;;;;  ;;;;  
   ;    ;;  ;   ;        ;     ;        ;  ; ; ;  ;   ;  ;   ;      ; 
   ;    ;   ;   ;       ;      ;     ;;;;  ; ; ;  ;   ;  ;   ;   ;;;; 
   ;    ;   ;   ;       ;      ;    ;   ;  ; ; ;  ;   ;  ;   ;  ;   ; 
   ;    ;   ;   ;   ;  ;       ;    ;   ;  ; ; ;  ;   ;  ;   ;  ;   ; 
 ;;;;; ;;;  ;;   ;;;   ;     ;;;;;;  ;;; ;;; ; ;;; ;;;    ;;; ;  ;;; ;
                      ;                                               
                                                                      
                                                                      


  (define (intermediate/lambda)
    (parameterize ([language (list "How to Design Programs" 
                                   "Intermediate Student with lambda")])
      (check-top-of-repl)
      
      (generic-settings #t)
      (generic-output #t #f #f)
      (teaching-language-fraction-output)
      
      (test-hash-bang)
      (test-error-after-definition)
      
      (prepare-for-test-expression)
      
      (test-expression "'|.|" "'|.|")
      (test-expression '("(equal? (list " image ") (list " image "))") 
                       "true")
      (test-expression "(define x 1)(define x 2)"
                       "x: this name was defined previously and cannot be re-defined"
                       "define: cannot redefine name: x")
      
      (test-expression "(define-struct spider (legs))(make-spider 4)"
                       "(make-spider 4)"
                       "define-struct: cannot redefine name: spider")
      
      (test-expression "(sqrt -1)" "0+1i")
      
      (test-expression "class"
                       "class: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: class")
      (test-expression "shared" 
                       "shared: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: shared")
      
      (test-expression "(define (. x y) (* x y))" "read: illegal use of \".\"")
      (test-expression "'(1 . 2)" "read: illegal use of \".\"")
      
      (test-expression "call/cc"
                       "call/cc: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: call/cc")
      
      (test-expression "(error 'a \"~a\" 1)"
                       "procedure error: expects 2 arguments, given 3: 'a \"~a\" 1")
      (test-expression "(error \"a\" \"a\")"
                       "error: expected a symbol and a string, got \"a\" and \"a\"")
      
      (test-expression "(time 1)" 
                       #rx"cpu time: [0-9]+ real time: [0-9]+ gc time: [0-9]+\n1")
            
      (test-expression "true" "true")
      (test-expression "mred^" 
                       "mred^: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: mred^")
      (test-expression "(eq? 'a 'A)" "false")
      (test-expression "(set! x 1)"
                       "set!: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: set!")
      (test-expression "(cond [(= 1 2) 3])" "cond: all question results were false")
      (test-expression "(cons 1 2)" "cons: second argument must be of type <list>, given 1 and 2")
      (test-expression "'(1)" "(list 1)")
      (test-expression "(define shrd (list 1)) (list shrd shrd)"
                       "(list (list 1) (list 1))"
                       "define: cannot redefine name: shrd")
      (test-expression "(local ((define x x)) 1)" "local variable used before its definition: x")
      (test-expression "(letrec ([x x]) 1)" "local variable used before its definition: x")
      (test-expression "(if 1 1 1)" "if: question result is not true or false: 1")
      (test-expression "(+ 1)" "procedure +: expects at least 2 arguments, given 1: 1")
      
      (test-expression "1.0" "1")
      (test-expression "#i1.0" "#i1.0")
      (test-expression "4/3" "{number 4/3 \"1.3\" decimal}")
      (test-expression "1/3" "{number 1/3 \"0.3\" decimal}")
      (test-expression "-4/3" "{number -4/3 \"-1.3\" decimal}")
      (test-expression "-1/3" "{number -1/3 \"-0.3\" decimal}")
      (test-expression "3/2" "{number 3/2 \"1.5\" decimal}")
      (test-expression "1/2" "{number 1/2 \"0.5\" decimal}")
      (test-expression "-1/2" "{number -1/2 \"-0.5\" decimal}")
      (test-expression "-3/2" "{number -3/2 \"-1.5\" decimal}")
      (test-expression "+1/3i" "0+1/3i")
      (test-expression "+1/2i" "0+0.5i")
      (test-expression "779625/32258" "{number 779625/32258 \"24.1684233368466736933473866...\" decimal}")
      (test-expression "(exact? 1.5)" "true")
      
      (test-expression "(let ([f (lambda (x) x)]) f)" "(lambda (a1) ...)")
      (test-expression ",1"
                       "unquote: misuse of a comma or `unquote', not under a quasiquoting backquote")

      (test-expression "(list 1)" "(list 1)")
      (test-expression "(car (list))" "car: expects argument of type <pair>; given empty")
      (test-expression "argv" 
                       "argv: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: argv")))
  

                                                        
           ;;                                        ;; 
            ;                                         ; 
            ;                                         ; 
 ;;;;    ;;;; ;;; ;;; ;;;;  ; ;;;    ;;;    ;;;    ;;;; 
     ;  ;   ;  ;   ;      ;  ;;  ;  ;   ;  ;   ;  ;   ; 
  ;;;;  ;   ;  ;   ;   ;;;;  ;   ;  ;      ;;;;;  ;   ; 
 ;   ;  ;   ;   ; ;   ;   ;  ;   ;  ;      ;      ;   ; 
 ;   ;  ;   ;   ;;;   ;   ;  ;   ;  ;   ;  ;   ;  ;   ; 
  ;;; ;  ;;; ;   ;     ;;; ;;;;  ;;  ;;;    ;;;    ;;; ;
                                                        
                                                        
                                                        


  (define (advanced)
    (parameterize ([language (list "How to Design Programs" "Advanced Student")])
      (check-top-of-repl)

      (generic-settings #t)
      (generic-output #t #t #t)
      (teaching-language-fraction-output)
      
      (test-hash-bang)
      (test-error-after-definition)
      
      (prepare-for-test-expression)
      
      (test-expression "'|.|" "'|.|")
      (test-expression '("(equal? (list " image ") (list " image "))") 
                       "true")
      (test-expression "(define x 1)(define x 2)"
                       "x: this name was defined previously and cannot be re-defined"
                       "define: cannot redefine name: x")
      
      (test-expression "(define-struct spider (legs))(make-spider 4)"
                       "(make-spider 4)"
                       "define-struct: cannot redefine name: spider")
      
      (test-expression "(sqrt -1)" "0+1i")

      (test-expression "class"
                       "class: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: class")

      (test-expression "shared" "shared: found a use of `shared' that does not follow an open parenthesis")
      
      (test-expression "(define (. x y) (* x y))" "read: illegal use of \".\"")
      (test-expression "'(1 . 2)" "read: illegal use of \".\"")
      
      (test-expression "call/cc" 
                       "call/cc: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: call/cc")
      
      (test-expression "(error 'a \"~a\" 1)"
                       "procedure error: expects 2 arguments, given 3: 'a \"~a\" 1")
      (test-expression "(error \"a\" \"a\")"
                       "error: expected a symbol and a string, got \"a\" and \"a\"")
      
      (test-expression "(time 1)" 
                       #rx"cpu time: [0-9]+ real time: [0-9]+ gc time: [0-9]+\n1")
            
      (test-expression "true" "true")
      (test-expression "mred^" 
                       "mred^: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: mred^")
      (test-expression "(eq? 'a 'A)" "false")
      (test-expression "(set! x 1)"
                       "x: name is not defined"
                       "set!: cannot set undefined identifier: x")
      (test-expression "(cond [(= 1 2) 3])" "cond: all question results were false")
      (test-expression "(cons 1 2)" "cons: second argument must be of type <list or cyclic list>, given 1 and 2")
      (test-expression "'(1)" "(list 1)")
      (test-expression "(define shrd (list 1)) (list shrd shrd)"
                       "(shared ((-1- (list 1))) (list -1- -1-))"
                       "define: cannot redefine name: shrd")
      (test-expression "(local ((define x x)) 1)" "local variable used before its definition: x")
      (test-expression "(letrec ([x x]) 1)" "local variable used before its definition: x")
      (test-expression "(if 1 1 1)" "if: question result is not true or false: 1")
      (test-expression "(+ 1)" "procedure +: expects at least 2 arguments, given 1: 1")

      (test-expression "1.0" "1")
      (test-expression "#i1.0" "#i1.0")
      (test-expression "4/3" "{number 4/3 \"1.3\" decimal}")
      (test-expression "1/3" "{number 1/3 \"0.3\" decimal}")
      (test-expression "-4/3" "{number -4/3 \"-1.3\" decimal}")
      (test-expression "-1/3" "{number -1/3 \"-0.3\" decimal}")
      (test-expression "3/2" "{number 3/2 \"1.5\" decimal}")
      (test-expression "1/2" "{number 1/2 \"0.5\" decimal}")
      (test-expression "-1/2" "{number -1/2 \"-0.5\" decimal}")
      (test-expression "-3/2" "{number -3/2 \"-1.5\" decimal}")
      (test-expression "+1/3i" "0+1/3i")
      (test-expression "+1/2i" "0+0.5i")
      (test-expression "779625/32258" "{number 779625/32258 \"24.1684233368466736933473866...\" decimal}")
      (test-expression "(exact? 1.5)" "true")
      
      (test-expression "(let ([f (lambda (x) x)]) f)" "(lambda (a1) ...)")
      (test-expression ",1"
                       "unquote: misuse of a comma or `unquote', not under a quasiquoting backquote")

      (test-expression "(list 1)" "(list 1)")
      (test-expression "(car (list))" "car: expects argument of type <pair>; given empty")
      (test-expression "argv"
                       "argv: name is not defined, not an argument, and not a primitive name"
                       "reference to undefined identifier: argv")))

                                                 
                                                 
                                            ;    
                                            ;    
  ;;;  ;;  ;; ; ;;;  ; ;;;    ;;;   ; ;;;  ;;;;; 
 ;   ;  ;   ;  ;   ;  ;   ;  ;   ;   ;      ;    
  ;;;   ;   ;  ;   ;  ;   ;  ;   ;   ;      ;    
     ;  ;   ;  ;   ;  ;   ;  ;   ;   ;      ;    
 ;   ;  ;   ;  ;   ;  ;   ;  ;   ;   ;      ;   ;
  ;;;    ;;; ; ;;;;   ;;;;    ;;;   ;;;;     ;;; 
               ;      ;                          
               ;      ;                          
              ;;;    ;;;                         


  (define (prepare-for-test-expression)
    (let ([drs (wait-for-drscheme-frame)])
      (clear-definitions drs)
      (set-language #t)
      (sleep 1) ;; this shouldn't be neccessary....
      (do-execute drs)))
  
  ;; test-setting : (-> void) string string string -> void
  ;; opens the language dialog, runs `set-setting'
  ;; closes the language dialog, executes,
  ;; makes sure that `expression' produces
  ;; `result'. `set-setting' is expected to click around
  ;; in the language dialog.
  ;; `setting-name' is used in the error message when the test fails.
  (define (test-setting set-setting setting-name expression result)
    (set-language #f)
    (set-setting)
    (let ([f (get-top-level-focus-window)])
      (fw:test:button-push "OK")
      (wait-for-new-frame f))
    (let* ([drs (get-top-level-focus-window)]
           [interactions (send drs get-interactions-text)])
      (clear-definitions drs)
      (type-in-definitions drs expression)
      (do-execute drs)
      (let* ([got (fetch-output drs)])
        (unless (string=? result got)
          (printf "FAILED: ~s ~s ~s test~n expected: ~a~n      got: ~a~n"
                  (language) setting-name expression result got)))))
  
  (define (test-hash-bang)
    (let* ([expression (format "#!~n1")]
           [result "1"]
           [drs (get-top-level-focus-window)]
           [interactions (send drs get-interactions-text)])
      (clear-definitions drs)
      (type-in-definitions drs expression)
      (do-execute drs)
      (let* ([got (fetch-output drs)])
        (unless (string=? "1" got)
          (printf "FAILED: ~s ~a test~n expected: ~a~n     got: ~a~n"
                  (language) expression result got)))))
  
  (define (check-top-of-repl)
    (let ([drs (wait-for-drscheme-frame)])
      (set-language #t)
      (do-execute drs)
      (let* ([interactions (send drs get-interactions-text)]
             [short-lang (car (last-pair (language)))]
             [get-line (lambda (n) (send interactions get-text 
                                         (send interactions paragraph-start-position n)
                                         (send interactions paragraph-end-position n)))]
             [line0-expect (format "Welcome to DrScheme, version ~a." (version:version))]
             [line1-expect 
              (if (string? short-lang)
                  (format "Language: ~a." short-lang)
                  short-lang)]
             [line0-got (get-line 0)]
             [line1-got (get-line 1)])
        (unless (and (string=? line0-expect line0-got)
                     (if (string? short-lang)
                         (string=? line1-expect line1-got)
                         (regexp-match line1-expect line1-got)))
          (printf "expected lines: ~n  ~a~n  ~a~ngot lines:~n  ~a~n  ~a~n" 
                  line0-expect line1-expect
                  line0-got line1-got)
          (error 'language-test.ss "failed get top of repl test")))))

  
  ;; teaching-language-fraction-output
  ;; tests that the teaching langauges properly handle repeating decimals
  (define (teaching-language-fraction-output)
    (test-setting
     (lambda () (fw:test:set-radio-box! "Fraction Style" "Mixed fractions"))
     "Fraction Style -- Mixed fractions"
     "4/3"
     "{number 4/3 \"1 1/3\" mixed}")
    (test-setting
     (lambda () (fw:test:set-radio-box! "Fraction Style" "Repeating decimals"))
     "Fraction Style -- Repeating decimals"
     "4/3"
     "{number 4/3 \"1.3\" decimal}"))
  
  ;; plt-language-fraction-output : -> void
  ;; tests that the PLT languages properly handle repeating decimals
  (define (plt-language-fraction-output)
    (test-setting
     (lambda () (fw:test:set-check-box! "Use decimal notation for rationals" #f))
     "Use decimal notation for rationals -- #f"
     "4/3 1/2 -1/3"
     "{number 4/3 \"1 1/3\" mixed}\n{number 1/2 \"1/2\" mixed}\n{number -1/3 \"- 1/3\" mixed}")
    (test-setting
     (lambda () (fw:test:set-check-box! "Use decimal notation for rationals" #t))
     "Use decimal notation for rationals -- #t"
     "4/3 1/2 -1/3"
     "{number 4/3 \"#e1.3\" decimal}\n{number 1/2 \"#e0.5\" decimal}\n{number -1/3 \"#e-0.3\" decimal}"))
  
  (define (generic-settings false/true?)
    (test-setting
      (lambda () (fw:test:set-check-box! "Case sensitive" #t))
     "Case sensitive -- #t"
     "(eq? 'g 'G)" (if false/true? "false" "#f"))
    (test-setting
     (lambda () (fw:test:set-check-box! "Case sensitive" #f))
     "Case sensitive -- #f"
     "(eq? 'g 'G)" (if false/true? "true" "#t")))
  
  (define (generic-output list? quasi-quote? has-sharing?)
    (let* ([drs (wait-for-drscheme-frame)]
           [expression (format "(define x (list 2))~n(list x x)")]
           [set-output-choice
            (lambda (option show-sharing pretty?)
              (set-language #f)
              (fw:test:set-radio-box! "Output Style" option)
              (when (and has-sharing? show-sharing)
                (fw:test:set-check-box!
                 "Show sharing in values"
                 (if (eq? show-sharing 'on) #t #f)))
              (fw:test:set-check-box!
               "Insert newlines in printed values"
               pretty?)
              (let ([f (get-top-level-focus-window)])
                (fw:test:button-push "OK")
                (wait-for-new-frame f)))]
           [shorten
            (lambda (str)
              (if ((string-length str) . <= . 45)
                  str
                  (string-append (substring str 0 45) "...")))]
           [test
	    ;; answer must either be a string, or a procedure that accepts both zero and 1
	    ;; argument. When the procedure accepts 1 arg, the argument is `got' and
	    ;; the result must be a boolean indicating if the result was satisfactory.
	    ;; if the procedure receives no arguments, it must return a descriptive string
	    ;; for the error message
            (lambda (option show-sharing pretty? answer)
              (set-output-choice option show-sharing pretty?)
              (do-execute drs)
              (let ([got (fetch-output drs)])
                (unless (if (procedure? answer)
                            (answer got)
                            (whitespace-string=? answer got))
                  (printf "FAILED ~s ~a, sharing ~a pretty? ~a~n            got ~s~n       expected ~s~n"
                          (language) option show-sharing pretty?
                          (shorten got)
                          (if (procedure? answer) (answer) answer)))))])
      
      (clear-definitions drs)
      (type-in-definitions drs expression)
      
      (test "write" 'off #t "((2) (2))")
      (when has-sharing?
        (test "write" 'on #t "(#0=(2) #0#)"))
      (when quasi-quote?
        (test "Quasiquote" 'off #t "`((2) (2))")
        (when has-sharing?
          (test "Quasiquote" 'on #t "(shared ((-1- `(2))) `(,-1- ,-1-))")))
      
      (test "Constructor" 'off #t
            (if list?
                "(list (list 2) (list 2))"
                "(cons (cons 2 empty) (cons (cons 2 empty) empty))"))
      (when has-sharing?
        (test "Constructor" 'on #t
              (if list?
                  "(shared ((-1- (list 2))) (list -1- -1-))"
                  "(shared ((-1- (cons 2 empty))) (cons -1- (cons -1- empty)))")))
 
      ;; setup write / pretty-print difference
      (clear-definitions drs)
      (for-each fw:test:keystroke
                (string->list
                 "(define (f n)\n(cond [(zero? n) null]\n[else (cons n (f (- n 1)))]))\n(f 200)"))
      (test "Constructor" #f #f
            (case-lambda
             [(x) (not (member #\newline (string->list x)))]
             [() "no newlines in result"]))
      (test "Constructor" #f #t
            (case-lambda
             [(x) (member #\newline (string->list x))]
             [() "newlines in result (may need to make the window smaller)"]))
      (test "write" #f #f
            (case-lambda
             [(x) (not (member #\newline (string->list x)))]
             [() "no newlines in result"]))
      (test "write" #f #t
            (case-lambda
             [(x) (member #\newline (string->list x))]
             [() "newlines in result (may need to make the window smaller)"]))))

  (define re:out-of-sync
    (regexp
     "WARNING: Interactions window is out of sync with the definitions window\\."))
  
  (define (test-error-after-definition)
    (let* ([drs (wait-for-drscheme-frame)]
           [interactions-text (send drs get-interactions-text)])
      (clear-definitions drs)
      (type-in-definitions drs "(define y 0) (define (f x) (/ x y)) (f 2)")
      (do-execute drs)
      (let ([last-para (send interactions-text last-paragraph)])
        (type-in-interactions drs "y\n")
        (wait-for-computation drs)
        (let ([got
               (fetch-output
                drs
                (send interactions-text paragraph-start-position (+ last-para 1))
                (send interactions-text paragraph-end-position
                      (- (send interactions-text last-paragraph) 1)))])
          (unless (equal? got "0")
            (printf "FAILED: test-error-after-definition failed, expected 0, got ~s\n" got))))))

  
  ;; test-expression : (union string 'xml 'image (listof (union string 'xml 'image)))
  ;;                   (union string regexp (string -> boolean)) 
  ;;                -> void
  ;; types an expression in the definitions window, executes it and tests the output
  ;; types an expression in the REPL and tests the output from the REPL.
  (define test-expression
    (case-lambda 
      [(expression expected) (test-expression expression expected expected)]
      [(expression defs-expected repl-expected)
       (let* ([drs (wait-for-drscheme-frame)]
              [interactions-text (send drs get-interactions-text)]
              [definitions-text (send drs get-definitions-text)]
              [handle-insertion
               (lambda (item)
                 (cond
                   [(eq? item 'image)
                    (use-get/put-dialog 
                     (lambda () (fw:test:menu-select "Special" "Insert Image..."))
                     (simplify-path (build-path (collection-path "icons") "recycle.gif")))]
                   [(string? item)
                    (type-in-definitions drs item)]
                   [(eq? item 'xml)
                    (fw:test:menu-select "Special" "Insert XML Box")
                    (for-each fw:test:keystroke (string->list "<a><b>"))]
                   [else (error 'handle-insertion "unknown thing to insert ~s" item)]))]
              [check-expectation
               (lambda (expected got)
                 (cond
                   [(string? expected)
                    (whitespace-string=? expected got)]
                   [(regexp? expected)
                    (regexp-match expected got)]
                   [(procedure? expected)
                    (expected got)]))]
              [make-err-msg
               (lambda (expected)
                 (cond
                   [(string? expected)
                    "FAILED: ~s ~s expected ~s to produce:\n  ~s\ngot:\n  ~s\ninstead~n"]
                   [(regexp? expected)
                    "FAILED: ~s ~s expected ~s to match ~s, got ~s instead~n"]
                   [(procedure? expected)
                    "FAILED: ~s ~s expected ~s to pass predicate ~s, got ~s~n"]))])
         (clear-definitions drs)
         (cond
	   [(pair? expression) (for-each handle-insertion expression)]
           [else (handle-insertion expression)])
         (do-execute drs)
         
         (let ([got
                (fetch-output
                 drs
                 (send interactions-text paragraph-start-position 2)
                 (send interactions-text paragraph-end-position
                       (- (send interactions-text last-paragraph) 1)))])
           (when (regexp-match re:out-of-sync got)
             (error 'text-expression "got out of sync message"))
           (unless (check-expectation defs-expected got)
             (printf (make-err-msg defs-expected) 
                     'definitions (language) expression defs-expected got)))
         
         (send definitions-text select-all)
         (send definitions-text copy)
         
         (send interactions-text set-position
               (send interactions-text last-position)
               (send interactions-text last-position))
         
         (send interactions-text paste)
         
         (let ([last-para (send interactions-text last-paragraph)])
           (type-in-interactions drs (string #\newline))
           (wait-for-computation drs)
           (let ([got
                  (fetch-output
                   drs
                   (send interactions-text paragraph-start-position (+ last-para 1))
                   (send interactions-text paragraph-end-position
                         (- (send interactions-text last-paragraph) 1)))])
             (when (regexp-match re:out-of-sync got)
               (error 'text-expression "got out of sync message"))
             (unless (check-expectation repl-expected got)
               (printf (make-err-msg repl-expected) 'interactions (language) expression defs-expected got)))))]))
  
  
  (define-syntax (go stx)
    (syntax-case stx ()
      [(_ arg)
       (identifier? (syntax arg))
       (syntax (begin (printf ">> starting ~a\n" (syntax-object->datum #'arg))
                      (arg)
                      (printf ">> finished ~a\n" (syntax-object->datum #'arg))))]))
  
  (define (run-test)
    ;; clear teachpack
    (let ([drs (wait-for-drscheme-frame)])
      (fw:test:menu-select "Language" "Clear All Teachpacks"))

    (go beginner)
    (go beginner/abbrev)
    (go intermediate)
    (go intermediate/lambda)
    (go advanced)
    (go r5rs)
    (go mred)
    (go mzscheme)))
