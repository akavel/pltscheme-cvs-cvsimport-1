;;;
;;; <lset.ss> ---- Lists as Sets
;;; Time-stamp: <03/03/13 16:20:56 noel>
;;;
;;; Copyright (C) 2002 by Noel Welsh. 
;;;
;;; This file is part of SRFI-1.

;;; SRFI-1 is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU Lesser General Public
;;; License as published by the Free Software Foundation; either
;;; version 2.1 of the License, or (at your option) any later version.

;;; SRFI-1 is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; Lesser General Public License for more details.

;;; You should have received a copy of the GNU Lesser General Public
;;; License along with SRFI-1; if not, write to the Free Software
;;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA

;;; Author: Noel Welsh <noelwelsh@yahoo.com>
;;
;;
;; Commentary:

;; Based on the reference implementation by Olin Shiver and hence:

;; Copyright (c) 1998, 1999 by Olin Shivers. You may do as you please with
;; this code as long as you do not remove this copyright notice or
;; hold me liable for its use. Please send bug reports to shivers@ai.mit.edu.
;;     -Olin

(module lset
  mzscheme

  (require (lib "optional.ss" "srfi")
		   (all-except "search.ss" member)
		   (all-except "fold.ss" map for-each)
		   (rename "search.ss" s:member member)
		   "delete.ss"
		   "predicate.ss"
		   "filter.ss")
  (require (lib "receive.ss" "srfi" "8"))

  (provide lset<=
		   lset=
		   lset-adjoin
		   lset-union
		   lset-union!
		   lset-intersection
		   lset-difference
		   lset-difference!
		   lset-xor
		   lset-xor!
		   lset-diff+intersection
		   lset-diff+intersection!)

  ;; Lists-as-sets
  ;;;;;;;;;;;;;;;;;

  ;; This is carefully tuned code; do not modify casually.
  ;; - It is careful to share storage when possible;
  ;; - Side-effecting code tries not to perform redundant writes.
  ;; - It tries to avoid linear-time scans in special cases where constant-time
  ;;   computations can be performed.
  ;; - It relies on similar properties from the other list-lib procs it calls.
  ;;   For example, it uses the fact that the implementations of MEMBER and
  ;;   FILTER in this source code share longest common tails between args
  ;;   and results to get structure sharing in the lset procedures.
  
  (define (%lset2<= = lis1 lis2) (every (lambda (x) (s:member x lis2 =)) lis1))
  
  (define (lset<= = . lists)
	(check-arg procedure? = 'lset<=)
	(or (not (pair? lists)) ; 0-ary case
		(let lp ((s1 (car lists)) (rest (cdr lists)))
		  (or (not (pair? rest))
			  (let ((s2 (car rest))  (rest (cdr rest)))
				(and (or (eq? s2 s1)	; Fast path
						 (%lset2<= = s1 s2)) ; Real test
					 (lp s2 rest)))))))
  
  (define (lset= = . lists)
	(check-arg procedure? = 'lset=)
	(or (not (pair? lists)) ; 0-ary case
		(let lp ((s1 (car lists)) (rest (cdr lists)))
		  (or (not (pair? rest))
			  (let ((s2   (car rest))
					(rest (cdr rest)))
				(and (or (eq? s1 s2)	; Fast path
						 (and (%lset2<= = s1 s2) (%lset2<= = s2 s1))) ; Real test
					 (lp s2 rest)))))))
  
  
  (define (lset-adjoin = lis . elts)
	(check-arg procedure? = 'lset-adjoin)
	(fold (lambda (elt ans) (if (s:member elt ans =) ans (cons elt ans)))
		  lis elts))
  
  
  (define (lset-union = . lists)
	(check-arg procedure? = 'lset-union)
	(reduce (lambda (lis ans)	; Compute ANS + LIS.
			  (cond ((null? lis) ans)	; Don't copy any lists
					((null? ans) lis) 	; if we don't have to.
					((eq? lis ans) ans)
					(else
					 (fold (lambda (elt ans) (if (any (lambda (x) (= x elt)) ans)
												 ans
												 (cons elt ans)))
						   ans lis))))
			'() lists))
  
  (define (lset-union! = . lists)
	(check-arg procedure? = 'lset-union!)
	(reduce (lambda (lis ans)	; Splice new elts of LIS onto the front of ANS.
			  (cond ((null? lis) ans)	; Don't copy any lists
					((null? ans) lis) 	; if we don't have to.
					((eq? lis ans) ans)
					(else
					 (pair-fold (lambda (pair ans)
								  (let ((elt (car pair)))
									(if (any (lambda (x) (= x elt)) ans)
										ans
										(begin (set-cdr! pair ans) pair))))
								ans lis))))
			'() lists))
  
  
  (define (lset-intersection = lis1 . lists)
	(check-arg procedure? = 'lset-intersection)
	(let ((lists (delete lis1 lists eq?))) ; Throw out any LIS1 vals.
	  (cond ((any null-list? lists) '())		; Short cut
			((null? lists)          lis1)		; Short cut
			(else (filter (lambda (x)
							(every (lambda (lis) (s:member x lis =)) lists))
						  lis1)))))
  
  (define (lset-intersection! = lis1 . lists)
	(check-arg procedure? = 'lset-intersection!)
	(let ((lists (delete lis1 lists eq?))) ; Throw out any LIS1 vals.
	  (cond ((any null-list? lists) '())		; Short cut
			((null? lists)          lis1)		; Short cut
			(else (filter! (lambda (x)
							 (every (lambda (lis) (s:member x lis =)) lists))
						   lis1)))))
  
  
  (define (lset-difference = lis1 . lists)
	(check-arg procedure? = 'lset-difference)
	(let ((lists (filter pair? lists)))	; Throw out empty lists.
	  (cond ((null? lists)     lis1)	; Short cut
			((memq lis1 lists) '())	; Short cut
			(else (filter (lambda (x)
							(every (lambda (lis) (not (s:member x lis =)))
								   lists))
						  lis1)))))
  
  (define (lset-difference! = lis1 . lists)
	(check-arg procedure? = 'lset-difference!)
	(let ((lists (filter pair? lists)))	; Throw out empty lists.
	  (cond ((null? lists)     lis1)	; Short cut
			((memq lis1 lists) '())	; Short cut
			(else (filter! (lambda (x)
							 (every (lambda (lis) (not (s:member x lis =)))
									lists))
						   lis1)))))
  
  
  (define (lset-xor = . lists)
	(check-arg procedure? = 'lset-xor)
	(reduce (lambda (b a)			; Compute A xor B:
			  ;; Note that this code relies on the constant-time
			  ;; short-cuts provided by LSET-DIFF+INTERSECTION,
			  ;; LSET-DIFFERENCE & APPEND to provide constant-time short
			  ;; cuts for the cases A = (), B = (), and A eq? B. It takes
			  ;; a careful case analysis to see it, but it's carefully
			  ;; built in.
			  
			  ;; Compute a-b and a^b, then compute b-(a^b) and
			  ;; cons it onto the front of a-b.
			  (receive (a-b a-int-b)   (lset-diff+intersection = a b)
					   (cond ((null? a-b)     (lset-difference = b a))
							 ((null? a-int-b) (append b a))
							 (else (fold (lambda (xb ans)
										   (if (s:member xb a-int-b =) ans (cons xb ans)))
										 a-b
										 b)))))
			'() lists))
  
  
  (define (lset-xor! = . lists)
	(check-arg procedure? = 'lset-xor!)
	(reduce (lambda (b a)			; Compute A xor B:
			  ;; Note that this code relies on the constant-time
			  ;; short-cuts provided by LSET-DIFF+INTERSECTION,
			  ;; LSET-DIFFERENCE & APPEND to provide constant-time short
			  ;; cuts for the cases A = (), B = (), and A eq? B. It takes
			  ;; a careful case analysis to see it, but it's carefully
			  ;; built in.
			  
			  ;; Compute a-b and a^b, then compute b-(a^b) and
			  ;; cons it onto the front of a-b.
			  (receive (a-b a-int-b)   (lset-diff+intersection! = a b)
					   (cond ((null? a-b)     (lset-difference! = b a))
							 ((null? a-int-b) (append! b a))
							 (else (pair-fold (lambda (b-pair ans)
												(if (s:member (car b-pair) a-int-b =) ans
													(begin (set-cdr! b-pair ans) b-pair)))
											  a-b
											  b)))))
			'() lists))
  
  
  (define (lset-diff+intersection = lis1 . lists)
	(check-arg procedure? = 'lset-diff+intersection)
	(cond ((every null-list? lists) (values lis1 '()))	; Short cut
		  ((memq lis1 lists)        (values '() lis1))	; Short cut
		  (else (partition (lambda (elt)
							 (not (any (lambda (lis) (s:member elt lis =))
									   lists)))
						   lis1))))
  
  (define (lset-diff+intersection! = lis1 . lists)
	(check-arg procedure? = 'lset-diff+intersection!)
	(cond ((every null-list? lists) (values lis1 '()))	; Short cut
		  ((memq lis1 lists)        (values '() lis1))	; Short cut
		  (else (partition! (lambda (elt)
							  (not (any (lambda (lis) (s:member elt lis =))
										lists)))
							lis1))))
  
  
  )

;;; lset.ss ends here