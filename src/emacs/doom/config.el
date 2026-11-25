;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; Force disable header line globally

;;; Forester support ---------------------------------------------------------
;; Semantic editing for .tree files:
;; - open a tree by title/taxon/address instead of by filename;
;; - insert links/transclusions by title;
;; - use Forester's LSP server through Doom's (lsp +eglot) module when available.

(require 'cl-lib)
(require 'subr-x)

(defgroup yve-forester nil
  "Small Forester helpers for this Doom configuration."
  :group 'tools)

(defcustom yve/forester-auto-start-lsp t
  "When non-nil, start `forester lsp' automatically in `forester-mode'."
  :type 'boolean
  :group 'yve-forester)

(defvar yve/forester-font-lock-keywords
  '(("\\\\[[:alnum:]_/-]+" . font-lock-keyword-face)
    ("\\[\\[\\([[:alnum:]_-]+\\)\\]\\]" 1 font-lock-constant-face)
    ("\\\\\\(title\\|taxon\\|number\\|date\\){\\([^}\n]+\\)}"
     (1 font-lock-keyword-face)
     (2 font-lock-function-name-face)))
  "Basic highlighting for Forester source files.")

(define-derived-mode forester-mode text-mode "Forester"
  "Major mode for Forester .tree files."
  (setq-local font-lock-defaults '(yve/forester-font-lock-keywords))
  (setq-local comment-start "%% ")
  (setq-local comment-end ""))

(add-to-list 'auto-mode-alist '("\\.tree\\'" . forester-mode))

(defun yve/forester-root ()
  "Return the root directory of the current Forester forest."
  (or (locate-dominating-file default-directory "forest.toml")
      (user-error "No forest.toml found above `%s'" default-directory)))

(defun yve/forester--toml-tree-dirs (root)
  "Read simple `trees = [\"...\"]' entries from ROOT/forest.toml.
This intentionally implements only the simple form used by ordinary
Forester forests; when it cannot parse the setting, callers fall back to
the conventional `trees/' directory."
  (let ((toml (expand-file-name "forest.toml" root)))
    (when (file-readable-p toml)
      (with-temp-buffer
        (insert-file-contents toml)
        (goto-char (point-min))
        (when (re-search-forward
               "^[[:space:]]*trees[[:space:]]*=[[:space:]]*\\[\\([^]]+\\)\\]"
               nil t)
          (let ((inside (match-string-no-properties 1))
                dirs)
            (with-temp-buffer
              (insert inside)
              (goto-char (point-min))
              (while (re-search-forward "\"\\([^\"]+\\)\"" nil t)
                (push (match-string-no-properties 1) dirs))
              (nreverse dirs))))))))

(defun yve/forester-tree-directories (&optional root)
  "Return existing tree directories for the Forester forest at ROOT."
  (let* ((root (or root (yve/forester-root)))
         (dirs (or (yve/forester--toml-tree-dirs root) '("trees"))))
    (cl-remove-if-not
     #'file-directory-p
     (mapcar (lambda (dir) (expand-file-name dir root)) dirs))))

(defun yve/forester--first-macro (macro)
  "Return the first one-line value of \\MACRO{...} in the current buffer."
  (goto-char (point-min))
  (when (re-search-forward
         (format "\\\\%s{\\([^}\n]*\\)}" (regexp-quote macro))
         nil t)
    (string-trim (match-string-no-properties 1))))

(defun yve/forester--read-tree (file root)
  "Return a completion candidate `(LABEL . FILE)' for a Forester tree FILE."
  (with-temp-buffer
    (insert-file-contents file nil 0 16000)
    (let* ((title (or (yve/forester--first-macro "title") "(untitled)"))
           (taxon (or (yve/forester--first-macro "taxon") ""))
           (number (or (yve/forester--first-macro "number") ""))
           (id (file-name-base file))
           (rel (file-relative-name file root))
           (label
            (string-trim
             (format "%s%s%s — %s [%s]"
                     title
                     (if (string-empty-p taxon) "" (format " (%s)" taxon))
                     (if (string-empty-p number) "" (format " #%s" number))
                     id
                     rel))))
      (cons label file))))

(defun yve/forester-tree-candidates ()
  "Return completion candidates for all trees in the current Forester forest."
  (let* ((root (yve/forester-root))
         (dirs (yve/forester-tree-directories root))
         (files (delete-dups
                 (apply #'append
                        (mapcar (lambda (dir)
                                  (directory-files-recursively dir "\\.tree\\'"))
                                dirs)))))
    (unless files
      (user-error "No .tree files found under %s"
                  (mapconcat (lambda (d) (file-relative-name d root)) dirs ", ")))
    (sort
     (mapcar (lambda (file) (yve/forester--read-tree file root)) files)
     (lambda (a b) (string< (car a) (car b))))))

(defun yve/forester--choose-tree (&optional prompt)
  "Choose a Forester tree by semantic metadata and return its file path."
  (let* ((candidates (yve/forester-tree-candidates))
         (choice (completing-read (or prompt "Forester tree: ")
                                  candidates nil t)))
    (cdr (assoc choice candidates))))

(defun yve/forester-open-tree ()
  "Open a Forester tree by title, taxon, number, address, or path."
  (interactive)
  (find-file (yve/forester--choose-tree "Open Forester tree: ")))

(defun yve/forester--choose-tree-id (&optional prompt)
  "Choose a Forester tree and return its address, i.e. its filename stem."
  (file-name-base (yve/forester--choose-tree prompt)))

(defun yve/forester-insert-tree-id ()
  "Choose a Forester tree by title and insert its address."
  (interactive)
  (insert (yve/forester--choose-tree-id "Insert tree address: ")))

(defun yve/forester-insert-link ()
  "Choose a Forester tree by title and insert a [[tree-id]] link."
  (interactive)
  (insert (format "[[%s]]"
                  (yve/forester--choose-tree-id "Insert link to tree: "))))

(defun yve/forester-insert-transclusion ()
  "Choose a Forester tree by title and insert \\transclude{tree-id}."
  (interactive)
  (insert (format "\\transclude{%s}"
                  (yve/forester--choose-tree-id "Transclude tree: "))))

(defun yve/forester-insert-folded-transclusion ()
  "Choose a Forester tree and insert a folded-by-default transclusion."
  (interactive)
  (insert
   (format "\\scope{\n  \\put\\transclude/expanded{false}\n  \\transclude{%s}\n}"
           (yve/forester--choose-tree-id "Insert folded transclusion: "))))

(defun yve/forester-insert-numbered-transclusion ()
  "Choose a Forester tree and insert a numbered transclusion."
  (interactive)
  (insert
   (format "\\scope{\n  \\put\\transclude/numbered{true}\n  \\transclude{%s}\n}"
           (yve/forester--choose-tree-id "Insert numbered transclusion: "))))

(defun yve/forester-eglot-ensure ()
  "Start Forester's Eglot server when available."
  (when (and yve/forester-auto-start-lsp
             (executable-find "forester")
             (require 'eglot nil t))
    (add-to-list 'eglot-server-programs
                 '(forester-mode . ("forester" "lsp")))
    (eglot-ensure)))

(after! eglot
  (add-to-list 'eglot-server-programs
               '(forester-mode . ("forester" "lsp"))))

(add-hook 'forester-mode-hook #'yve/forester-eglot-ensure)

(map! :leader
      (:prefix ("o" . "open")
       (:prefix ("F" . "Forester")
        :desc "Open tree by title" "t" #'yve/forester-open-tree
        :desc "Insert tree address" "i" #'yve/forester-insert-tree-id
        :desc "Insert link" "l" #'yve/forester-insert-link
        :desc "Insert transclusion" "x" #'yve/forester-insert-transclusion
        :desc "Insert folded transclusion" "f" #'yve/forester-insert-folded-transclusion
        :desc "Insert numbered transclusion" "n" #'yve/forester-insert-numbered-transclusion)))

(map! :map forester-mode-map
      :localleader
      :desc "Open tree by title" "t" #'yve/forester-open-tree
      :desc "Insert tree address" "i" #'yve/forester-insert-tree-id
      :desc "Insert link" "l" #'yve/forester-insert-link
      :desc "Insert transclusion" "x" #'yve/forester-insert-transclusion
      :desc "Insert folded transclusion" "f" #'yve/forester-insert-folded-transclusion
      :desc "Insert numbered transclusion" "n" #'yve/forester-insert-numbered-transclusion)
(setq-default header-line-format nil)
(setq pgtk-use-im-context nil)
(setq shell-file-name (executable-find "bash"))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the defalt:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
