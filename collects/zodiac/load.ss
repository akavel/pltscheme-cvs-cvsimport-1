; $Id$

(require-library "macro.ss")
(require-library "cores.ss")

(require-library "zsigs.ss" "zodiac")
(require-library "sigs.ss" "zodiac")

; All this stuff needs to be disappeared.

(require-library "sparams.ss" "backward")

(define zodiac:system@
  (require-library-unit/sig "link.ss" "zodiac"))
