;;; init --- `Emacs' Initialization file -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;; identity
(setopt user-mail-address "alexforsale@yahoo.com"
        user-full-name "Kristian Alexander P")

;;; `+config/org-directory'
(cond ((file-directory-p (expand-file-name "Sync/org" (getenv "HOME")))
       (customize-set-variable '+config/org-directory (expand-file-name "Sync/org" (getenv "HOME"))
                               "`+config/org-directory' set on Linux Syncthing folder."))
      ((string-match-p "microsoft" (shell-command-to-string "uname -a"))
       (if (file-directory-p "/mnt/c/Users/SyncthingServiceAcct/Default Folder/org")
           (customize-set-variable '+config/org-directory "/mnt/c/Users/SyncthingServiceAcct/Default Folder/org"
                                   "`+config/org-directory set on Windows.'")
	 (if (file-directory-p "/mnt/c/Users/alexforsale/Sync/org")
	     (customize-set-variable '+config/org-directory "/mnt/c/Users/alexforsale/Sync/Org"
				     "`+config/org-directory set on Windows.'")))))
(setopt org-directory +config/org-directory)

;;; custom functions
(defun my/move-line-or-region-internal (arg)
   (cond
    ((and mark-active transient-mark-mode)
     (if (> (point) (mark))
            (exchange-point-and-mark))
     (let ((column (current-column))
              (text (delete-and-extract-region (point) (mark))))
       (forward-line arg)
       (move-to-column column t)
       (set-mark (point))
       (insert text)
       (exchange-point-and-mark)
       (setq deactivate-mark nil)))
    (t
     (beginning-of-line)
     (when (or (> arg 0) (not (bobp)))
       (forward-line)
       (when (or (< arg 0) (not (eobp)))
            (transpose-lines arg))
       (forward-line -1)))))

(defun my/move-line-or-region-down (arg)
   "Move region (transient-mark-mode active) or current line ARG lines down."
   (interactive "*p")
   (my/move-line-or-region-internal arg))

(defun my/move-line-or-region-up (arg)
   "Move region (transient-mark-mode active) or current line ARG lines up."
   (interactive "*p")
   (my/move-line-or-region-internal (- arg)))

