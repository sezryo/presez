(setq lexical-binding t)

(message "Start loading init.el")

(defvar host-dir (concat user-emacs-directory "host/"))
(if (file-exists-p host-dir)
    (progn
      (message "Start loading host init")
      (add-to-list 'load-path host-dir)
      (require 'init-host)
      (message "Finish loading host init"))
  (message "Host file not found"))

;; customise file
(defvar var-dir (concat user-emacs-directory "var/"))
(defvar sync-dir "syncdir/")
(make-directory var-dir :parents)
(setq custom-file (concat var-dir "custom.el"))

;; no temporary files
(defvar backup-dir (concat var-dir "backup"))
(defvar auto-save-dir (concat var-dir "auto-save/"))
(make-directory backup-dir :parents)
(make-directory auto-save-dir :parents)
(setq backup-directory-alist
      `(("." . ,backup-dir)))
(setq auto-save-file-name-transforms
      `((".*" ,auto-save-dir t)))
(setq create-lockfiles nil)


;; theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'catppuccin t)
(setq catppuccin-flavor 'frappe) ;; or 'latte, 'macchiato, or 'mocha
(catppuccin-reload)

;; no menu bar
(menu-bar-mode -1)
;; no tool bar
(tool-bar-mode -1)
;; no scroll bar
(scroll-bar-mode -1)

;; default font
(set-face-attribute 'default nil
                    :family "Jetbrains Mono"
                    :height 90
                    :weight 'normal
                    :width 'normal)

;; no tabs
(setq-default indent-tabs-mode nil)

;; windmove
(windmove-default-keybindings)

;; split thresholds
(setq split-height-threshold 120
      split-width-threshold 120)

;; quoted char radix
(setq read-quoted-char-radix 16)

(defun restart-emacs-daemon ()
  "Restart emacs"
  (interactive)
  (async-shell-command "systemctl --user restart emacs"))

;; packages
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")))
(require 'package)
(add-to-list 'package-directory-list "~/.nix-profile/share/emacs/site-lisp/elpa")
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-demand t)

(use-package ace-window
  :ensure t
  :bind (("M-o" . ace-window)))

(use-package avy
  :ensure t
  :config
  (global-set-key (kbd "C-:") 'avy-goto-char-timer))

(use-package cdlatex
  :ensure t
  :config
  (use-package texmathp
    :ensure auctex)
  :hook ((org-mode . turn-on-org-cdlatex)))

(use-package company
  :ensure t
  :hook ((after-init . global-company-mode)))

(use-package counsel
  :ensure t
  :delight
  :config
  (counsel-mode)
  (use-package ivy
    :ensure t
    :delight
    :config
    (ivy-mode))
  (use-package swiper
    :ensure t
    :config
    (global-set-key (kbd "C-s") 'swiper-isearch)))

(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-mode))

(use-package delight
  :ensure t)

(use-package direnv
  :ensure t
  :config
  (direnv-mode))

(global-display-line-numbers-mode)

(use-package eldoc
  :ensure t)

(use-package expand-region
  :ensure t
  :config
  (global-set-key (kbd "C-=") 'er/expand-region))

(use-package f
  :ensure t)

(use-package fish-mode
  :ensure t)

(use-package flycheck
  :ensure t)

(use-package flycheck-projectile
  :ensure t)

(use-package flyspell
  :ensure nil ; builtin
  :hook ((org-mode . flyspell-mode)
         (TeX-mode . flyspell-mode)))

(use-package haskell-mode
  :ensure t)

(use-package idris-mode
  :ensure t
  :custom
  (idris-interpreter-path "idris2"))

(use-package json-mode
  :ensure t)

(use-package lsp-haskell
  :ensure t)

(use-package lsp-mode
  :ensure t
  :hook ((lsp-mode . (lambda ()
                       (let ((lsp-keymap-prefix "C-c l"))
                         (lsp-enable-which-key-integration))))
         (haskell-mode . lsp)
         (haskell-literate-mode . lsp)
         (c-mode . lsp)
         (tuareg-mode . lsp)
         (c++-mode . lsp)
         (rust-mode . lsp))
  :custom
  (lsp-rust-server 'rust-analyzer)
  (lsp-rust-analyzer-proc-macro-enable t)
  (lsp-rust-analyzer-rustc-source "discover")
  (lsp-rust-analyzer-experimental-proc-attr-macros t)
  :config
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map))

(use-package lsp-ui
  :ensure t)

(use-package lua-mode
  :ensure t)

(use-package magit
  :ensure t)

(use-package markdown-mode
  :ensure t)

(add-to-list 'load-path "~/.nix-profile/share/emacs/site-lisp")
(require 'merlin)
(add-hook 'tuareg-mode-hook 'merlin-mode t)
(custom-set-variables
  '(merlin-command "ocamlmerlin")
)

(use-package nyan-mode
  :ensure t
  :custom
  (nyan-animate-nyancat t)
  (nyan-bar-length 16)
  (nyan-wavy-trail t)
  :config
  (nyan-mode))

(use-package neotree
  :ensure t
  :custom
  (neo-smart-open t)
  :bind
  (("C-c t s" . neotree-show)
   ("C-c t t" . neotree-toggle)))

(use-package nix-mode
  :ensure t)

(use-package ob-rust
  :ensure t)

(use-package org
  :ensure t
  :custom
  (org-directory (concat sync-dir "orgs"))
  (org-startup-indented t)
  ;; done with time information
  (org-log-done 'time)
  :bind (("C-c o l" . org-store-link)
         ("C-c o a" . org-agenda)
         ("C-c o c" . org-capture)))

(use-package org-agenda
  :ensure org
  :custom
  (org-agenda-file-regexp "\\`[^.].*\\.org\\'\\|[0-9-]+")
  :config
  (add-to-list 'org-agenda-files (concat sync-dir "orgs/tasks")))

(use-package org-bullets
  :ensure t
  :custom
  (org-bullets-bullet-list
   '("●"
     "○"
     "✿"
     "❀"
     "◆"
     "◇"))
  :hook (org-mode . (lambda () (org-bullets-mode 1))))

(use-package org-journal
  :ensure t
  :init
  (setq org-journal-prefix-key "C-c j ")
  :custom
  (org-journal-dir (concat sync-dir "orgs/journal"))
  (org-journal-file-format "%Y-%m-%d")
  :config
  ;; include journal in agenda
  (add-to-list 'org-agenda-files (concat sync-dir "orgs/journal")))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (file-truename (concat sync-dir "orgs/notes")))
  (org-roam-completion-everywhere t)
  (org-roam-capture-templates
   (let ((file-format "%<%Y%m%d%H%M%S>-${slug}.org")
         (common-header-before
          [ "#+title: ${title}" ])
         (common-header-after
          [ "#+options: tex:t"
            "#+startup: latexpreview" ]))
     (cl-flet ((build-header (l)
                          (apply 'concat (mapcar (lambda (s) (concat s "\n"))
                                                 (vconcat common-header-before l common-header-after)))))
       `(("d" "default" plain "%?"
          :target (file+head ,file-format ,(build-header [ ]))
          :unnarrowed t)
         ("p" "paper" plain (file ,(concat var-dir "orgs/templates/paper.org"))
          :target (file+head ,file-format ,(build-header [ "#+filetags: Paper" ]))
          :unnarrowed t)))))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies: use org-journal instead
         ;; ("C-c n j" . org-roam-dailies-capture-today)
         :map org-mode-map
         ("C-M-i"   . completion-at-point))
  :config
  ;; db auto sync
  (org-roam-db-autosync-mode))

(defun sync-orgs ()
  "Sync orgs notes"
  (interactive)
  (let ((default-directory org-directory))
    (async-shell-command "nix-shell --command update-all")))

(use-package paredit
  :ensure t)

(use-package pdf-tools
  :ensure t
  :custom
  (doc-view-resolution 300)
  (pdf-view-use-scaling t)
  :config
  (pdf-tools-install))

(use-package popup
  :ensure t)

(use-package projectile
  :ensure t
  :delight
  :custom
  (projectile-switch-project-action 'neotree-projectile-action)
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))

(use-package proof-general
  :ensure t
  :custom
  (proof-three-window-enable t)
  (proof-three-window-mode-policy 'hybrid))

(use-package racket-mode
  :ensure t)

(use-package rainbow-delimiters
  :ensure t)

(use-package rime
  :ensure t
  :custom
  (rime-share-data-dir "@rimeShareDataDir@"))

(use-package rg
  :ensure t)

(use-package rust-mode
  :ensure t)

(use-package scribble-mode
  :ensure t)

(use-package sudo-edit
  :ensure t)

(use-package swift-mode
  :ensure t)

(use-package telega
  :ensure t
  :defer t
  :custom
  (telega-proxies '(( :enable @telegaProxyEnable@
                      :server "@telegaProxyServer@"
                      :port @telegaProxyPort@
                      :type (:@type "proxyTypeSocks5") ))))

(use-package terraform-mode
  :ensure t)

(use-package tex
  :ensure auctex
  :custom
  ;; use default value
  ;; (TeX-view-program-selection '((output-pdf "PDF Tools")))
  (TeX-source-correlate-start-server t)
  (TeX-source-correlate-mode t)
  :config
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer))

(use-package treesit-auto
  :ensure t
  :config
  (global-treesit-auto-mode))

(use-package undo-tree
  :ensure t
  :delight
  :custom
  (undo-tree-history-directory-alist `(("." . ,(concat var-dir "undo-tree"))))
  :config
  (global-undo-tree-mode))

(use-package vterm
  :ensure t)

(use-package which-key
  :ensure t
  :delight
  :config
  (which-key-mode))

(use-package yaml-mode
  :ensure t)

(defun load-agda-mode ()
  "Open init.el file"
  (interactive)
  (load-file (let ((coding-system-for-read 'utf-8))
               (shell-command-to-string "agda-mode locate"))))

(message "Finish loading init.el")
