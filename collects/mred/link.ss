;;
;; $Id$
;;

(compound-unit/sig (import [core : mzlib:core^])
  (link [wx : mred:wx^ ((compound-unit/sig (import) 
					   (link [wx : wx^ (wx@)])
					   (export (unit wx))))]
	[mred : mred^ ((reference-unit/sig "linkwx.ss") core wx)])
  (export (open mred)))
