(TeX-add-style-hook
 "init"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "11pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("fontenc" "T1") ("ulem" "normalem") ("vietnam" "utf8")))
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-environments-local "minted")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art11"
    "inputenc"
    "fontenc"
    "graphicx"
    "grffile"
    "longtable"
    "wrapfig"
    "rotating"
    "ulem"
    "amsmath"
    "textcomp"
    "amssymb"
    "capt-of"
    "hyperref"
    "vietnam")
   (LaTeX-add-labels
    "sec:orgf72aa21"
    "sec:orgda3613a"
    "sec:orgdf484df"
    "sec:org041d096"
    "sec:org8622ded"
    "sec:org8d90c99"
    "sec:orge7fd6ce"
    "sec:org32abe88"
    "sec:org4261dd5"
    "sec:org3bed63b"
    "sec:org3615f16"
    "sec:org1c58642"
    "sec:org5531610"
    "sec:org15548c5"
    "sec:org5f9a376"
    "sec:org2700791"
    "sec:org876840b"
    "sec:orgeba9eab"
    "sec:orgf97159f"
    "sec:org310c788"
    "sec:orgb20ca7b"
    "sec:org4a654b2"
    "sec:org88b2556"
    "sec:org6c80e8c"
    "sec:org5646bf8"))
 :latex)

