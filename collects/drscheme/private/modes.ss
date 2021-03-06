(module modes mzscheme
  (require (lib "unitsig.ss")
           (lib "string-constant.ss" "string-constants")
           (lib "class.ss")
           (lib "framework.ss" "framework")
           "drsig.ss")
  
  (provide modes@)
  
  (define modes@
    (unit/sig drscheme:modes^
      (import)
      
      (define-struct mode (name surrogate repl-submit matches-language))
      (define modes (list))
      
      (define (get-modes) modes)
      
      (define (add-mode name surrogate repl-submit matches-language)
        (let ([new-mode (make-mode name 
                                   surrogate
                                   repl-submit
                                   matches-language)])
          (set! modes (cons new-mode modes))
          new-mode))
      
      (define (add-initial-modes)
        
        ;; must be added first, to make it last in mode list,
        ;; since predicate matches everything
        (add-mode 
         (string-constant scheme-mode)
         (new scheme:text-mode%)
         (λ (text prompt-position) (scheme:text-balanced? text prompt-position))
         (λ (l) #t))
        
        (add-mode 
         (string-constant text-mode)
         #f
         (λ (text prompt-position) #t)
         (λ (l) 
           (and l (ormap (λ (x) (regexp-match #rx"Algol" x)) l))))))))
