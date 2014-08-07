(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (wombat)))
 '(custom-safe-themes (quote ("4dacec7215677e4a258e4529fac06e0231f7cdd54e981d013d0d0ae0af63b0c8" default)))
 '(dired-omit-files "^\\.?#\\|^\\.$")
 '(fci-rule-color "#383838")
 '(flycheck-flake8-maximum-complexity 9)
 '(flycheck-highlighting-mode (quote lines))
 '(ibuffer-formats (quote ((mark modified read-only vc-status-mini " " (name 18 18 :left :elide) " " (size 9 -1 :right) " " (mode 16 16 :left :elide) " " filename-and-process) (mark " " (name 16 -1) " " filename))))
 '(inhibit-startup-screen t)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(vc-annotate-background "#2b2b2b")
 '(vc-annotate-color-map (quote ((20 . "#bc8383") (40 . "#cc9393") (60 . "#dfaf8f") (80 . "#d0bf8f") (100 . "#e0cf9f") (120 . "#f0dfaf") (140 . "#5f7f5f") (160 . "#7f9f7f") (180 . "#8fb28f") (200 . "#9fc59f") (220 . "#afd8af") (240 . "#bfebbf") (260 . "#93e0e3") (280 . "#6ca0a3") (300 . "#7cb8bb") (320 . "#8cd0d3") (340 . "#94bff3") (360 . "#dc8cc3"))))
 '(vc-annotate-very-old-color "#dc8cc3")
 '(web-mode-enable-current-element-highlight t))

(define-key global-map (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(autoload 'ibuffer "ibuffer" "List buffers." t)

(add-hook 'ibuffer-hook
	  (lambda ()
	    (ibuffer-vc-set-filter-groups-by-vc-root)
	    (unless (eq ibuffer-sorting-mode 'alphabetic)
	      (ibuffer-do-sort-by-alphabetic))))

;;(add-hook 'after-init-hook #'global-flycheck-mode)
(setq flycheck-flake8-maximum-complexity 9)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :weight light :height 140 :family "Source Code Pro"))))
 '(flycheck-error ((t (:underline "red4"))))
 '(flycheck-error-face ((t (:background "brown4"))))
 '(flycheck-fringe-error ((t nil)))
 '(flycheck-fringe-warning ((t nil)))
 '(flycheck-warning ((t (:underline "dark orange"))))
 '(flycheck-warning-face ((t (:background "chocolate4"))))
 '(flymake-errline ((((class color)) (:underline "red"))))
 '(flymake-warnline ((((class color)) (:underline "yellow")))))

(eval-after-load "flycheck"
  '(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

(require 'package)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
	;;("marmalade" . "http://marmalade-repo.org/packages/")
	("melpa" . "http://melpa.milkbox.net/packages/")))

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(mapc
 (lambda (package)
   (or (package-installed-p package)
       (package-install package)))
 '(exec-path-from-shell
   flycheck
   google-this
   autopair
   dash
   python-mode
   jedi
   diff-hl
   magit
   ibuffer-vc
;;   dart-mode
   s
   zenburn-theme
;;   less-css-mode
   python-django
   flycheck-color-mode-line
   virtualenv
   virtualenvwrapper
   elnode
;;   org-trello
   web-mode
   expand-region
   smartparens
   ))

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;;;; el-get packages
(setq my:el-get-packages
      '(python
	popup
	auto-complete
	fill-column-indicator
	fuzzy
	highlight-indentation
	pymacs
	rope
	ropemacs
	ropemode
	yaml-mode
;;	nxhtml
        epc
	ctable
	deferred
	helm
	popup
	smooth-scroll
	dired+
	))
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (let (el-get-master-branch)
      (goto-char (point-max))
      (eval-print-last-sexp))))
