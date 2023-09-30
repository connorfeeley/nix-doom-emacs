;;; config.el -*- lexical-binding: t; -*-

;; FIXME: presumably this would need to be done for all consumers of nix-doom-emacs.
;;        Find a way to integrate this into the nix-doom-emacs derivation.

;; `comp-run-async-workers' is advised to force it to output `doom-cache-dir'/comp/
;; instead of /tmp. Restore the original behaviour.
(advice-remove 'comp-run-async-workers #'comp-run-async-workers@dont-litter-tmpdir)

;; Set doom's cache directory to outside of the nix store.
(custom-set-variables '(doom-cache-dir
                        ;; FIXME: should probably use home directory instead.
                        ;; (file-name-concat temporary-file-directory "doom.d" "cache")
                        ;; Use XDG cache dir.
                        (expand-file-name "doom/" (or (getenv-internal "XDG_CACHE_HOME") "~/.cache"))))
