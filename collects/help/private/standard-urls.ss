(module standard-urls mzscheme

  (require "../servlets/private/util.ss"
           "internal-hp.ss"
           (lib "contract.ss"))
  
  (provide home-page-url)
  
  (define (search-type? x)
    (member x '("keyword" "keyword-index" "keyword-index-text")))
  
  (define (search-how? x)
    (member x '("exact-match" "containing-match" "regexp-match")))
  
  (provide search-type? search-how?)
  (provide/contract 
   (make-relative-results-url (string? 
                               search-type? 
                               search-how?
                               any/c 
                               (listof path?)
                               any/c
                               (union false/c string?) . -> . string?))
   (make-results-url (string?
                      search-type? search-how? any/c 
                      (listof path?) 
                      any/c
                      (union false/c string?)
                      . -> .
                      string?))
   (flush-manuals-url string?)
   (flush-manuals-path string?)
   (make-missing-manual-url (string? string? string? string? . -> . string?))
   (get-hd-location ((lambda (sym) (memq sym hd-location-syms))
                     . -> . 
                     string))
   [make-docs-plt-url (string? . -> . string?)]
   [make-docs-html-url (string? . -> . string?)])

  (define (make-docs-plt-url manual-name)
    (format "http://download.plt-scheme.org/doc/~a/bundles/~a-doc.plt"
            (if (repos-or-nightly-build?)
                "pre-release"
                (version))
            manual-name))
  
  (define (make-docs-html-url manual-name)
    (format "http://download.plt-scheme.org/doc/~a/html/~a/index.htm" 
            (if (repos-or-nightly-build?)
                "pre-release"
                (version))
            manual-name))
  
  (define (prefix-with-server cookie suffix)
    (format "http://~a:~a~a" internal-host internal-port suffix))
  
  (define results-url-prefix (format "http://~a:~a/servlets/results.ss?" internal-host internal-port))
  (define flush-manuals-path "/servlets/results.ss?flush=yes")
  (define flush-manuals-url (format "http://~a:~a~a" internal-host internal-port flush-manuals-path))
  
  
  (define relative-results-url-prefix "/servlets/results.ss?")

  (define home-page-url (format "http://~a:~a/servlets/home.ss" internal-host internal-port))
  
  (define (make-missing-manual-url cookie coll name link)
    (format "http://~a:~a/servlets/missing-manual.ss?manual=~a&name=~a&link=~a"
            internal-host
            internal-port
            coll
            (hexify-string name)
            (hexify-string link)))
  
  (define (make-relative-results-url search-string search-type match-type lucky? manuals doc.txt? lang-name)
    (string-append
     relative-results-url-prefix
     (make-results-url-args search-string search-type match-type lucky? manuals doc.txt? lang-name)))

  (define (make-results-url search-string search-type match-type lucky? manuals doc.txt? lang-name)
    (string-append
     results-url-prefix
     (make-results-url-args search-string search-type match-type lucky? manuals doc.txt? lang-name)))
  
  (define (make-results-url-args search-string search-type match-type lucky? manuals doc.txt? language-name)
    (let ([start
           (format
            (string-append "search-string=~a&"
                           "search-type=~a&"
                           "match-type=~a&"
                           "lucky=~a&"
                           "manuals=~a&"
                           "doctxt=~a")
            (hexify-string search-string)
            search-type
            match-type
            (if lucky? "true" "false")
            (hexify-string (format "~s" (map path->bytes manuals)))
            (if doc.txt? "true" "false"))])
      (if language-name
          (string-append start (format "&langname=~a" (hexify-string language-name)))
          start)))
  
  ; sym, string assoc list
  (define hd-locations
    '((hd-tour "/doc/tour/")
      (release-notes "/servlets/release/notes.ss")
      (plt-license "/servlets/release/license.ss")
      (front-page "/servlets/home.ss")))
  
  (define hd-location-syms (map car hd-locations))

  (define (get-hd-location sym)
    ; the assq is guarded by the contract
    (let ([entry (assq sym hd-locations)])
      (prefix-with-server (cadr entry)))))
