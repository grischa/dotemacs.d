(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (wombat)))
 '(custom-safe-themes (quote ("4dacec7215677e4a258e4529fac06e0231f7cdd54e981d013d0d0ae0af63b0c8" default)))
 '(fci-rule-color "#383838")
 '(flycheck-flake8-maximum-complexity 8)
 '(flycheck-highlighting-mode (quote lines))
 '(inhibit-startup-screen t)
 '(nxhtml-autoload-web nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(vc-annotate-background "#2b2b2b")
 '(vc-annotate-color-map (quote ((20 . "#bc8383") (40 . "#cc9393") (60 . "#dfaf8f") (80 . "#d0bf8f") (100 . "#e0cf9f") (120 . "#f0dfaf") (140 . "#5f7f5f") (160 . "#7f9f7f") (180 . "#8fb28f") (200 . "#9fc59f") (220 . "#afd8af") (240 . "#bfebbf") (260 . "#93e0e3") (280 . "#6ca0a3") (300 . "#7cb8bb") (320 . "#8cd0d3") (340 . "#94bff3") (360 . "#dc8cc3"))))
 '(vc-annotate-very-old-color "#dc8cc3"))

(global-set-key (kbd "C-x C-b") 'ibuffer)
(autoload 'ibuffer "ibuffer" "List buffers." t)

(require 'package)
(setq package-archives 
      '(("gnu" . "http://elpa.gnu.org/packages/")
	("marmalade" . "http://marmalade-repo.org/packages/")
	("melpa" . "http://melpa.milkbox.net/packages/")))

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(mapc
 (lambda (package)
   (or (package-installed-p package)
       (package-install package)))
 '(flycheck
   google-this
   python-mode
   diff-hl
   magit
   ibuffer-vc
   dart-mode))
;; dash
;; autopair))
;; flymake-cursor
;; exec-path-from-shell
;; s
;; zenburn-theme)
;;;; el-get packages
(setq my:el-get-packages
      '(auto-complete
	fill-column-indicator
	fuzzy
	highlight-indentation
	jedi
	pymacs
	rope
	ropemacs
	ropemode
	yaml-mode
	nxhtml))
;; ctable
;; deferred
;; el-get
;; epc
;; flymake-cursor
;; package
;; popup
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


(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

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

(add-hook 'after-init-hook #'global-flycheck-mode)
(setq flycheck-flake8-maximum-complexity 7)

;;(autopair-global-mode t)

;;(add-to-list 'load-path "~/.emacs.d/")

;;(load-file "~/.emacs.d/emacs-for-python/epy-init.el")

;;(epy-setup-checker "~/.emacs.d/pycheckers %f")
;;(epy-django-snippets)
;;(epy-setup-ipython)

;;(require 'highlight-indentation)
;;(add-hook 'python-mode-hook 'highlight-indentation)

(setq skeleton-pair nil)

;; javascript
(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; nxhtml
(load "~/.emacs.d/nxhtml/autostart")

(setq ido-use-filename-at-point 'guess)

(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.sls$" . yaml-mode))

(load-file "~/.emacs.d/diff-hl.el")
(add-hook 'python-mode-hook 'turn-on-diff-hl-mode)

(require 'magit)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :weight light :height 140 :family "Source Code Pro"))))
 '(flycheck-error-face ((t (:background "brown4"))))
 '(flycheck-warning-face ((t (:background "chocolate4"))))
 '(flymake-errline ((((class color)) (:underline "red"))))
 '(flymake-warnline ((((class color)) (:underline "yellow")))))

(add-hook 'server-visit-hook 'call-raise-frame)
(defun call-raise-frame ()
  (raise-frame))

;; ;; flymake with buildout
;; ;; from https://bitbucket.org/runeh/dotfiles/src/e686525f6cca/dotemacs/dotemacs
;; ;; add epylint to buildout:
;; ;; http://stackoverflow.com/questions/10001205/epylint-in-emacs-using-virtualenv
;; (require 'flymake)
;; (load-library "flymake-cursor")
;; (setq flymake-start-syntax-check-on-newline nil)
;; (add-hook 'find-file-hook 'flymake-find-file-hook)
;; (global-set-key "\C-c\C-j"  'flymake-goto-next-error)
;; (global-set-key "\C-c\C-k"  'flymake-goto-prev-error)

;; ;; Look for buildout dir with epylint
;; (setq pyflymake-buildout-paths (list "bin/epylint"))

;; (defun pyflymake-find-buildout (filename)
;;   "Finds buildout dir"
;;   (if (string= filename "/")
;;       "epylint"
;;     (let (buildout)
;;       (dolist (path pyflymake-buildout-paths)
;;         (if (file-exists-p (concat filename path))
;;             (setq buildout (concat filename path))))
;;       (message buildout)
;;       (or buildout
;;           (pyflymake-find-buildout (file-name-directory
;;                                     (directory-file-name filename)))))))

;; (defun flymake-pylint-init ()
;;   (if (not (file-writable-p (file-name-directory buffer-file-name)))
;;       nil
;;     (list (pyflymake-find-buildout buffer-file-name)
;;           (list (file-relative-name
;;                  (flymake-init-create-temp-buffer-copy 'flymake-create-temp-inplace)
;;                  (file-name-directory buffer-file-name))))))


;; (add-to-list 'flymake-allowed-file-name-masks
;;              '("\\.py\\'" flymake-pylint-init))

(add-hook 'python-mode-hook (lambda () (add-to-list 'write-file-functions 'delete-trailing-whitespace)))

(require 'google-this)
(google-this-mode 1)

(global-set-key (kbd "C-x g") 'google-this-mode-submap)

(require 'fill-column-indicator)
(define-globalized-minor-mode
 global-fci-mode fci-mode (lambda () (fci-mode 1)))
(setq-default fci-rule-column 79)
(global-fci-mode t)
(setq-default fill-column 78)

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

(add-to-list 'load-path "~/.emacs.d/")

(require 'flycheck-color-mode-line)

(eval-after-load "flycheck"
  '(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

(eval-after-load "mumamo"
  '(setq mumamo-per-buffer-local-vars
	 (delq 'buffer-file-name mumamo-per-buffer-local-vars)))
