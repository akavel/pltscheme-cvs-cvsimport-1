; $Id$

(reference-library "macro.ss")
(reference-library "cores.ss")

(reference-library "zsigs.ss" "zodiac")
(reference-library "sigs.ss" "zodiac")

; All this stuff needs to be disappeared.

(reference-library "sparams.ss" "backward")

(define zodiac:system@
  (reference-library-unit/sig "link.ss" "zodiac"))
