;;
;; $Id$
;;
;; Link the gui tester together into compound unit.
;;
;; keymap (keys.ss) must be evaled before stprims.ss,
;; so mred:shifted-key-list is defined.
;;   

(compound-unit/sig

  (import 
    [wx       : wx^]
    [testable : mred:testable-window^]
    [keymap   : mred:keymap^])

  (link
    [run : mred:test:run^
      ((require-unit/sig "strun.ss") wx)]
    
    [prim : mred:test:primitives^
      ((require-unit/sig "stprims.ss") wx testable keymap run)])

  (export
    (open run)
    (open prim)))
