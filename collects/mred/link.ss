;;
;; $Id$
;;

(compound-unit/sig (import [core : mzlib:core^])
  (link [wx : mred:wx^ ((unit/sig () (import)))]
	[mred : mred^ ((reference-unit/sig "linkwx.ss") core wx)])
  (export (open mred)))
