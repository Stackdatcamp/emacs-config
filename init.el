(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("elpy" . "https://jorgenschaefer.github.io/packages/"))
(package-initialize)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Use use-package to reduce load time
(eval-when-compile
  (require 'use-package))
(require 'diminish)                ;; if you use :diminish
(require 'bind-key)                ;; if you use any :bind variant

;; Requice common-lisp library
(require 'cl-lib)

;; Auto-revert mode
(global-auto-revert-mode 1)
(setq auto-revert-interval 0.5)

;; Backup stored in /tmp
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Delete old backup
(message "Deleting old backup files...")
(let ((week (* 60 60 24 7))
      (current (float-time (current-time))))
  (dolist (file (directory-files temporary-file-directory t))
    (when (and (backup-file-name-p file)
	       (> (- current (float-time (fifth (file-attributes file))))
		  week))
      (message "%s" file)
      (delete-file file))))

;; Startup
(add-hook 'after-init-hook 
	  (lambda () 
	    (find-file (format "%s/%s" config-directory "init.org"))))


;; Information settings
(setq user-full-name "Nguyễn Đức Hiếu"
      user-mail-address "hieunguyen31371@gmail.com")

;; Startup screen
(use-package dashboard
  :ensure t
  :init 
  (dashboard-setup-startup-hook)
  :config 
  (setq dashboard-startup-banner 'logo)
  )

;; Initialize Emacs full screen 
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(global-set-key (kbd "<f11>") 'toggle-frame-maximized)

;; No startup messages on *scratch* buffer
(setq initial-scratch-message "")

;; Cursor type
(setq-default cursor-type 'bar)

;; Global font-lock mode
(setq global-font-lock-mode t)


;; Enable line number and column number
(setq column-number-mode t)

;; Disable tool bar, menu bar, and scroll bar
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode 1)

;; Paren mode
(show-paren-mode t)
(setq show-paren-delay 0)

;; Default font
(use-package unicode-fonts
  :ensure t
  :init
  (unicode-fonts-setup)
  :config
  (set-frame-font "DejaVu Sans Mono 10" nil t))
;; Set themes
(use-package gruvbox-theme
  :ensure t
  :init
  (load-theme 'gruvbox t)
  :config
  (set-face-attribute 'font-lock-comment-face nil :foreground "#27ae60")
  (set-face-attribute 'mode-line nil :background "#427b58" :foreground "#ffffff")
  )

;; Ignore disabled command
(setq disabled-command-function 'ignore)

;; I never want to enter overwrite mode
(put 'overwrite-mode 'disabled t)

;; Delete marked region when input
(delete-selection-mode 1)

;; Global mark ring
(setq global-mark-ring-max 50000)

;; "Yes or no"? Too much writing
(defalias 'yes-or-no-p 'y-or-n-p)

;; Make comint promts read-only
(setq comint-prompt-read-only t)

;; Auto close bracket insertion.
(electric-pair-mode 1)
(setq electric-pair-pairs '(
			    (?\" . ?\")
			    (?\( . ?\))
			    (?\{ . ?\})
			    ) )

(when (fboundp 'electric-indent-mode) (electric-indent-mode -1))

;; Set kill ring size
(setq global-mark-ring-max 50000)

;; Bound undo to C-z
(global-set-key (kbd "C-z") 'undo)

;; Comment Do-What-I-Mean
(defun comment-dwim-mod ()	       	
  "Like `comment-dwim', but toggle comment if cursor is not at end of line.
URL `http://ergoemacs.org/emacs/emacs_toggle_comment_by_line.html'
Version 2016-10-25"
  (interactive)
  (if (region-active-p)
    (comment-dwim nil)
    (let ((-lbp (line-beginning-position))
  	  (-lep (line-end-position)))
      (if (eq -lbp -lep)
  	  (progn
  	    (comment-dwim nil))
  	(if (eq (point) -lep)
  	    (progn
  	      (comment-dwim nil))
  	  (progn
  	    (comment-or-uncomment-region -lbp -lep)
  	    (forward-line )))))))

(global-set-key (kbd "M-;") 'comment-dwim-mod) 

;; Bind comment-line to C-;
(global-set-key (kbd "C-;") 'comment-line)

;; Set comment style
(setq comment-style "plain")

;; Expand region with C-' and return to original position with C-g
(use-package expand-region
  :ensure t
  :init
  (defadvice keyboard-quit (before collapse-region activate)
    (when (memq last-command '(er/expand-region er/contract-region))
      (er/contract-region 0)))
  :bind 
  ("C-'" . er/expand-region)
  )

;; Multi-cursor
(use-package multiple-cursors
  :ensure t
  :init
  ;; In case commands behavior is messy with multiple-cursors,
  ;; check your ~/.emacs.d/.mc-lists.el
  (defun mc/check-command-behavior ()
    "Open ~/.emacs.d/.mc-lists.el. 
So you can fix the list for run-once and run-for-all multiple-cursors commands."
    (interactive)
    (find-file "~/.emacs.d/.mc-lists.el"))  
  :bind
  ("C-?" . mc/edit-lines)
  ("C->" . mc/mark-next-like-this)
  ("C-<" . mc/mark-previous-like-this)
  ("C-N" . mc/insert-numbers)
  )




;; Define function: fill character to 80
(defun fill-to-end (char)
  (interactive "HcFill Character:")
  (save-excursion
    (end-of-line)
    (while (< (current-column) 80)
      (insert-char char))))

;; Eval and replace lisp expression
(defun fc-eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (prin1 (eval (read (current-kill 0)))
	 (current-buffer)))
(global-set-key (kbd "C-c e") 'fc-eval-and-replace)

;; Move line/region up/down
(defun move-text-internal (arg)
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

(defun move-text-down (arg)
  "Move region (transient-mark-mode active) or current line
arg lines down."
  (interactive "*p")
  (move-text-internal arg))

(defun move-text-up (arg)
  "Move region (transient-mark-mode active) or current line
arg lines up."
  (interactive "*p")
  (move-text-internal (- arg)))

(global-set-key [\M-up] 'move-text-up)
(global-set-key [\M-down] 'move-text-down)

;; Srink whitespace, simple but useful
(use-package shrink-whitespace
  :ensure t
  :bind
  ("C-SPC" . shrink-whitespace)
  )

(use-package company
  :ensure t
  :init
  ;; Activate globally
  (add-hook 'after-init-hook 'global-company-mode)

  ;; Press <F1> to show the documentation buffer and press C-<F1> to jump to it
  (defun my/company-show-doc-buffer ()
    "Temporarily show the documentation buffer for the selection."
    (interactive)
    (let* ((selected (nth company-selection company-candidates))
	   (doc-buffer (or (company-call-backend 'doc-buffer selected)
			   (error "No documentation available"))))
      (with-current-buffer doc-buffer
	(goto-char (point-min)))
      (display-buffer doc-buffer t)))  

  :config
  ;; Some useful configs
  (setq company-selection-wrap-around t
  	company-tooltip-align-annotations t
  	company-idle-delay 0.36
  	company-minimum-prefix-length 2
  	company-tooltip-limit 10)
  ;; Make scroll bar more visible
  (set-face-attribute 'company-scrollbar-bg nil :background "tan")
  (set-face-attribute 'company-scrollbar-fg nil :background "darkred")
  (set-face-attribute 'company-tooltip nil :background "#f9f5d7" :foreground "#1d2021")
  (set-face-attribute 'company-tooltip-selection nil 
		      :background "#b57614" :foreground "#1d2021" :weight 'bold)
  (set-face-attribute 'company-tooltip-common nil :foreground "#458588" :weight 'bold :underline nil)
  (set-face-attribute 'company-tooltip-common-selection nil :foreground "#f9f5d7" 
		      :weight 'bold :underline nil)
  (set-face-attribute 'company-preview-common nil
		      :foreground "#1d2021" :background "#f9f5d7" :weight 'bold)
  :bind 
  (:map company-active-map
	("C-<f1>" . my/company-show-doc-buffer)
	)
  )

;; math backend, this will input math symbols everywhere except in 
;; LaTeX math evironments
(use-package company-math
  :ensure t
  :config
  (add-to-list 'company-backends 'company-math-symbols-unicode)
  )


;; Quick help show up in a popup
;; (company-quickhelp-mode 1)
;; (setq company-quickhelp-delay nil)(set-face-attribute 'company-tooltip-annotation nil :foreground "#504945")
;; (setq company-quickhelp-color-background "#f9f5d7")
;; (setq company-quickhelp-color-foreground "#1d2021")

;; (eval-after-load 'company
;; '(define-key company-active-map (kbd "C-c h") #'company-quickhelp-manual-begin))

;; Enable Yasnippets
(use-package yasnippet
  :ensure t
  :init
  ;; It will test whether it can expand, if yes, cursor color -> green.
  (defun yasnippet-can-fire-p (&optional field)
    (interactive)
    (setq yas--condition-cache-timestamp (current-time))
    (let (templates-and-pos)
      (unless (and yas-expand-only-for-last-commands
		   (not (member last-command yas-expand-only-for-last-commands)))
	(setq templates-and-pos (if field
				    (save-restriction
				      (narrow-to-region (yas--field-start field)
							(yas--field-end field))
				      (yas--templates-for-key-at-point))
				  (yas--templates-for-key-at-point))))

      (set-cursor-color (if (and templates-and-pos (first templates-and-pos)) 
			    "green" "#ffffaf"))))
  (add-hook 'post-command-hook 'yasnippet-can-fire-p)  

  (yas-global-mode 1)

  (yas-reload-all)
  :config
  (setq yas-snippet-dirs (format "%s/%s" config-directory "Snippets"))
  :bind
  ("<C-tab>" . yas-insert-snippet)
  )

;; With backquote warnings:
;; (add-to-list 'warning-suppress-types '(yasnippet backquote-change))

(use-package key-chord
  :ensure t
  :init
  (key-chord-define-global "??" 'mc/mark-all-like-this)
  (key-chord-mode +1)
  )

(use-package helm
  :ensure t
  :init
  (helm-mode 1)
  :config
  (require 'helm-config)
  (global-unset-key (kbd "C-x c"))


  (setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
	helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source	.	
	helm-ff-(save-excursion )arch-library-in-sexp        t ; search for library in `require' and `declare-function' sexp		.	
	helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
	helm-ff-file-name-history-use-recentf t
	helm-echo-input-in-header-line t 
	helm-M-x-fuzzy-match t
	helm-autoresize-max-height 0
	helm-autoresize-min-height 30)

  (helm-autoresize-mode 1)

  :bind-keymap
  ;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
  ;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
  ;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
  ("C-c h" . helm-command-prefix)  
  :bind (
 	 ("C-x b" . helm-buffers-list)
 	 ("M-x" . helm-M-x)
 	 ("C-x C-f" . helm-find-files)
 	 ("M-y" . helm-show-kill-ring)
 	 :map helm-map
 	 ("<tab>" . helm-execute-persistent-action) ; rebind tab to run persistent action
 	 ("C-i" . helm-execute-persistent-action)   ; make TAB work in terminal
 	 ("C-z" . helm-select-action)              ; list actions using C-z    
 	 )
  )


;; Use "C-:" to switch to Helm interface during company-ing
(use-package helm-company
  :ensure t
  :config
  (eval-after-load 'company
    '(progn
       (define-key company-mode-map (kbd "C-:") 'helm-company)
       (define-key company-active-map (kbd "C-:") 'helm-company)))    
  )

(use-package ag
  :ensure t
  :init
  ;; Truncate long results
  (add-hook 'ag-mode-hook (lambda () (setq truncate-lines t)))

  :config
  ;; Add highlighting
  (setq ag-highlight-search t)
  (set-face-attribute 'ag-match-face nil 
		      :weight 'bold
		      :foreground "#fabd2f")

  ;; Set ag to reuse the same buffer
  (setq ag-reuse-buffers 't)
  )

(use-package polymode
  :ensure t
  :init 
  (require 'poly-R)
  (require 'poly-markdown)
  (require 'poly-org)

  (add-to-list 'auto-mode-alist '("\\.org" . poly-org-mode))
  (add-to-list 'auto-mode-alist '("\\.md" . poly-markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.Snw$" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rnw$" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rmd$" . poly-markdown+r-mode))
  (add-to-list 'auto-mode-alist '("\\.rapport$" . poly-rapport-mode))
  (add-to-list 'auto-mode-alist '("\\.Rhtml$" . poly-html+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rbrew$" . poly-brew+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rcpp$" . poly-r+c++-mode))
  (add-to-list 'auto-mode-alist '("\\.cppR$" . poly-c++r-mode))
  )

(defun check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
	(backward-char 1)
	(if (looking-at "->") t nil)))))

(defun do-yas-expand ()
  (let ((yas/fallback-behavior 'return-nil))
    (yas/expand)))

(defun tab-indent-or-complete ()
  (interactive)
  (cond
   ((minibufferp)
    (minibuffer-complete))
   (t
    (indent-for-tab-command)
    (if (or (not yas/minor-mode)
	    (null (do-yas-expand)))
	(if (check-expansion)
	    (progn
	      (company-manual-begin)
	      (if (null company-candidates)
		  (progn
		    (company-abort)
		    (indent-for-tab-command)))))))))

(defun tab-complete-or-next-field ()
  (interactive)
  (if (or (not yas/minor-mode)
	  (null (do-yas-expand)))
      (if company-candidates
	  (company-complete-selection)
	(if (check-expansion)
	    (progn
	      (company-manual-begin)
	      (if (null company-candidates)
		  (progn
		    (company-abort)
		    (yas-next-field))))
	  (yas-next-field)))))

(defun expand-snippet-or-complete-selection ()
  (interactive)
  (if (or (not yas/minor-mode)
	  (null (do-yas-expand))
	  (company-abort))
      (company-complete-selection)))

(defun abort-company-or-yas ()
  (interactive)
  (if (null company-candidates)
      (yas-abort-snippet)
    (company-abort)))

(global-set-key [tab] 'tab-indent-or-complete)
(global-set-key (kbd "TAB") 'tab-indent-or-complete)
(global-set-key [(control return)] 'company-complete-common)

(define-key company-active-map [tab] 'expand-snippet-or-complete-selection)
(define-key company-active-map (kbd "TAB") 'expand-snippet-or-complete-selection)

(define-key yas-minor-mode-map [tab] nil)
(define-key yas-minor-mode-map (kbd "TAB") nil)

(define-key yas-keymap [tab] 'tab-complete-or-next-field)
(define-key yas-keymap (kbd "TAB") 'tab-complete-or-next-field)
(define-key yas-keymap [(control tab)] 'yas-next-field)
(define-key yas-keymap (kbd "C-g") 'abort-company-or-yas)

(use-package focus
  :ensure t
  :bind ("<f4>" . focus-mode))

;; Word-wrap
(add-hook 'org-mode-hook (lambda () (visual-line-mode 1)))

;; Omit the headline-asterisks except the last one:
(setq org-hide-leading-stars t)

;; Auto indent normally
(setq org-src-tab-acts-natively t)

;; Enable shift selection
(setq org-support-shift-select t)

;; Org keyword
(setq org-todo-keywords
    '((sequence "TODO" "DONE" "CANCELED")))
;; Fontification
(setq org-src-fontify-natively t)
(set-face-attribute 'org-level-1 nil :weight 'bold :height 120)
(set-face-attribute 'org-level-2 nil :weight 'bold)
(set-face-attribute 'org-block nil :foreground "#ffffff")  
(set-face-attribute 'org-block-begin-line nil :foreground "#d5c4a1")
(set-face-attribute 'org-block-end-line nil :foreground "#d5c4a1")

;; Org agenda folders
(setq org-agenda-files '("/home/hieu/Dropbox/org"))

;; Set monday as the start of the week
(setq org-agenda-start-on-weekday 1)

;; Active Babel languages:
(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)
   (emacs-lisp . t)
   (gnuplot . t)
   (plantuml . t)
   ))


;; Show inline images
(setq org-startup-with-inline-images t)

(use-package pdf-tools
  :ensure t
  :init 
  (pdf-tools-install)
  :config
  (setq pdf-view-display-size "fit-page"
	auto-revert-interval 0
	ess-pdf-viewer-pref "emacsclient"
	TeX-view-program-selection '((output-pdf "PDF Tools"))
	pdf-view-midnight-colors '("#fffff8" . "#111111"))
  )

(use-package magit
  :ensure t
  :bind
  ;; Set magit-status to F9
  ("<f9>" . magit-status)
  )

  ;; Currently magit cause some error when auto revert mode is on
  (setq magit-auto-revert-mode nil)

(use-package ess
  :ensure t
  :config
  (require 'ess-site)
  (require 'ess-rutils)
  (require 'ess-eldoc)  
  )

;; Truncate long lines
(add-hook 'special-mode-hook (lambda () (setq truncate-lines t)))
(add-hook 'inferior-ess-mode-hook (lambda () (setq truncate-lines t)))


;; Indentation style
(setq ess-default-style 'RStudio)

;; Disable syntax highlight in inferior buffer
(add-hook 'inferior-ess-mode-hook (lambda () (font-lock-mode 0)) t)

;; Right now read-only comints cause some errors
(add-hook 'inferior-ess-mode-hook (lambda () (setq-local comint-prompt-read-only nil)))

;; ESS syntax highlight  
(setq ess-R-font-lock-keywords 
      '((ess-R-fl-keyword:modifiers . t)
	(ess-R-fl-keyword:fun-defs . t)
	(ess-R-fl-keyword:keywords . t)
	(ess-R-fl-keyword:assign-ops . t)
	(ess-R-fl-keyword:constants . t)
	(ess-fl-keyword:fun-calls . t)
	(ess-fl-keyword:numbers . t)
	(ess-fl-keyword:operators . t)
	(ess-fl-keyword:delimiters . t)
	(ess-fl-keyword:= . t)
	(ess-R-fl-keyword:F&T . t)
	(ess-R-fl-keyword:%op% . t)
	)
      )

(setq ess-use-company 'script-only)
(setq ess-tab-complete-in-script t)	;; Press <tab> inside functions for completions

;; Describe object
;; (setq ess-R-describe-object-at-point-commands
;; 	'(("str(%s)")
;; 	  ("print(%s)")
;; 	  ("summary(%s, maxsum = 20)")))


;; Returm C-c h as prefix to Helm"
(defun ess-map-control-h-to-helm ()
  "Return C-c h to helm prefix instead of ess-handy-commands"
  (interactive)
  (local-unset-key (kbd "C-c h"))
  (local-set-key (kbd "C-c h") 'helm-command-prefix))

(add-hook 'ess-mode-hook 'ess-map-control-h-to-helm)

;; Remap "<-" key to M-- instead of smart bind to "_"
(ess-toggle-underscore nil)
(define-key ess-mode-map (kbd "M--") 'ess-smart-S-assign)
(define-key inferior-ess-mode-map (kbd "M--") 'ess-smart-S-assign)

;; Hot key C-S-m for pipe operator in ESS
;; Temporary removed and use Yasnippet instead
(defun then_R_operator ()
  "R - %>% operator or 'then' pipe operator"
  (interactive)
  (just-one-space 1)
  (insert "%>%")
  (just-one-space 1))

(define-key ess-mode-map (kbd "C-S-m") 'then_R_operator)
(define-key inferior-ess-mode-map (kbd "C-S-m") 'then_R_operator)



(defun ess-rmarkdown ()
  "Compile R markdown (.Rmd). Should work for any output type."
  (interactive)
  ;; Check if attached R-session
  (condition-case nil
      (ess-get-process)
    (error
     (ess-switch-process)))
  (let* ((rmd-buf (current-buffer)))
    (save-excursion
      (let* ((sprocess (ess-get-process ess-current-process-name))
	     (sbuffer (process-buffer sprocess))
	     (buf-coding (symbol-name buffer-file-coding-system))
	     (R-cmd
	      (format "library(rmarkdown); rmarkdown::render(\"%s\")"
		      buffer-file-name)))
	(message "Running rmarkdown on %s" buffer-file-name)
	(ess-execute R-cmd 'buffer nil nil)
	(switch-to-buffer rmd-buf)
	(ess-show-buffer (buffer-name sbuffer) nil)))))

(define-key polymode-mode-map "\M-ns" 'ess-rmarkdown)

(defun ess-rshiny ()
  "Compile R markdown (.Rmd). Should work for any output type."
  (interactive)
  ;; Check if attached R-session
  (condition-case nil
      (ess-get-process)
    (error
     (ess-switch-process)))
  (let* ((rmd-buf (current-buffer)))
    (save-excursion
      (let* ((sprocess (ess-get-process ess-current-process-name))
	     (sbuffer (process-buffer sprocess))
	     (buf-coding (symbol-name buffer-file-coding-system))
	     (R-cmd
	      (format "library(rmarkdown);rmarkdown::run(\"%s\")"
		      buffer-file-name)))
	(message "Running shiny on %s" buffer-file-name)
	(ess-execute R-cmd 'buffer nil nil)
	(switch-to-buffer rmd-buf)
	(ess-show-buffer (buffer-name sbuffer) nil)))))

(define-key polymode-mode-map "\M-nr" 'ess-rshiny)

(use-package elpy
  :ensure t
  :init
  ;; Enable company
  (add-hook 'python-mode-hook 'company-mode)
  (add-hook 'inferior-python-mode-hook 'company-mode)

  ;; Enable elpy
  (elpy-enable)
  :config
  ;; Do not enable elpy snippets for now
  (delete 'elpy-module-yasnippet elpy-modules)

  (flymake-mode -1)
  (elpy-use-cpython "python3")
  (setq elpy-rpc-python-command "python3")
  (setq elpy-rpc-backend "jedi")

  :bind(
	:map python-mode-map
	     ("C-c C-c" . elpy-shell-send-current-statement)
	     ("C-c <RET>" . elpy-shell-send-region-or-buffer)
	     )
  )	       

;; Fix:Calling ‘run-python’ with ‘python-shell-interpreter’ set to "python3"
;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=24401
;; This will be fixed in the next version of Emacs
(defun python-shell-completion-native-try ()
  "Return non-nil if can trigger native completion."
  (let ((python-shell-completion-native-enable t)
	(python-shell-completion-native-output-timeout
	 python-shell-completion-native-try-output-timeout))
    (python-shell-completion-native-get-completions
     (get-buffer-process (current-buffer))
     nil "_")))

(use-package tex 
  :ensure auctex)

;; Appearance
(require 'font-latex)

;; Preview-latex
;; (set-default 'preview-scale-function 1.2)

;; Math mode
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
;; (set-face-attribute 'font-latex-math-face nil :foreground "#ffffff")

;; Enable query for master file
(setq-default TeX-master nil)		    
(setq TeX-auto-save t			    
      TeX-parse-self t
      TeX-save-query nil
      TeX-PDF-mode t	    
      font-latex-fontify-sectioning 'color
      font-latex-fontify-script nil)    

;; Word-wrap
 (add-hook 'TeX-mode-hook (lambda () (visual-line-mode 1)))


;; Completion
(use-package company-auctex
  :ensure t
  :init
  (company-auctex-init)
  )

(use-package shx
  :ensure t
  :init
  (add-hook 'shell-mode-hook #'shx-mode)
  )

;; Keybinding for terminal
(global-set-key [f2] 'shell)

;; Company
(use-package company-shell
  :ensure t
  :config
  (add-to-list 'company-backends '(company-shell company-shell-env company-fish-shell))
  )

(use-package gnuplot-mode
  :ensure t
  :config
  ;; automatically open files ending with .gp or .gnuplot in gnuplot mode
  (setq auto-mode-alist 
	(append '(("\\.\\(gp\\|gnuplot\\)$" . gnuplot-mode)) auto-mode-alist))    
  )

(use-package plantuml-mode
  :ensure t
  :config
  ;; Recognize plantuml files
  (add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))
  ;; Path to jar file, remember to put it in the right folder
  (setq plantuml-jar-path (expand-file-name "~/Java/plantuml.jar"))
  ;; Add to org-plantuml
  (setq org-plantuml-jar-path (expand-file-name "~/Java/plantuml.jar"))
  )

(use-package helpful
  :ensure t)

(use-package evil
  :ensure t
  :init
  :config
  (evil-set-initial-state 'help-mode 'emacs)
  (evil-set-initial-state 'dashboard-mode 'emacs)
  (evil-set-initial-state 'org-mode 'emacs)
  (evil-mode 1))
