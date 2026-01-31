(setopt user-mail-address "alexforsale@yahoo.com"
        user-full-name "Kristian Alexander P")

(cond ((file-directory-p (expand-file-name "Sync/org" (getenv "HOME")))
       (customize-set-variable '+config/org-directory (expand-file-name "Sync/org" (getenv "HOME"))))
      ((string-match-p "microsoft" (shell-command-to-string "uname -a"))
       (if (file-directory-p "/mnt/c/Users/SyncthingServiceAcct/Default Folder/org")
           (customize-set-variable '+config/org-directory "/mnt/c/Users/SyncthingServiceAcct/Default Folder/org"))))

(use-package emacs
  :ensure nil
  :config
  (delete-selection-mode 1)
  (transient-mark-mode 1)
  (setopt use-short-answers t
	  delete-by-moving-to-trash t))

(use-package completion-preview
  :ensure nil
  :config
  (global-completion-preview-mode)
  (push 'org-self-insert-command completion-preview-commands))

(use-package minibuffer
  :ensure nil
  :config
  (setopt minibuffer-visible-completions t
	  completion-styles '(basic partial-completion flex emacs22)))

(use-package simple
  :ensure nil
  :config
  (setopt completion-auto-wrap t
	  completion-auto-select t
	  completion-auto-help 'visible
	  completion-ignore-case t))

(use-package which-key
  :ensure nil
  :init
  (which-key-mode 1))

(use-package files
  :ensure nil
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
	  backup-directory-alist `(("." . ,(expand-file-name ".backup" user-emacs-directory))))
  :hook
  ((prog-mode text-mode) . auto-save-visited-mode))

(use-package simple
  :ensure nil
  :config
  (global-visual-line-mode t))
