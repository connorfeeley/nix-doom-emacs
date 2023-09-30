;;; config.el -*- lexical-binding: t; -*-

;; `comp-run-async-workers' is advised to force it to output `doom-cache-dir'/comp/
;; instead of /tmp. Restore the original behaviour.
(advice-remove 'comp-run-async-workers #'comp-run-async-workers@dont-litter-tmpdir)
