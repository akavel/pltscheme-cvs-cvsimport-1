
(module info (lib "infotab.ss" "setup")
  (define doc.txt "doc.txt")
  (define name "SirMail")
  (define mred-launcher-libraries (list "sirmail.ss"))
  (define mred-launcher-names (list "SirMail"))
  (define compile-omit-files '("recover.ss"))
  (define requires '(("mred") ("openssl"))))



