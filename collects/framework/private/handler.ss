
(module handler mzscheme
  (require (lib "unitsig.ss")
	   (lib "class.ss")
           (lib "list.ss")
           (lib "hierlist.ss" "hierlist")
	   "sig.ss"
	   "../gui-utils.ss"
	   (lib "mred-sig.ss" "mred")
	   (lib "file.ss")
           (lib "string-constant.ss" "string-constants"))

  (provide handler@)

  (define handler@
    (unit/sig framework:handler^
      (import mred^
	      [finder : framework:finder^]
	      [group : framework:group^]
	      [text : framework:text^]
	      [preferences : framework:preferences^]
	      [frame : framework:frame^])
      
      (define-struct handler (name extension handler))

      (define format-handlers '())

      (define make-insert-handler
	(letrec ([string-list?
		  (λ (l)
		    (cond
		     [(null? l) #t]
		     [(not (pair? l)) #f]
		     [else
		      (and (string? (car l))
			   (string-list? (cdr l)))]))])
	  (λ (who name extension handler)
	    (cond
	     [(not (string? name))
	      (error who "name was not a string")]
	     [(and (not (procedure? extension))
		   (not (string? extension))
		   (not (string-list? extension)))
	      (error who
		     "extension was not a string, list of strings, or a predicate")]
	     [(not (procedure? handler))
	      (error who "handler was not a function")]
	     [else (make-handler name
				 (if (string? extension)
                                     (list extension)
                                     extension)
				 handler)]))))
      
      (define insert-format-handler
	(λ args
	  (set! format-handlers 
		(cons (apply make-insert-handler 'insert-format-handler args)
		      format-handlers))))

      (define find-handler
	(λ (name handlers)
	  (let/ec exit
	    (let ([extension (if (string? name)
				 (or (filename-extension name)
				     "")
				 "")])
	      (for-each
	       (λ (handler)
		 (let ([ext (handler-extension handler)])
		   (when (or (and (procedure? ext)
				  (ext name))
			     (and (pair? ext)
				  (ormap (λ (ext) (string=? ext extension))
					 ext)))
		     (exit (handler-handler handler)))))
	       handlers)
	      #f))))
      
      (define find-format-handler
	(λ (name)
	  (find-handler name format-handlers)))

					; Finding format & mode handlers by name
      (define find-named-handler
	(λ (name handlers)
	  (let loop ([l handlers])
	    (cond
	     [(null? l) #f]
	     [(string-ci=? (handler-name (car l)) name)
	      (handler-handler (car l))]
	     [else (loop (cdr l))]))))
      
      (define find-named-format-handler
	(λ (name)
	  (find-named-handler name format-handlers)))

					; Open a file for editing
      (define current-create-new-window
	(make-parameter
	 (λ (filename)
	   (let ([frame (make-object frame:text% filename)])
	     (send frame show #t)
	     frame))))

      (define edit-file
	(case-lambda
	 [(filename) (edit-file
		      filename
		      (λ ()
			((current-create-new-window) filename)))]
	 [(filename make-default)
	  (with-handlers ([(λ (x) #f) ;exn:fail?
			   (λ (exn)
			     (message-box
			      (string-constant error-loading)
			      (string-append
			       (format (string-constant error-loading-file/name)
				       (or filename
					   (string-constant unknown-filename)))
			       "\n\n"
			       (if (exn? exn)
				   (format "~a" (exn-message exn))
				   (format "~s" exn))))
			     #f)])
            (gui-utils:show-busy-cursor
	     (λ ()
	       (if filename
		   (let ([already-open (send (group:get-the-frame-group)
					     locate-file
					     filename)])
                     (cond
		       [already-open
			(send already-open make-visible filename)
                        (send already-open show #t)
			already-open]
		       [(and (preferences:get 'framework:open-here?)
			     (send (group:get-the-frame-group) get-open-here-frame))
			=>
			(λ (fr)
			  (add-to-recent filename)
			  (send fr open-here filename)
			  (send fr show #t)
			  fr)]
		       [else
			(let ([handler
			       (if (path? filename)
				   (find-format-handler filename)
				   #f)])
			  (add-to-recent filename)
			  (if handler
			      (handler filename)
			      (make-default)))]))
		   (make-default)))))]))
      
      ;; type recent-list-item = (list/p string? number? number?)
      
      ;; add-to-recent : path -> void
      (define (add-to-recent filename)
        (let* ([old-list (preferences:get 'framework:recently-opened-files/pos)]
               [old-ents (filter (λ (x) (string=? (path->string (car x))
                                                       (path->string filename))) 
                                 old-list)]
               [old-ent (if (null? old-ents)
                            #f
                            (car old-ents))]
               [new-ent (list filename 
                              (if old-ent (cadr old-ent) 0)
                              (if old-ent (caddr old-ent) 0))]
               [added-in (cons new-ent (remove new-ent old-list compare-recent-list-items))]
               [new-recent (size-down added-in (preferences:get 'framework:recent-max-count))])
          (preferences:set 'framework:recently-opened-files/pos new-recent)))
      
      ;; compare-recent-list-items : recent-list-item recent-list-item -> boolean
      (define (compare-recent-list-items l1 l2)
        (string=? (path->string (car l1))
                  (path->string (car l2))))

      ;; size-down : (listof X) -> (listof X)[< recent-max-count]
      ;; takes a list of stuff and returns the
      ;; front of the list, up to `recent-max-count' items
      (define (size-down new-recent n)
        (let loop ([n n]
                   [new-recent new-recent])
          (cond
            [(zero? n) null]
            [(null? new-recent) null]
            [else
             (cons (car new-recent)
                   (loop (- n 1)
                         (cdr new-recent)))])))
      
      ;; size-recently-opened-files : number -> void
      ;; sets the recently-opened-files/pos preference
      ;; to a size limited by `n'
      (define (size-recently-opened-files n)
         (preferences:set
          'framework:recently-opened-files/pos
          (size-down (preferences:get 'framework:recently-opened-files/pos)
                     n)))       
      
      ;; set-recent-position : string number number -> void
      ;; updates the recent menu preferences 
      ;; with the positions `start' and `end'
      (define (set-recent-position filename start end)
        (let ([recent-items
               (filter (λ (x) (string=? (path->string (car x))
                                             (path->string filename)))
                       (preferences:get 'framework:recently-opened-files/pos))])
          (unless (null? recent-items)
            (let ([recent-item (car recent-items)])
              (set-car! (cdr recent-item) start)
              (set-car! (cddr recent-item) end)))))
        
      ;; install-recent-items : (is-a?/c menu%) -> void?
      (define (install-recent-items menu)
        (let ([recently-opened-files
               (preferences:get
                'framework:recently-opened-files/pos)])
          (for-each (λ (item) (send item delete))
                    (send menu get-items))
          
          (instantiate menu-item% ()
            (parent menu)
            (label (string-constant show-recent-items-window-menu-item))
            (callback (λ (x y) (show-recent-items-window))))
          
          (instantiate separator-menu-item% ()
            (parent menu))

          (for-each (λ (recent-list-item) 
                      (let ([filename (car recent-list-item)])
                        (instantiate menu-item% ()
                          (parent menu)
                          (label (gui-utils:trim-string  
                                  (regexp-replace*
                                   "&"
                                   (path->string filename)
                                   "&&")
                                  200))
                          (callback (λ (x y) (open-recent-list-item recent-list-item))))))
                    recently-opened-files)))

      ;; open-recent-list-item : recent-list-item -> void
      (define (open-recent-list-item recent-list-item)
        (let* ([filename (car recent-list-item)]
               [start (cadr recent-list-item)]
               [end (caddr recent-list-item)])
          (cond
            [(file-exists? filename)
             (let ([fr (edit-file filename)])
               (when (is-a? fr frame:open-here<%>)
                 (let ([ed (send fr get-open-here-editor)])
                   (when (equal? (send ed get-filename) filename)
                     (send ed set-position start end)))))]
            [else
             (message-box (string-constant error)
                          (format (string-constant cannot-open-because-dne)
                                  filename))])))
      
      ;; show-recent-items-window : -> void
      (define (show-recent-items-window)
        (unless recent-items-window
          (set! recent-items-window (make-recent-items-window)))
        (send recent-items-window show #t))
      
      ;; make-recent-items-window : -> frame
      (define (make-recent-items-window)
        (make-object (get-recent-items-window%)
          (string-constant show-recent-items-window-label)
          #f
          (preferences:get 'framework:recent-items-window-w) 
          (preferences:get 'framework:recent-items-window-h)))

      ;; recent-items-window : (union #f (is-a?/c frame%))
      (define recent-items-window #f)

      (define recent-items-hierarchical-list%
        (class hierarchical-list%
          (define/override (on-double-select item)
            (send item open-item))
          (super-instantiate ())))
      
      (define recent-items-super% (frame:standard-menus-mixin frame:basic%))

      (define (set-recent-items-frame-superclass super%)
        (set! recent-items-super% super%))
      
      (define (get-recent-items-window%)
        (class recent-items-super%

          ;; remove extraneous separators
          (define/override (file-menu:between-print-and-close menu) (void))
          (define/override (edit-menu:between-find-and-preferences menu) (void))
          
          (define/override (on-size w h)
            (preferences:set 'framework:recent-items-window-w w)
            (preferences:set 'framework:recent-items-window-h h))

          ;; refresh-hl : (listof recent-list-item) -> void
          (define/private (refresh-hl recent-list-items)
            (let ([ed (send hl get-editor)])
              (send ed begin-edit-sequence)
              (for-each (λ (item) (send hl delete-item item)) (send hl get-items))
              (for-each (λ (item) (add-recent-item item))
                        (if (eq? (preferences:get 'framework:recently-opened-sort-by) 'name)
                            (quicksort recent-list-items
                                       (λ (x y) (string<=? (path->string (car x))
                                                                (path->string (car y)))))
                            recent-list-items))
              (send ed end-edit-sequence)))
          
          (define/private (add-recent-item recent-list-item)
            (let ([item (send hl new-item (make-hierlist-item-mixin recent-list-item))])
              (send (send item get-editor) insert (path->string (car recent-list-item)))))

          (field [remove-prefs-callback
                  (preferences:add-callback
                   'framework:recently-opened-files/pos
                   (λ (p v)
                     (refresh-hl v)))])
          
          (define/augment (on-close)
            (inner (void) on-close)
            (remove-prefs-callback)
            (set! recent-items-window #f))
          
          (super-new)
          
          (inherit get-area-container)
          (field [bp (make-object horizontal-panel% (get-area-container))]
                 [hl (make-object recent-items-hierarchical-list% (get-area-container) '())]
                 [sort-by-name-button
                  (make-object button% 
                    (string-constant recent-items-sort-by-name) 
                    bp
                    (λ (x y) (set-sort-by 'name)))]
                 [sort-by-age-button
                  (make-object button% 
                    (string-constant recent-items-sort-by-age) 
                    bp
                    (λ (x y) (set-sort-by 'age)))])
          
          (send bp stretchable-height #f)
          (send sort-by-name-button stretchable-width #t)
          (send sort-by-age-button stretchable-width #t)
          
          (define/private (set-sort-by flag)
            (preferences:set 'framework:recently-opened-sort-by flag)
            (case flag
              [(name) 
               (send sort-by-age-button enable #t)
               (send sort-by-name-button enable #f)]
              [(age) 
               (send sort-by-age-button enable #f)
               (send sort-by-name-button enable #t)])
            (refresh-hl (preferences:get 'framework:recently-opened-files/pos)))

          (set-sort-by (preferences:get 'framework:recently-opened-sort-by))))

      ;; make-hierlist-item-mixin : recent-item -> mixin(arg to new-item method of hierlist)
      (define (make-hierlist-item-mixin recent-item)
        (λ (%)
          (class %
            (define/public (open-item)
              (open-recent-list-item recent-item))
            (super-instantiate ()))))
      
      (define *open-directory* ; object to remember last directory
	(new (class object%
               (field [the-dir #f])
               [define/public get (λ () the-dir)]
               [define/public set-from-file!
                 (λ (file) 
                   (set! the-dir (path-only file)))]
               [define/public set-to-default
                 (λ ()
                   (set! the-dir (current-directory)))]
               (set-to-default)
               (super-new))))

      (define open-file
	(λ ()
	  (let ([file 
		 (parameterize ([finder:dialog-parent-parameter
				 (and (preferences:get 'framework:open-here?)
                                      (get-top-level-focus-window))])
		   (finder:get-file
		    (send *open-directory* get)))])
	    (when file
	      (send *open-directory*
		    set-from-file! file))
	    (and file
		 (edit-file file))))))))
