(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("elpy" . "https://jorgenschaefer.github.io/packages/"))
(package-initialize)

;; Requice common-lisp library
(require 'cl-lib)
(require 'bind-key)

;; Initialize Emacs full screen 
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; No startup messages on *scratch* buffer
(setq initial-scratch-message "")

;; Cursor type
(setq-default cursor-type 'bar)


;; Default font
(require 'unicode-fonts)
(unicode-fonts-setup)
(set-frame-font "DejaVu Sans Mono 10" nil t)


;; Set themes
(load-theme 'gruvbox t)
(set-face-attribute 'font-lock-comment-face nil :foreground "#27ae60")
(set-face-attribute 'default nil :foreground "#ffffff")
(set-face-attribute 'mode-line nil :background "#2f4f4f" :foreground "#ffffff")

;; Set background face for color string
(add-hook 'prog-mode-hook 'rainbow-mode)


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

;; Delete marked region when input
(delete-selection-mode 1)

;; Global mark ring
(setq global-mark-ring-max 50000)

;; "Yes or no"? Too much writing
(defalias 'yes-or-no-p 'y-or-n-p)


;; Auto close bracket insertion.
(electric-pair-mode 1)
(setq electric-pair-pairs '(
			    (?\" . ?\")
			    (?\( . ?\))
			    (?\{ . ?\})
			    ) )

(when (fboundp 'electric-indent-mode) (electric-indent-mode -1))

;; Add new line at the bottom of buffer
(setq next-line-add-newlines t)

;; Set kill ring size
(setq global-mark-ring-max 50000)

;; Bound undo to C-z
(global-set-key (kbd "C-z") 'undo)

;; Expand region with C-' and return to original position with C-g
(require 'expand-region)
(global-set-key (kbd "C-'") 'er/expand-region)

(defadvice keyboard-quit (before collapse-region activate)
  (when (memq last-command '(er/expand-region er/contract-region))
    (er/contract-region 0)))


;; Multi-cursor
(require 'multiple-cursors)
(global-set-key (kbd "C-?") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-N") 'mc/insert-numbers)

;; Define function: fill character to 80
(defun fill-to-end (char)
  (interactive "cFill Character:")
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
(require 'shrink-whitespace)
(global-set-key (kbd "C-SPC") 'shrink-whitespace)

;; Code completion
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)

(setq company-selection-wrap-around t
      company-tooltip-align-annotations t
      company-idle-delay 0.36
      company-minimum-prefix-length 2
      company-tooltip-limit 10)

;; Quick help show up in a popup
(company-quickhelp-mode 1)
(setq company-quickhelp-delay 1)

;; Math backend, this will input math symbols everywhere except in 
;; LaTeX math evironments
(require 'company-math)
(add-to-list 'company-backends 'company-math-symbols-unicode)

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

;; Enable Yasnippets
(require 'yasnippet)
(setq yas-snippet-dirs (format "%s/%s" config-directory "Snippets"))

(yas-global-mode 1)

(global-set-key (kbd "<C-tab>") 'yas-insert-snippet)


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
			  "green" "white"))))
(add-hook 'post-command-hook 'yasnippet-can-fire-p)

(yas-reload-all)
;; With backquote warnings:
;; (add-to-list 'warning-suppress-types '(yasnippet backquote-change))

(require 'key-chord)
(key-chord-define-global "??" 'mc/mark-all-like-this)
(key-chord-mode +1)

(require 'helm)
(require 'helm-config)

;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(bind-key* (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)   ; make TAB work in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action)              ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq 
 helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
 helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
 helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
 helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
 helm-ff-file-name-history-use-recentf t
 helm-echo-input-in-header-line        t)


(setq helm-autoresize-max-height 0)
(setq helm-autoresize-min-height 30)
(helm-autoresize-mode 1)

(helm-mode 1)

;; Use helm for some common task
(global-set-key (kbd "C-x b") 'helm-buffers-list)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(setq helm-M-x-fuzzy-match t)


;; Use "C-:" to switch to Helm interface during companying
(require 'helm-company)
(eval-after-load 'company
  '(progn
     (define-key company-mode-map (kbd "C-:") 'helm-company)
     (define-key company-active-map (kbd "C-:") 'helm-company)))

(require 'polymode)
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

;; Auto indent normally
(setq org-src-tab-acts-natively t)

;; Enable shift selection
(setq org-support-shift-select t)


;; fontify code in code blocks
(setq org-src-fontify-natively t)
(set-face-attribute 'org-block nil :foreground "#ffffff")

(set-face-attribute 'org-block-begin-line nil :foreground "#d5c4a1")
(set-face-attribute 'org-block-end-line nil :foreground "#d5c4a1")

(require 'ess-site)
(require 'ess-rutils)


;; Describe object
;; (setq ess-R-describe-object-at-point-commands
;; 	'(("str(%s)")
;; 	  ("print(%s)")
;; 	  ("summary(%s, maxsum = 20)")))

;; Truncate long lines
(add-hook 'special-mode-hook (lambda () (setq truncate-lines t)))
(add-hook 'inferior-ess-mode-hook (lambda () (setq truncate-lines t)))


;; Indentation style
(setq ess-default-style 'RStudio)

;; Disable syntax highlight in inferior buffer
(add-hook 'inferior-ess-mode-hook (lambda () (font-lock-mode 0)) t)

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

;; Eldoc mode for function arguments hints
(require 'ess-eldoc)  

(setq ess-use-company 'script-only)
(setq ess-tab-complete-in-script t)	;; Press <tab> inside functions for completions

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
;; (defun then_R_operator ()
;;   "R - %>% operator or 'then' pipe operator"
;;   (interactive)
;;   (just-one-space 1)
;;   (insert "%>%")
;;   (just-one-space 1))
;; (define-key ess-mode-map (kbd "C-S-m") 'then_R_operator)
;; (define-key inferior-ess-mode-map (kbd "C-S-m") 'then_R_operator)



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

(elpy-enable)				
(with-eval-after-load 'elpy (flymake-mode -1))
(setq elpy-rpc-python-command "python3")
(elpy-use-cpython "python3")
(setq elpy-rpc-backend "jedi")


;; Enable company
(add-hook 'python-mode-hook 'company-mode)
(add-hook 'inferior-python-mode-hook 'company-mode)

;; Keybinding
(define-key python-mode-map (kbd "C-c C-c") 'elpy-shell-send-current-statement)
(define-key python-mode-map (kbd "C-c <RET>") 'elpy-shell-send-region-or-buffer)

;; Ill put flycheck configurations here temporary
;; (with-eval-after-load 'flycheck
;; (flycheck-pos-tip-mode))

;; (defun flymake-to-flycheck ()
;;    "Change from flymake to flycheck when flymake is on."
;;    (interactive)
;;    (flymake-mode-off)
;;    (flycheck-mode 1))

;; (add-hook 'python-mode-hook 'flymake-to-flycheck)


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

;; (require 'ein)
;; (require 'ein-loaddefs)
;; (require 'ein-notebook)
;; (require 'ein-subpackages)

(load "auctex.el" nil t t)

;; Appearance
(require 'font-latex)

;; Math mode
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
(set-face-attribute 'font-latex-math-face nil :foreground "#ffffff")

;; Enable query for master file
(setq-default TeX-master nil)		    
(setq TeX-auto-save t			    
      TeX-parse-self t
      TeX-save-query nil
      TeX-PDF-mode t	    
      font-latex-fontify-sectioning 'color
      font-latex-fontify-script nil)    

;; Word-wrap
(add-hook 'TeX-mode-hook (lambda () (setq word-wrap t)))

;; Completion
(require 'company-auctex)
(company-auctex-init)

(require 'shx)
(add-hook 'shell-mode-hook #'shx-mode)

;; Make comint promts read-only
(add-hook 'shx-mode-hook (lambda () (setq comint-prompt-read-only t)))

;; Keybinding for terminal
(global-set-key [f2] 'shell)

;; Company
(add-to-list 'company-backends '(company-shell company-shell-env company-fish-shell))

(require 'gnuplot-mode)
;; automatically open files ending with .gp or .gnuplot in gnuplot mode
(setq auto-mode-alist 
      (append '(("\\.\\(gp\\|gnuplot\\)$" . gnuplot-mode)) auto-mode-alist))

;; Rainbow mode
(add-hook 'html-mode-hook 'rainbow-mode)
(add-hook 'css-mode-hook 'rainbow-mode)

(pdf-tools-install)
(setq pdf-view-display-size "fit-page"
      auto-revert-interval 0
      ess-pdf-viewer-pref "emacsclient"
      TeX-view-program-selection '((output-pdf "PDF Tools"))
      pdf-view-midnight-colors '("#fffff8" . "#111111"))

;; Currently magit cause some error when auto revert mode is on
(setq magit-auto-revert-mode nil)
