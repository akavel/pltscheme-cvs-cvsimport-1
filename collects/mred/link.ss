;;
;; $Id$
;;

(compound-unit/sig (import [core : mzlib:core^])
  (link [wx : wx^ (wx@)]
	[mred : mred^ ((reference-unit/sig "linkwx.ss") core wx)])
  (export (open mred)))
