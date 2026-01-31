(customize-set-variable 'custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))
(add-to-list 'default-frame-alist '(menu-bar-lines . 0))
(add-to-list 'initial-frame-alist '(menu-bar-lines . 0))

(add-to-list 'initial-frame-alist '(tool-bar-lines . 0))
(add-to-list 'default-frame-alist '(tool-bar-lines . 0))

(add-to-list 'initial-frame-alist '(vertical-scroll-bars))
(add-to-list 'default-frame-alist '(vertical-scroll-bars))

(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(with-eval-after-load 'package
  (setopt package-enable-at-startup nil)
  ;; Add `melpa` to `package-archives`.
  (add-to-list 'package-archives
               '("melpa" . "https://melpa.org/packages/") t)
  ;; gnu-devel
  (add-to-list 'package-archives '("gnu-devel" . "https://elpa.gnu.org/devel/") t)
  (add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t))

(setopt use-package-compute-statistics t)