(keymap-global-set "C-c M-n" '("Move line or region down" . my/move-line-or-region-down))
(keymap-global-set "C-c M-p" '("Move line or region up" . my/move-line-or-region-up))

(defvar my/move-line-or-region-repeat-map
  (let ((map (make-sparse-keymap)))
    (define-key map "n" #'my/move-line-or-region-down)
    (define-key map "p" #'my/move-line-or-region-up)
    map)
  "Keymap for my/move-line-or-region-repeat-map")
(put 'my/move-line-or-region-down 'repeat-map 'my/move-line-or-region-repeat-map)
(put 'my/move-line-or-region-up 'repeat-map 'my/move-line-or-region-repeat-map)

;;; enable `delete-selection-mode'
(use-package delsel
  :ensure nil
  :config
  (delete-selection-mode 1))

;;; base
(use-package emacs
  :ensure nil
  :custom
  (context-menu-mode t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  :config
  (transient-mark-mode 1)
  (setopt use-short-answers t
          delete-by-moving-to-trash t
          load-prefer-newer t
          ;; read-buffer-completion-ignore-case t
          ;; read-file-name-completion-ignore-case t
          inhibit-startup-screen t
          indicate-empty-lines t
          frame-resize-pixelwise t))

;;; tramp
(use-package tramp
  :ensure nil
  :config
  (setopt tramp-remote-path
          (append tramp-remote-path
 	          '(tramp-own-remote-path))))
;;; repeat
(use-package repeat
  :ensure nil
  :config
  (repeat-mode 1))

;;; enable `global-font-lock-mode'
(use-package font-core
  :ensure nil
  :config
  (global-font-lock-mode 1))

;;; winner
(use-package winner
  :ensure nil
  :init
  (winner-mode +1)
  :config
  (setopt winner-boring-buffers '("*Completions*" "*Compile-Log*" "*inferior-lisp*" "*Fuzzy Completions*"
                                  "*Apropos*" "*Help*" "*cvs*" "*Buffer List*" "*Ibuffer*"
                                  "*esh command on file*")))

;;; completion
;; (use-package completion-preview
;;   :ensure nil
;;   :config
;;   (global-completion-preview-mode)
;;   (push 'org-self-insert-command completion-preview-commands))

;; (use-package minibuffer
;;   :ensure nil
;;   :config
;;   (setopt minibuffer-visible-completions t
;;           completion-styles '(basic partial-completion flex emacs22)))

(use-package simple
  :ensure nil
  :config
  (global-visual-line-mode t)
  (column-number-mode t)
  (line-number-mode t)
  ;; (setopt completion-auto-wrap t
  ;;         completion-auto-select 'second-tab
  ;;         completion-auto-help nil
  ;;         completion-ignore-case t)
  (setq-default indent-tabs-mode nil))

;; (use-package icomplete
;;   :ensure nil
;;   :config
;;   (fido-vertical-mode 1))

;;; saveplace
(use-package saveplace
  :init
  (save-place-mode 1))

;;; recentf
(use-package recentf
  :bind ("C-c f" . recentf)
  :commands recentf-open-files
  :init
  (recentf-mode 1)
  :custom
  (recentf-auto-cleanup t)
  (recentf-max-saved-items 250)
  (recentf-max-menu-items 300)
  (recentf-exclude
   `("/elpa/" ;; ignore all files in elpa directory
     "recentf" ;; remove the recentf load file
     ".*?autoloads.el$"
     "treemacs-persist"
     "company-statistics-cache.el" ;; ignore company cache file
     "/intero/" ;; ignore script files generated by intero
     "/journal/" ;; ignore daily journal files
     ".gitignore" ;; ignore `.gitignore' files in projects
     "/tmp/" ;; ignore temporary files
     "NEWS" ;; don't include the NEWS file for recentf
     "bookmarks"  "bmk-bmenu" ;; ignore bookmarks file in .emacs.d
     "loaddefs.el"
     "^/\\(?:ssh\\|su\\|sudo\\)?:" ;; ignore tramp/ssh files
     (concat "^" (regexp-quote (or (getenv "XDG_RUNTIME_DIR")
                                   "/run"))))))

;;; autorevert
(use-package autorevert
  :ensure nil
  :config
  (global-auto-revert-mode t)
  (setopt auto-revert-interval 60
          global-auto-revert-non-file-buffers t))

;;; which-key
(use-package which-key
  :ensure nil
  :init
  (which-key-mode 1))

;;; files
(use-package files
  :ensure nil
  :hook
  ((prog-mode text-mode) . auto-save-visited-mode)
  :config
  (auto-save-visited-mode 1)
  (nconc
   auto-mode-alist
   '(("/LICENSE\\'" . text-mode)
     ("\\.log\\'" . text-mode)
     ("rc\\'" . conf-mode)
     ("\\.\\(?:hex\\|nes\\)\\'" . hexl-mode)))
  (setopt auto-save-visited-interval 10
          revert-without-query (list ".")
          find-file-suppress-same-file-warnings t
          find-file-visit-truename t
          confirm-kill-processes nil
          version-control t
          backup-by-copying t
          backup-directory-alist `(("." . ,(expand-file-name ".backup" user-emacs-directory)))
          auto-save-list-file-prefix (expand-file-name ".autosave/" user-emacs-directory)
          require-final-newline t
          find-file-visit-truename t
          auto-mode-case-fold nil)
  :hook
  ((prog-mode text-mode) . auto-save-visited-mode))

;;; savehist
(use-package savehist
  :ensure nil
  :config
  (savehist-mode 1)
  (setopt savehist-additional-variables
          '(command-history
            kill-ring
            register-alist
            mark-ring
            global-mark-ring
            search-ring
            regexp-search-ring)))

;;; project
(use-package project
  :ensure nil
  :config
  (setopt project-mode-line t))

;;; mouse
(use-package mouse
  :ensure nil
  :config
  (setopt mouse-yank-at-point t))

;;; subword
(use-package subword
  :ensure nil
  :init
  (global-subword-mode 1))

;;; text-mode
(use-package text-mode
  :ensure nil
  :hook (((text-mode prog-mode) . visual-line-mode)
         (prog-mode . (lambda () (setq-local sentence-end-double-space t))))
  :config
  (setq-default sentence-end-double-space nil)
  (setopt sentence-end-without-period nil)
  (setopt colon-double-space nil)
  (setopt adaptive-fill-mode t))

;;; server
(use-package server
  :ensure nil
  :config
  (unless (server-running-p)
    (server-start))
  (require 'org-protocol))

;; spelling
(use-package ispell
  :ensure nil
  :config
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "en_US,id_ID")
  (add-to-list 'ispell-dictionary-alist
               '("en_US" "[[:alpha:]]" "[^[:alpha:]]" "['’]" nil ("-d" "en_US") nil utf-8))
  (setopt ispell-program-name (or (executable-find "ispell")
                                  (executable-find "hunspell")
                                  (executable-find "aspell"))
          ispell-dictionary "en_US,id_ID"
          ispell-personal-dictionary (expand-file-name ".hunspell_personal" (getenv "XDG_DATA_HOME"))))

(unless (file-exists-p ispell-personal-dictionary)
  (write-region "" nil ispell-personal-dictionary nil 0))

(use-package flyspell
  :ensure nil)

;;; `help'
(use-package help
  :ensure nil
  :config
  (setopt help-window-select t))

;;; `org-mode'
(use-package org
  :ensure nil
  :demand t
  :commands org-tempo
  :hook (org-mode . flyspell-mode)
  :hook ((org-mode . org-indent-mode)
         (org-mode . +config/org-prettify-symbols))
  :config
  (cond ((file-directory-p (expand-file-name "braindump/org" org-directory))
         (customize-set-variable '+config/org-roam-directory
                                 (expand-file-name "braindump/org" org-directory)
                                 "`+config/org-roam-directory' set inside `org-directory'"))
        ((file-directory-p (expand-file-name "Projects/personal/braindump/org" (getenv "HOME")))
         (customize-set-variable '+config/org-roam-directory
                                 (expand-file-name "Projects/personal/braindump/org" (getenv "HOME"))
                                 "`+config/org-roam-directory' set inside personal projects directory")))
  (cond ((file-directory-p (expand-file-name "alexforsale.github.io" org-directory))
         (customize-set-variable '+config/blog-directory
                                 (expand-file-name "alexforsale.github.io" org-directory)
                                 "`+config/blog-directory' set inside `org-directory'"))
        ((file-directory-p (expand-file-name "Projects/personal/alexforsale.github.io" (getenv "HOME")))
         (customize-set-variable '+config/blog-directory
                                 (expand-file-name "Projects/personal/alexforsale.github.io" (getenv "HOME"))
                                 "`+config/blog-directory' set inside personal projects directory")))
  (modify-syntax-entry ?= "$" org-mode-syntax-table)
  (modify-syntax-entry ?~ "$" org-mode-syntax-table)
  (modify-syntax-entry ?_ "$" org-mode-syntax-table)
  (modify-syntax-entry ?+ "$" org-mode-syntax-table)
  (modify-syntax-entry ?/ "$" org-mode-syntax-table)
  (modify-syntax-entry ?* "$" org-mode-syntax-table)
  (add-to-list 'org-modules 'org-tempo t)
  (add-to-list 'org-structure-template-alist '("sh" . "src sh"))
  (add-to-list 'org-structure-template-alist '("co" . "src conf"))
  (add-to-list 'org-structure-template-alist '("lisp" . "src lisp"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("sc" . "src scheme"))
  (add-to-list 'org-structure-template-alist '("ts" . "src typescript"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("go" . "src go"))
  (add-to-list 'org-structure-template-alist '("yaml" . "src yaml"))
  (add-to-list 'org-structure-template-alist '("js" . "src js"))
  (add-to-list 'org-structure-template-alist '("json" . "src json"))
  (add-to-list 'org-structure-template-alist '("n" . "note"))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (awk . t)
     (C . t)
     (css . t)
     (calc . t)
     (ditaa . t) ; needs the `ditaa' package
     (dot . t ) ; `graphviz'
     (screen . t)
     (haskell . t)
     (java . t)
     (js . t)
     (latex . t)
     (lisp . t)
     (lua . t)
     (org . t)
     (perl . t)
     (plantuml . t)
     (python .t)
     (ruby . t)
     (shell . t)
     (sed . t)
     (scheme . t)
     (sql . t)
     (sqlite . t)))
  (setq-default org-use-sub-superscripts '{})
  (add-to-list 'org-babel-tangle-lang-exts '("js" . "js"))
  (defun +config/org-prettify-symbols ()
    (push '("[ ]" . "☐") prettify-symbols-alist)
    (push '("[X]" . "☑") prettify-symbols-alist)
    (prettify-symbols-mode t))
  (require 'org-tempo)
  :custom
  (org-highlight-latex-and-related nil)
  (org-replace-disputed-keys t)
  (org-indirect-buffer-display 'current-window)
  (org-enforce-todo-dependencies t)
  (org-fontify-whole-heading-line t)
  (org-return-follows-link t)
  (org-mouse-1-follows-link t)
  (org-image-actual-width nil)
  (org-adapt-indentation nil)
  (org-startup-indented t)
  (org-link-descriptive nil)
  (org-log-done 'time)
  (org-log-refile 'time)
  (org-log-redeadline 'time)
  (org-log-reschedule 'time)
  (org-log-into-drawer t)
  (org-clone-delete-id t)
  (org-default-notes-file (expand-file-name "notes.org" org-directory))
  (org-insert-heading-respect-content nil)
  (org-pretty-entities t)
  (org-use-property-inheritance t)
  (org-priority-highest ?A)
  (org-priority-lowest ?D)
  (org-priority-default ?B)
  (org-todo-keywords
   '((sequence
      "TODO(t!)"  ; A task that needs doing & is ready to do
      "NEXT(n!)"  ; Tasks that can be delayed
      "PROG(p!)"  ; A task that is in progress
      "WAIT(w!)"  ; Something external is holding up this task
      "HOLD(h!)"  ; This task is paused/on hold because of me
      "|"
      "DONE(d!)"  ; Task successfully completed
      "DELEGATED(l!)" ; Task is delegated
      "NOTES(o!)" ; set as notes
      "KILL(k!)") ; Task was cancelled, aborted or is no longer applicable
     )))

(keymap-global-set "C-c l" #'("Org store link" . org-store-link))
(keymap-global-set "C-c a" #'("Org agenda" . org-agenda))
(keymap-global-set  "C-c c" #'("Org capture" . org-capture))

(use-package org-entities
  :ensure nil
  :config
  (setopt org-entities-user
          '(("flat"  "\\flat" nil "" "" "266D" "♭")
            ("sharp" "\\sharp" nil "" "" "266F" "♯"))))

(use-package org-faces
  :ensure nil
  :custom
  (org-fontify-quote-and-verse-blocks t))

(use-package org-archive
  :ensure nil
  :after org
  :custom
  (org-archive-tag "archive")
  (org-archive-subtree-save-file-p t)
  (org-archive-mark-done t)
  (org-archive-reversed-order t)
  (org-archive-location (concat (expand-file-name "archives.org" org-directory) "::datetree/* Archived Tasks")))

(use-package org-capture
  :after org
  :ensure nil
  :demand t
  :config
  (org-capture-put :kill-buffer t)
  (setq org-capture-templates ;; this is the default from `doom'.
        `(("i" "Inbox - Goes Here first!" entry
           (file+headline ,(expand-file-name "inbox.org" org-directory) "Inbox")
           "** %?\n%i\n%a" :prepend t)
          ;; ("r" "Request" entry (file+headline ,(expand-file-name "inbox.org" org-directory) "Request")
          ;;  (file ,(expand-file-name "request.template" org-directory)))
          ("l" "Links" entry
           (file+headline ,(expand-file-name "links.org" org-directory) "Links")))))

(use-package org-refile
  :ensure nil
  :after org
  :hook (org-after-refile-insert . save-buffer)
  :custom
  (org-refile-targets
   `((,(expand-file-name "projects.org" org-directory) :maxlevel . 1)
     (,(expand-file-name "notes.org" org-directory) :maxlevel . 1)
     (,(expand-file-name "routines.org" org-directory) :maxlevel . 3)
     (,(expand-file-name "personal.org" org-directory) :maxlevel . 1)))
  (org-refile-use-outline-path 't)
  (org-outline-path-complete-in-steps nil))

(use-package org-fold
  :ensure nil
  :custom
  (org-fold-catch-invisible-edits 'smart))

(use-package org-id
    :ensure nil
    :after org
    :custom
    (org-id-locations-file-relative t)
    (org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id))

(use-package org-num
    :ensure nil
    :after org
    :custom
    (org-num-face '(:inherit org-special-keyword :underline nil :weight bold))
    (org-num-skip-tags '("noexport" "nonum")))

(use-package org-crypt ; built-in
    :ensure nil
    :after org
    :commands org-encrypt-entries org-encrypt-entry org-decrypt-entries org-decrypt-entry
    ;;:hook (org-reveal-start . org-decrypt-entry)
    :preface
    ;; org-crypt falls back to CRYPTKEY property then `epa-file-encrypt-to', which
    ;; is a better default than the empty string `org-crypt-key' defaults to.
    (defvar org-crypt-key nil)
    (with-eval-after-load 'org
      (add-to-list 'org-tags-exclude-from-inheritance "crypt"))
    :config
    (setopt epa-file-encrypt-to "alexforsale@yahoo.com"))

(use-package org-attach
    :ensure nil
    :after org
    :commands (org-attach-new
               org-attach-open
               org-attach-open-in-emacs
               org-attach-reveal-in-emacs
               org-attach-url
               org-attach-set-directory
               org-attach-sync)
    :config
    (unless org-attach-id-dir
      (setq-default org-attach-id-dir (expand-file-name ".attach/" org-directory)))
    (with-eval-after-load 'projectile
      (add-to-list 'projectile-globally-ignored-directories org-attach-id-dir))
    :custom
    (org-attach-auto-tag nil))

(use-package org-agenda
    :ensure nil
    :after org
    :custom
    (org-agenda-breadcrumbs-separator " → ")
    (org-agenda-files (list (concat org-directory "/")))
    (org-agenda-file-regexp "\\`[^.].*\\.org\\|[0-9]+$\\'")
    (org-agenda-include-inactive-timestamps t)
    (org-agenda-window-setup 'only-window)
    (org-stuck-projects '("+{project*}-killed-Archives/-DONE-KILL-DELEGATED"
                          ("TODO" "NEXT" "IDEA" "PROG")
                          nil ""))
    :config
    (with-eval-after-load 'evil
      (evil-set-initial-state #'org-agenda-mode 'normal)
      (evil-define-key 'normal org-agenda-mode-map "q" 'org-agenda-quit))
    (setopt org-agenda-custom-commands
          `(("w" "Work Agenda and all TODOs"
             ((agenda ""
                      ((org-agenda-span 1)
                       (org-agenda-start-on-weekday t)
                       (org-agenda-block-separator nil)
                       (org-agenda-use-time-grid t)
                       (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                       (org-agenda-format-date "%A %-e %B %Y")
                       (org-agenda-overriding-header "\nToday\n")))
              (tags-todo "TODO=\"TODO\"|\"NEXT\""
                         ((org-agenda-block-separator nil)
                          (org-agenda-skip-function '(org-agenda-skip-if-todo 'nottodo 'done))
                          (org-agenda-use-time-grid nil)
                          (org-agenda-overriding-header "\nIncomplete\n")))
              (agenda ""
                      ((org-agenda-span 7)
                       (org-agenda-start-on-weekday 1)
                       (org-agenda-block-separator nil)
                       (org-agenda-use-time-grid nil)
                       (org-agenda-overriding-header "\nWeekly\n"))))
             ((org-agenda-tag-filter-preset '("-personal" "-home"))))
            ("h" "Home Agenda and all personal TODOs"
             ((agenda ""
                      ((org-agenda-span 1)
                       (org-agenda-start-on-weekday t)
                       (org-agenda-block-separator nil)
                       (org-agenda-use-time-grid t)
                       (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                       (org-agenda-format-date "%A %-e %B %Y")
                       (org-agenda-overriding-header "\nToday\n")))
              (tags-todo "TODO=\"TODO\"|\"NEXT\""
                         ((org-agenda-block-separator nil)
                          (org-agenda-skip-function '(org-agenda-skip-if-todo 'nottodo 'done))
                          (org-agenda-use-time-grid nil)
                          (org-agenda-overriding-header "\nIncomplete\n")))
              (agenda ""
                      ((org-agenda-span 7)
                       (org-agenda-start-on-weekday 1)
                       (org-agenda-block-separator nil)
                       (org-agenda-use-time-grid nil)
                       (org-agenda-overriding-header "\nWeekly\n"))))
             ;; ((org-agenda-tag-filter-preset '("+personal")))
             ))))

(use-package org-clock
    :ensure nil
    :after org
    :commands org-clock-save
    :hook (kill-emacs . org-clock-save)
    :custom
    (org-persist 'history)
    (org-clock-in-resume t)
    (org-clock-out-remove-zero-time-clocks t)
    (org-clock-history-length 20)
    (org-show-notification-handler "notify-send")
    (org-agenda-skip-scheduled-if-deadline-is-shown t)
    :config
    (org-clock-persistence-insinuate))

(use-package org-timer
    :ensure nil
    :config
    (setopt org-timer-format "Timer :: %s"))

(use-package org-contrib)

(use-package org-eldoc
  :ensure nil
  :after org org-contrib
  :config
  (puthash "org" #'ignore org-eldoc-local-functions-cache)
  ;;(puthash "plantuml" #'ignore org-eldoc-local-functions-cache)
  (puthash "python" #'python-eldoc-function org-eldoc-local-functions-cache)
  :custom
  (org-eldoc-breadcrumb-separator " → "))

(use-package pdf-tools
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-width)
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
  :custom
  (pdf-annot-activate-created-annotations t "automatically annotate highlights"))

;;; `prog-mode'
;;; delete trailing whitespace and enable `electric-pair-local-mode'
(use-package prog-mode
  :ensure nil
  :hook
  (prog-mode . (lambda ()
                 (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)
                 (electric-pair-local-mode 1))))

(use-package display-line-numbers
  :ensure nil
  :hook (prog-mode . display-line-numbers-mode)
  :config
  (setopt display-line-numbers-type 'relative))

(use-package sh-script
    :ensure nil
    :config
    (setopt sh-indentation 2))

(use-package executable
    :ensure nil
    :hook
    (after-save . executable-make-buffer-file-executable-if-script-p))

;;; eglot
(use-package eglot
  :ensure nil
  :config
  (setopt eglot-autoshutdown t)
  (add-to-list 'eglot-server-programs
               `((nix-mode nix-ts-mode)
                 . ("nixd" "--semantic-tokens" "--inlay-hints"
                    :initializationOptions
                    (:nixd.nixpkgs.expr "import (builtins.getFlake \"/etc/nixos\").input.nixpkgs { }"
                                        :nixd.formatting.command ["nixfmt"]
                                        :nixd.options.nixos.expr ,(concat "(builtins.getFlake \"/etc/nixos\").nixosConfigurations." system-name ".options")
                                        :nixd.options.home_manager.expr ,(concat "(builtins.getFlake \"/etc/nixos\").homeConfigurations." "\"" user-login-name "@" system-name "\".options")
                                        :diagnostic.suppress ["sema-extra-with"])))))

;;; python
(add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))

(use-package python-ts-mode
  :ensure nil
  :hook (python-ts-mode . eglot-ensure))

;;; make-mode
(use-package make-mode
  :ensure nil
  :config
  (add-hook 'makefile-mode-hook 'indent-tabs-mode))

;;; external packages

;;; `vertico'
(use-package vertico
  :hook
  (rfn-eshadow-update-overlay . vertico-directory-tidy)
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-count 10) ;; Show more candidates
  (vertico-resize nil) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :config
  (advice-add #'tmm-add-prompt :after #'minibuffer-hide-completions)
  (keymap-set vertico-map "?" #'minibuffer-completion-help)
  :init
  (vertico-mode))

;;; `vertico-directory'
(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;;; `vertico-quick'
(use-package vertico-quick
  :after vertico
  :ensure nil
  :bind (:map vertico-map
              ("M-q" . vertico-quick-insert)
              ("C-q" . vertico-quick-exit)))

;;; `marginalia'
(use-package marginalia
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

;;; `orderless'
(use-package orderless
  :init
  (setopt completion-styles '(orderless basic substring partial-completion)
          completion-category-defaults nil
          completion-category-overrides
          '((file (styles orderless partial-completion)))
          orderless-component-separator #'orderless-escapable-split-on-space))

;;; `consult'
(use-package consult
  :bind (("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
                  ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  (setopt register-preview-delay 0.5
          register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)
  (setopt xref-show-xrefs-function #'consult-xref
          xref-show-definitions-function #'consult-xref)
  :config
  (setopt consult-narrow-key "<"
          consult-line-numbers-widen t
          consult-async-min-input 2
          consult-async-refresh-delay  0.15
          consult-async-input-throttle 0.2
          consult-async-input-debounce 0.1)
  (keymap-set isearch-mode-map "M-e" #'consult-isearch-history)
  (keymap-set isearch-mode-map "M-l" #'consult-line)
  (keymap-set isearch-mode-map "M-L" #'consult-line-multi)

  (keymap-set minibuffer-local-map "M-s" #'consult-history)
  (keymap-set minibuffer-local-map "M-r" #'consult-history)

  (keymap-global-set "<remap> <Info-search>" '("Consult info" . consult-info))
  (keymap-global-set "<remap> <yank-pop>" '("Consult yank-pop" . consult-yank-pop))
  (keymap-global-set "<remap> <bookmark-jump>" '("Consult bookmark" . consult-bookmark))
  (keymap-global-set "<remap> <goto-line>" '("Consult goto-line" . consult-goto-line))
  (keymap-global-set "<remap> <imenu>" '("Consult imenu" . consult-imenu))
  (keymap-global-set "<remap> <locate>" '("Consult locate". consult-locate))
  (keymap-global-set "<remap> <load-theme>" '("Consult theme" . consult-theme))
  (keymap-global-set "<remap> <man>" '("Consult man" . consult-man))
  (keymap-global-set "<remap> <recentf-open-files>" '("Consult recent-file" . consult-recent-file))
  (keymap-global-set "<remap> <switch-to-buffer>" '("Consult buffer" . consult-buffer))
  (keymap-global-set "<remap> <switch-to-buffer-other-frame>" '("Consult buffer other frame" . consult-buffer-other-frame))
  (keymap-global-set "<remap> <switch-to-buffer-other-window>" '("Consult buffer other window" . consult-buffer-other-window)))

;;; `corfu'
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.18)
  (corfu-auto-prefix 2)
  (corfu-quit-no-match 'separator)
  (corfu-preselect 'prompt)
  (corfu-count 16)
  (corfu-max-width 120)
  (corfu-on-exact-match nil)
  (corfu-quit-no-match corfu-quit-at-boundary)
  (completion-cycle-threshold 3)
  (text-mode-ispell-word-completion nil)
  :config
  (defun corfu-enable-always-in-minibuffer ()
    "Enable Corfu in the minibuffer if Vertico/Mct are not active."
    (unless (or (bound-and-true-p mct--active)
                (bound-and-true-p vertico--input)
                (eq (current-local-map) read-passwd-map))
      ;; (setq-local corfu-auto nil) ;; Enable/disable auto completion
      (setq-local corfu-echo-delay nil ;; Disable automatic echo and popup
                  corfu-popupinfo-delay nil)
      (corfu-mode 1)))
  (add-hook 'minibuffer-setup-hook #'corfu-enable-always-in-minibuffer 1))

;;; `cape'
(use-package cape
  :bind (("C-c p p" . completion-at-point) ;; capf
         ("C-c p t" . complete-tag)        ;; etags
         ("C-c p d" . cape-dabbrev))       ;; or dabbrev-completion
  :hook
  (prog-mode . +corfu-add-cape-file-h)
  ((org-mode markdown-mode) . +corfu-add-cape-elisp-block-h)
  :config
  (setopt cape-dabbrev-check-other-buffers t)
  (defun +corfu-add-cape-file-h ()
    (add-hook 'completion-at-point-functions #'cape-file -10 t))
  (defun +corfu-add-cape-elisp-block-h ()
    (add-hook 'completion-at-point-functions #'cape-elisp-block 0 t))
  (advice-add #'comint-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add #'pcomplete-completions-at-point :around #'cape-wrap-nonexclusive)
  :init
  ;; Add extra completion sources
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;;; `embark'
(use-package embark
  :init
  (setopt prefix-help-command #'embark-prefix-help-command)
  :config
  (keymap-global-set "C-." '("Embark act" . embark-act))
  (keymap-global-set "C-;" '("Embark DWIM" . embark-dwim))
  (keymap-global-set "C-h b" '("Embark bindings" . embark-bindings))
  (setopt which-key-use-C-h-commands nil
  	  prefix-help-command #'embark-prefix-help-command)
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;;; `embark-consult'
(use-package embark-consult
    :hook
    (embark-collect-mode . consult-preview-at-point-mode))

;;; `magit'
(use-package magit
  :demand t
  :config
  (setopt magit-revision-show-gravatars '("^Author:     " . "^Commit:     ")))

;;; `ox-hugo'
(use-package ox-hugo
    :after ox)

(defun my/create-blog-capture-file ()
  "Create a subdirectory and `org-mode' file under `+config/blog-directory'."
  (interactive)
  (let* ((name (read-string "slug: "))
		 (content-dir (expand-file-name "content-org/" +config/blog-directory)))
	(unless (file-directory-p (expand-file-name name content-dir))
	  (make-directory (expand-file-name name content-dir)))
	(expand-file-name (concat name ".org") (expand-file-name name content-dir))))

(add-to-list 'org-capture-templates
	     '("h" "Hugo Post" plain
	       (file my/create-blog-capture-file)
	       "#+options: ':nil -:nil ^:nil num:nil toc:nil
#+author: %n
#+title: %^{Title}
#+description:
#+date: %t
#+hugo_categories: %^{Categories|misc|desktop|emacs|learning}
#+hugo_tags: %^{Tags}
#+hugo_section: posts
#+hugo_base_dir: ../../
#+language: en
#+startup: inlineimages

* %?" :jump-to-captured t))

;;; `markdown-mode'
(use-package markdown-mode)

;;; nix-ts-mode
(use-package nix-ts-mode
  :mode "\\.nix\\'"
  :hook
  ((nix-ts-mode . (lambda () (setq-local tab-width 2)))
   (nix-ts-mode . eglot-ensure)))

;;; `yaml-pro'
(use-package yaml-mode
  :ensure nil
  :mode "\\.yaml\\'"
  :mode "\\.yml\\'")
(add-to-list 'major-mode-remap-alist '(yaml-mode . yaml-ts-mode))

(use-package yaml-ts-mode
  :hook (yaml-ts-mode . (lambda () (define-key yaml-ts-mode-map (kbd "RET") 'newline-and-indent)
                          (indent-bars-mode 1)
                          (setq-local tab-width 2)
                          (eglot-ensure))))

(use-package yaml-pro
  :hook ((yaml-ts-mode . yaml-pro-ts-mode)
         (yaml-ts-mode . eglot-ensure)))

;;; `toml-ts-mode'
(use-package toml-ts-mode
  :ensure nil
  :mode "\\.toml\\'"
  :hook (toml-ts-mode . eglot-ensure)
  :hook (toml-ts-mode . (lambda ()
                          (setq-local tab-width 2)
                          (setq-local require-final-newline t)))
  :config
  (add-to-list 'eglot-server-programs
               '(toml-ts-mode . ("taplo" "lsp" "stdio"))))

;;; `json-ts-mode'
(add-to-list 'major-mode-remap-alist '(js-json-mode . json-ts-mode))

(use-package json-ts-mode
  :ensure nil
  :hook (json-ts-mode . eglot-ensure))

;;; multiple-cursors
(use-package multiple-cursors
  :bind
  (("C->" . mc/mark-next-like-this)
   ("C-<" . mc/mark-previous-like-this)
   ("C-c C-<" . mc/mark-all-like-this)
   ("C-S-c C-S-c" . mc/edit-lines)))

(defvar my/mc-repeat-map
  (let ((map (make-sparse-keymap)))
    (define-key map ">" #'mc/mark-next-like-this)
    (define-key map "<" #'mc/mark-previous-like-this)
    map)
  "Keymap for my/mc-repeat-map")
(put 'mc/mark-next-like-this 'repeat-map 'my/mc-repeat-map)
(put 'mc/mark-previous-like-this 'repeat-map 'my/mc-repeat-map)

;;; rainbow
(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode)
  :config
  (setopt rainbow-html-colors-major-mode-list
  	'(prog-mode conf-mode html-mode css-mode php-mode nxml-mode xml-mode)
  	rainbow-html-colors t))

(use-package rainbow-identifiers
  :hook (prog-mode . rainbow-identifiers-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  (setopt rainbow-delimiters-max-face-count 4))

(use-package indent-bars
  :hook (prog-mode . indent-bars-mode))

(use-package org-rainbow-tags)

(use-package org-modern
  :config
  (set-face-attribute 'org-modern-symbol nil :family "Iosevka Nerd Font")
  (setopt org-auto-align-tags nil
          org-tags-column 0
          org-fold-catch-invisible-edits 'show-and-error
          org-special-ctrl-a/e t
          org-insert-heading-respect-content t
          ;; Org styling, hide markup etc.
          org-hide-emphasis-markers nil ; set to nil for easier editing
          org-ellipsis "…"
          ;; Agenda styling
          org-agenda-tags-column 0
          org-agenda-block-separator ?─
          org-agenda-time-grid
          '((daily today require-timed)
            (800 1000 1200 1400 1600 1800 2000)
            " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
          org-agenda-current-time-string
          "◀── now ─────────────────────────────────────────────────")
  (global-org-modern-mode))

;;; `notmuch'
(use-package notmuch
  :if (executable-find "notmuch")
  :defer t
  :commands (notmuch)
  :bind ("C-c m" . notmuch)
  :hook
  (message-setup . mml-secure-sign-pgpmime)
  :config
  (keymap-global-set "<XF86Mail>" '("Notmuch" . notmuch))
  (setq notmuch-fcc-dirs nil
	notmuch-search-result-format
	'(("date" . "%12s ")
	  ("count" . "%-7s ")
	  ("authors" . "%-30s ")
	  ("subject" . "%-72s ")
	  ("tags" . "(%s)"))
	notmuch-tag-formats
	'(("unread"
	   (propertize tag 'face 'notmuch-tag-unread))
	  ("flagged"
	   (propertize tag 'face 'notmuch-tag-flagged)
	   (notmuch-tag-format-image-data tag
					  (notmuch-tag-star-icon))))
	notmuch-tagging-keys
	'(("a" notmuch-archive-tags "Archive")
	  ("u" notmuch-show-mark-read-tags "Mark read")
	  ("f" ("+flagged") "Flag")
	  ("s" ("+spam" "-inbox") "Mark as spam")
	  ("d" ("+deleted" "-inbox") "Delete"))
	notmuch-saved-searches
	'((:name "flagged" :query "tag:flagged" :key "f")
	  (:name "archive" :query "tag:archive" :key "i")
	  (:name "inbox" :query "tag:inbox" :key "i")
	  (:name "sent" :query "tag:sent" :key "s")
	  (:name "drafts"  :query "tag:draft" :key "d")
	  (:name "all mail" :query "*" :key "a")
	  (:name "unread" :query "tag:unread" :key "u")
	  (:name "Today"
		 :query "date:today AND NOT tag:spam AND NOT tag:bulk"
		 :key "T"
		 :search-type 'tree
		 :sort-order 'newest-first)
	  (:name "This Week"
		 :query "date:weeks AND NOT tag:spam AND NOT tag:bulk"
		 :key "W"
		 :search-type 'tree
		 :sort-order 'newest-first)
	  (:name "This Month"
		 :query "date:months AND NOT tag:spam AND NOT tag:bulk"
		 :key "M"
		 :search-type 'tree
		 :sort-order 'newest-first)
	  (:name "flagged"
		 :query "tag:flagged AND NOT tag:spam AND NOT tag:bulk"
		 :key "f"
		 :search-type 'tree
		 :sort-order 'newest-first)
	  (:name "spam" :query "tag:spam"))
	notmuch-archive-tags '("-inbox" "-unread" "+archive"))
  (setq-default notmuch-search-oldest-first nil)
  (if (executable-find "gpg2")
      (setopt notmuch-crypto-gpg-program "gpg2")
    (setopt notmuch-crypto-gpg-program "gpg"))
  (setopt notmuch-crypto-process-mime t
	  mml-secure-openpgp-sign-with-sender t)
  (define-key notmuch-show-mode-map "S"
	      (lambda ()
		"Mark message as spam"
		(interactive)
		(notmuch-show-tag (list +spam -new)))))

(use-package message
  :ensure nil
  :if (executable-find "notmuch")
  :custom
  (message-directory (expand-file-name ".mail" (getenv "HOME")))
  (message-auto-save-directory (expand-file-name "gmail/drafts" message-directory))
  (message-sendmail-envelope-from 'header))

(use-package sendmail
  :ensure nil
  :if (executable-find "notmuch")
  :custom
  (mail-specify-envelope-from t)
  (mail-envelope-from 'header)
  (send-mail-function 'sendmail-send-it)
  (sendmail-program (executable-find "msmtp")))

(use-package notmuch-addr
  :after notmuch
  :config
  (notmuch-addr-setup))

(use-package ol-notmuch
  :after notmuch)

(use-package notmuch-indicator
  :after notmuch
  :config
  (setopt notmuch-indicator-args
          '((:terms "tag:unread and tag:inbox" :label "U" :label-face success))
          notmuch-indicator-notmuch-config-file
          (or (when (file-exists-p (expand-file-name ".notmuch-config" (getenv "HOME")))
                (file-exists-p (expand-file-name ".notmuch-config" (getenv "HOME"))))
              (when (file-exists-p (getenv "NOTMUCH_CONFIG"))
                (getenv "NOTMUCH_CONFIG"))))
  (notmuch-indicator-mode))

(use-package gruvbox-theme
  :ensure nil
  :config
  (load-theme 'gruvbox t nil))

(use-package org-roam
  :if (not (equal 'windows-nt system-type))
  :after org
  :custom
  (org-roam-directory +config/org-roam-directory)
  (org-roam-complete-everywhere t)
  (org-roam-capture-templates
   '(("d" "default" plain
      "#+author: %n\n#+date: %t\n#+description: \n#+hugo_base_dir: ..\n#+hugo_section: posts\n#+hugo_categories: other\n#+property: header-args :exports both\n#+hugo_tags: \n%?"
      :if-new (file+head "%<%Y-%m-%d_%H-%M-%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("p" "programming" plain
      "#+author: %n\n#+date: %t\n#+description: \n#+hugo_base_dir: ..\n#+hugo_section: posts\n#+hugo_categories: programming\n#+property: header-args :exports both\n#+hugo_tags: \n%?"
      :if-new (file+head "%<%Y-%m-%d_%H-%M-%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("t" "tech" plain
      "#+author: %n\n#+date: %t\n#+description: \n#+hugo_base_dir: ..\n#+hugo_section: posts\n#+hugo_categories: tech\n#+property: header-args :exports both\n#+hugo_tags: \n%?"
      :if-new (file+head "%<%Y-%m-%d_%H-%M-%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)))
  (org-roam-capture-ref-templates
   '(("r" "ref" plain "#+author: %n\n#+date: %t\n#+description: \n#+hugo_base_dir: ..\n#+hugo_section: posts\n#+hugo_categories: reference\n#+property: header-args :exports both\n#+hugo_tags: \n%?\n* Links\n- %l" :target (file+head "${slug}.org" "#+title: ${title}")
      :unnarrowed t)))
  :config
  (org-roam-setup)
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol))

(use-package org-roam-ui
  :after org-roam ;; or :after org
  ;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
  ;;         a hookable mode anymore, you're advised to pick something yourself
  ;;         if you don't care about startup time, use
  ;;  :hook (after-init . org-roam-ui-mode)
  :config
  (setopt org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))

(provide 'init)
;;; init.el ends here