(el-get 'sync my:el-get-packages)

(defun find-parent-with-file (path filename)
  "Traverse PATH upwards until we find FILENAME in the dir.

If we find it return the path of that dir, othwise nil is
returned."
  (if (file-exists-p (concat path "/" filename))
      path
    (let ((parent-dir (file-name-directory (directory-file-name path))))
      ;; Make sure we do not go into infinite recursion
      (if (string-equal path parent-dir)
          nil
        (find-parent-with-file parent-dir filename)))))


(defun buildout-find-bin (exec)
  (let* ((buildout-directory
	  (find-parent-with-file default-directory "buildout.cfg"))
	 (bin-path (concat buildout-directory "bin/" exec)))
    (if (file-exists-p bin-path) bin-path exec)))

(add-hook 'python-mode-hook (lambda ()
                              (hack-local-variables)
                              (venv-workon project-venv-name)))
(defun check-jedi-python ()
  "Update the path to python for jedi-mode if we switch to a Buildout project."
  (let ((bin (buildout-find-bin "python")))
    (set (make-local-variable 'jedi:server-command)
	 (list bin jedi:server-script))))
(add-hook 'python-mode-hook 'check-jedi-python)

(setq jedi:setup-keys nil)
;; (setq jedi:tooltip-method nil)
(autoload 'jedi:setup "jedi" nil t)
(add-hook 'python-mode-hook 'jedi:setup)
(defvar jedi:goto-stack '())
(defun jedi:jump-to-definition ()
  (interactive)
  (add-to-list 'jedi:goto-stack
               (list (buffer-name) (point)))
  (jedi:goto-definition))
(defun jedi:jump-back ()
  (interactive)
  (let ((p (pop jedi:goto-stack)))
    (if p (progn
            (switch-to-buffer (nth 0 p))
            (goto-char (nth 1 p))))))
(add-hook 'python-mode-hook
          '(lambda ()
             (local-set-key (kbd "C-.") 'jedi:jump-to-definition)
             (local-set-key (kbd "C-,") 'jedi:jump-back)
             (local-set-key (kbd "C-c d") 'jedi:show-doc)
             (local-set-key (kbd "C-<tab>") 'jedi:complete)))


;;(load-theme 'zenburn t)

;; ido mode
(require 'ido)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

;;(set-default-font "Source Code Pro")
;;(set-face-font 'default "Source Code Pro")
;;(set-face-attribute 'default nil :font "Source Code Pro" :weight 'ExtraLight :height 140)

(require 'desktop)
(desktop-save-mode 1)
(defun my-desktop-save ()
    (interactive)
    ;; Don't call desktop-save-in-desktop-dir, as it prints a message.
    (if (eq (desktop-owner) (emacs-pid))
        (desktop-save desktop-dirname)))
(add-hook 'auto-save-hook 'my-desktop-save)

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(server-start)

;;(add-hook 'after-init-hook #'global-flycheck-mode)
(add-hook 'python-mode-hook 'flycheck-mode)

;;(autopair-global-mode t)

;;(require 'highlight-indentation)
;;(add-hook 'python-mode-hook 'highlight-indentation)

(setq skeleton-pair nil)

;; javascript
(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(setq ido-use-filename-at-point 'guess)

(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.sls$" . python-mode))

(add-hook 'python-mode-hook 'turn-on-diff-hl-mode)

(require 'magit)



(add-hook 'server-visit-hook 'call-raise-frame)
(defun call-raise-frame ()
  (raise-frame))

(add-hook 'python-mode-hook (lambda () (add-to-list 'write-file-functions 'delete-trailing-whitespace)))

(require 'google-this)
(google-this-mode 1)

(global-set-key (kbd "C-x g") 'google-this-mode-submap)

(require 'fill-column-indicator)
(setq-default fci-rule-column 80)
(setq-default fill-column 78)
(add-hook 'python-mode-hook 'fci-mode)
(add-hook 'emacs-lisp-mode-hook 'fci-mode)
;; (define-globalized-minor-mode
;;  global-fci-mode fci-mode (lambda () (fci-mode 1)))
;; (global-fci-mode t)

;; ipython
;;(setq-default py-shell-name "ipython")
;;(setq-default py-which-bufname "IPython")
; use the wx backend, for both mayavi and matplotlib
;;(setq py-python-command-args
;;  '("--gui=wx" "--pylab=wx" "-colors" "Linux"))
;;(setq py-force-py-shell-name-p t)

; switch to the interpreter after executing code
;;(setq py-shell-switch-buffers-on-execute-p t)
;;(setq py-switch-buffers-on-execute-p t)
; don't split windows
;;(setq py-split-windows-on-execute-p nil)
; try to automagically figure out indentation
;;(setq py-smart-indentation t)

(global-set-key (kbd "C-x C-b") 'ibuffer)
(autoload 'ibuffer "ibuffer" "List buffers." t)

(add-hook 'ibuffer-hook
	  (lambda ()
	    (ibuffer-vc-set-filter-groups-by-vc-root)
	    (unless (eq ibuffer-sorting-mode 'alphabetic)
	      (ibuffer-do-sort-by-alphabetic))))

(setq require-final-newline t)

(setq tramp-default-method "ssh")

(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)
(autoload 'pymacs-autoload "pymacs")
;;(pymacs-load "ropemacs" "rope-")
;;(setq ropemacs-enable-autoimport t)

(require 'auto-complete)
(global-auto-complete-mode t)

(add-hook 'python-mode-hook 'jedi:setup)

(require 'flycheck-color-mode-line)

(eval-after-load "flycheck"
  '(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

;; (eval-after-load "mumamo"
;;   '(setq mumamo-per-buffer-local-vars
;; 	 (delq 'buffer-file-name mumamo-per-buffer-local-vars)))

;;(set-frame-parameter (selected-frame) 'alpha '(<active> [<inactive>]))
 (set-frame-parameter (selected-frame) 'alpha '(96 90))
 (add-to-list 'default-frame-alist '(alpha 96 90))

(eval-when-compile (require 'cl))
 (defun toggle-transparency ()
   (interactive)
   (if (/=
        (cadr (frame-parameter nil 'alpha))
        100)
       (set-frame-parameter nil 'alpha '(100 100))
     (set-frame-parameter nil 'alpha '(96 90))))
 (global-set-key (kbd "C-c t") 'toggle-transparency)

(add-to-list 'load-path "~/.emacs.d/dart-mode/")
(require 'dart-mode)

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[gj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

(setq web-mode-engines-alist
      '(("django"    . "\\.html\\'")
        ("blade"  . "\\.blade\\."))
)
(setq web-mode-style-padding 0)
(setq web-mode-script-padding 0)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))

(require 'expand-region)
(global-set-key (kbd "C-/") 'er/expand-region)

(setq-default dired-omit-files-p t)

(require 'smartparens-config)
(add-hook 'python-mode-hook 'smartparens-mode)

(define-key sp-keymap (kbd "C-.") 'sp-up-sexp)
(define-key sp-keymap (kbd "C-M-f") 'sp-forward-slurp-sexp)
(define-key sp-keymap (kbd "C-M-b") 'sp-forward-barf-sexp)
(define-key sp-keymap (kbd "M-D") 'sp-splice-sexp)

(flycheck-define-checker python-pep8
  ""
  :command ("pep8"
            source)
  :error-patterns
  ((error line-start
          (file-name) ":" line ":" (optional column ":") " "
          (message "E" (one-or-more digit) (zero-or-more not-newline))
          line-end)
   (warning line-start
            (file-name) ":" line ":" (optional column ":") " "
            (message (or "F"            ; Pyflakes in Flake8 >= 2.0
                         "W"            ; Pyflakes in Flake8 < 2.0
                         "C")           ; McCabe in Flake >= 2.0
                     (one-or-more digit) (zero-or-more not-newline))
            line-end)
   (info line-start
         (file-name) ":" line ":" (optional column ":") " "
         (message "N"              ; pep8-naming in Flake8 >= 2.0
                  (one-or-more digit) (zero-or-more not-newline))
         line-end)
   ;; Syntax errors in Flake8 < 2.0, in Flake8 >= 2.0 syntax errors are caught
   ;; by the E.* pattern above
   (error line-start (file-name) ":" line ":" (message) line-end))
  :modes python-mode)

;;(flycheck-add-next-checker 'python-flake8 'python-pylint)
;;(flycheck-add-next-checker 'python-flake8 'python-pep8)
