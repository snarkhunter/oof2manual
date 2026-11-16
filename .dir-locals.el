;; This tells emacs where the root xml file is, so that it knows the
;; xml flavor being used.  Obtained by googling "tell emacs nxml mode
;; how to find the parent document"

((nxml-mode
  (eval . (let ((root (locate-dominating-file default-directory ".dir-locals.el")))
            (when root
              (nxml-parent-document-set (expand-file-name "man_oof2.xml" root)))))))
