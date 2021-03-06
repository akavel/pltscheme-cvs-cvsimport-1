
(module make-cards mzscheme
  (require (lib "class.ss")
	   (prefix mred: (lib "mred.ss" "mred"))
	   (prefix card-class: "card-class.ss"))
  
  (provide back deck-of-cards make-card)

  (define (get-bitmap file)
    (make-object mred:bitmap% file))

  (define (make-semi bm-in w h)
    (let* ([bm (make-object mred:bitmap% (floor (/ w 2)) h)]
	   [mdc (make-object mred:bitmap-dc%)])
      (send mdc set-bitmap bm)
      (send mdc set-scale 0.5 1)
      (send mdc draw-bitmap bm-in 0 0)
      (send mdc set-bitmap #f)
      bm))

  (define (make-dim bm-in)
    (let ([w (send bm-in get-width)]
	  [h (send bm-in get-height)])
      (let* ([bm (make-object mred:bitmap% w h)]
	     [mdc (make-object mred:bitmap-dc% bm)])
	(send mdc draw-bitmap bm-in 0 0)
	(let* ([len (* w h 4)]
	       [b (make-bytes len)])
	  (send mdc get-argb-pixels 0 0 w h b)
	  (let loop ([i 0])
	    (unless (= i len)
	      (bytes-set! b i (quotient (* 3 (bytes-ref b i)) 4))
	      (loop (add1 i))))
	  (send mdc set-argb-pixels 0 0 w h b))
	(send mdc set-bitmap #f)
	bm)))

  (define here 
    (let ([cp (collection-path "games" "cards")])
      (lambda (file)
	(build-path cp 
		    (if ((mred:get-display-depth)  . <= . 8)
			"locolor"
			"hicolor")
		    file))))

  (define back (get-bitmap (here "card-back.png")))

  (define semi-back 
    (let ([w (send back get-width)]
	  [h (send back get-height)])
      (make-semi back w h)))

  (define dim-back
    (make-dim back))

  (define deck-of-cards
    (let* ([w (send back get-width)]
	   [h (send back get-height)])
      (let sloop ([suit 4])
	(if (zero? suit)
	    null
	    (let vloop ([value 13])
	      (sleep)
	      (if (zero? value)
		  (sloop (sub1 suit))
		  (let ([front (get-bitmap
				(here 
				 (format "card-~a-~a.png"
					 (sub1 value)
					 (sub1 suit))))])
		    (cons (make-object card-class:card%
			    suit
			    value
			    w h
			    front back
			    (make-semi front w h) semi-back
			    (lambda () (make-dim front))
			    (lambda () dim-back))
			  (vloop (sub1 value))))))))))
  
  (define (make-card front-bm back-bm suit-id value)
    (let ([w (send back get-width)]
	  [h (send back get-height)])
      (make-object card-class:card%
		   suit-id
		   value
		   w h
		   front-bm (or back-bm back)
		   (make-semi front-bm w h)
		   (if back-bm 
		       (make-semi back-bm w h)
		       semi-back)
		   (lambda () (make-dim front-bm))
		   (lambda ()
		     (if back-bm 
			 (make-dim back)
			 dim-back))))))