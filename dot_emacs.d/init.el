;;;;;;;;;;;;;;;;;;
;; ELPACA SETUP ;;
;;;;;;;;;;;;;;;;;;

(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              : (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                 ,@(when-let ((depth (plist-get order :depth)))
                                                     (list (format "--depth=%d" depth) "--no-single-branch"))
                                                 ,(plist-get order :repo) ,repo))))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Uncomment for systems which cannot create symlinks:
(elpaca-no-symlink-mode)

;; Install use-package support
(elpaca elpaca-use-package
	;; Enable use-package :ensure support for Elpaca.
	(elpaca-use-package-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GENERAL EMACS CONFIG ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq ring-bell-function #'ignore)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq vc-follow-symlinks t)
;; shut the annoying alarm sound up
(setq ring-bell-function 'ignore)
(electric-pair-mode +1)
;; Hide unnecessary UI elements
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(defvar display-line-numbers-type)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode +1)
;; enable history
(recentf-mode 1)
;; automatically load changed files
(defvar global-auto-revert-non-file-buffers)
(defvar auto-revert-verbose)
(global-auto-revert-mode +1)
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)
(show-paren-mode +1)

(setq custom-file "~/.emacs.d/emacs-custom.el")
(when (file-exists-p custom-file)
  (load custom-file))

;;;;;;;;;;;;;;
;; PACKAGES ;;
;;;;;;;;;;;;;;

(use-package solarized-theme :ensure t )

(use-package catppuccin-theme :ensure t)

(use-package doom-themes :ensure t)

(use-package ef-themes
  :ensure t
  :config (load-theme 'ef-bio t))

(use-package magit :ensure t)

(use-package exec-path-from-shell
  :ensure t
  :init (when (memq window-system '(mac ns x))
	  (exec-path-from-shell-initialize)))

(use-package nerd-icons
  :ensure t)

(use-package doom-modeline
  :ensure t
  :after (nerd-icons)
  :init (doom-modeline-mode 1))

(use-package which-key
  :ensure t
  :init (which-key-mode 1))

(use-package ace-window
  :ensure t
  :init (global-set-key (kbd "M-o") 'ace-window))

(use-package paredit
  :ensure t
  :init
  (add-hook 'clojure-mode-hook #'enable-paredit-mode)
  (add-hook 'cider-repl-mode-hook #'enable-paredit-mode)
  (add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode))

(use-package cider
  :ensure t)

(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;; automatic virtualenv setup for python
(use-package auto-virtualenv
  :ensure t
  :init
  (use-package pyvenv
    :ensure t)
  :config
  (add-hook 'python-mode-hook 'auto-virtualenv-set-virtualenv)
  (add-hook 'projectile-after-switch-project-hook 'auto-virtualenv-set-virtualenv)) ;; If using projectile)

(use-package lua-mode
  :ensure t
  :config (add-hook 'lua-mode-hook #'lua-mode))

(use-package evil
  :ensure t
  :custom
  (evil-undo-system 'undo-redo)
  (evil-want-keybinding nil)
  (evil-want-C-u-scroll 1)
  :config (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-paredit
  :ensure t
  :init (add-hook 'paredit-mode-hook #'evil-paredit-mode))

(use-package evil-escape
  :ensure t
  :config
  (setq-default evil-escape-key-sequence "jk")
  (evil-escape-mode +1))

(use-package format-all
  :ensure t
  :commands format-all-mode
  :hook (prog-mode . format-all-mode)
  :config
  (setq-default format-all-formatters
                '(("C"     (astyle "--mode=c"))
                  ("Shell" (shfmt "-i" "4" "-ci")))))


(use-package zig-mode :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completion and Navigation ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Enable vertico
(use-package vertico
  :ensure t
  :custom
  (enable-recursive-minibuffers t)
  (vertico-resize t) 
  (vertico-cycle t) 
  :init
  (vertico-mode +1))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init (marginalia-mode))


;; Example configuration for Consult
(use-package consult
  :ensure t
  :bind (("C-c M-x" . consult-mode-command)
	 ("C-c h" . consult-history)
         ("C-x C-r" . consult-recent-file)
         ([remap Info-search] . consult-info)
         ("C-x b" . consult-buffer) 
         ("C-x r b" . consult-bookmark)	
         ("C-x p b" . consult-project-buffer)
	 ("C-x t c" . consult-theme)
         ("M-y" . consult-yank-pop)
         ("M-g M-g" . consult-goto-line)
         ("M-s d" . consult-find)
         ("M-s c" . consult-locate)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)
         ("M-r" . consult-history))

  :hook (completion-list-mode . consult-preview-at-point-mode)
  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   :preview-key '(:debounce 0.4 any))
  (setq consult-narrow-key "<"))

(use-package embark
  :ensure t
  :bind
  (("C-," . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings)))
  
  (use-package embark-consult
    :ensure t 
    :hook
    (embark-collect-mode . consult-preview-at-point-mode))

(use-package company
  :ensure t
  :init
  (global-set-key (kbd "C-x C-n") 'company-complete)
  (global-company-mode +1)
  ;; Adjust delay and minimum prefix length for company mode
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 2))

(use-package company-quickhelp
  :ensure t
  :config (company-quickhelp-mode))


;;;;;;;;;;;;;
;; KEYMAPS ;;
;;;;;;;;;;;;;

(global-set-key (kbd "<f5>") 'consult-theme)
(global-set-key (kbd "<f2>") 'menu-bar-mode)
(global-set-key [remap dabbrev-expand] 'hippie-expand)
(global-set-key [remap list-buffers] 'ibuffer)

(provide 'init)
;;; init.el ends here
