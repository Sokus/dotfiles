
;;================================== LIBRARIES ===================================

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(load-library "view")
(require 'cc-mode) ; c/c++ editing
(require 'compile)

(require 'ido)
(ido-mode t)
(setq ido-everywhere t)
(setq ido-enable-flex-matching t)
(setq ido-auto-merge-work-directories-length -1)

(eval-when-compile
  (require 'use-package))

;;(use-package flycheck)

(use-package lsp-mode
  :hook
  ((c++-mode c-mode rust-mode go-mode csharp-mode python-mode cmake-mode) . lsp)
  :custom
  (lsp-diagnostic-package :flycheck)
  (lsp-prefer-capf t)
  (read-process-output-max (* 1024 1024)))

(use-package lsp-ui
  :custom
  (lsp-ui-doc-max-width 80)
  (lsp-ui-doc-position 'top))

;;(use-package lsp-treemacs)
;;(use-package dap-mode
;;  :init
;;  (require 'dap-gdb-lldb)
;;  (require 'dap-go)
;;  ;;download debuggers, REQUIRES unzip
;;  (when (not (file-exists-p (expand-file-name ".extension" user-emacs-directory)))
;;    (dap-gdb-lldb-setup t)
;;    (dap-go-setup t)))

(c-set-offset 'substatement-open 0)
(c-set-offset 'innamespace 0)
(c-set-offset 'brace-list-open 0)
(setq c-basic-offset 4)

(setq lsp-clients-clangd-args
      '("-j=8"
	"--header-insertion=never"
	"--all-scopes-completion"
	"--background-index"
	"--clang-tidy"
	"--compile-commands-dir=build"
	"--cross-file-rename"
	"--suggest-missing-includes"))

(use-package modern-cpp-font-lock
  :config
  (modern-c++-font-lock-global-mode))

(use-package cmake-mode)

;;=============================== GENERAL SETTINGS ===============================

(global-hl-line-mode 1)
(scroll-bar-mode -1)
(tool-bar-mode 0)
(menu-bar-mode -1)
(display-time)
(setq display-time-24hr-format t)
(setq frame-title-format '(buffer-file-name "Emacs: %b (%f)" "Emacs: %b"))
(setq inhibit-startup-screen t) 
(setq mouse-wheel-scroll-amount '(4 ((shift) . 4) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)
(setq scroll-step 5)
(setq shift-select-mode nil)
(setq enable-local-variables nil)
(setq backup-inhibited t) ;disable backup
(setq auto-save-default nil) ;disable auto save
(setq next-line-add-newlines nil)
(setq-default truncate-lines t)
(setq truncate-partial-width-windows nil)
(setq initial-scratch-message "")
(setq undo-limit 20000000)
(setq undo-strong-limit 40000000)
;;(setq next-line-add-newlines nil)

;;================================= COLOR THEME ==================================

(load-theme 'gruvbox-dark-medium t)

(setq fixme-modes '(c++-mode c-mode emacs-lisp-mode))
(make-face 'font-lock-fixme-face)
(make-face 'font-lock-study-face)
(make-face 'font-lock-important-face)
(make-face 'font-lock-note-face)
(mapc (lambda (mode)
        (font-lock-add-keywords
         mode
         '(("\\<\\(TODO\\)" 1 'font-lock-fixme-face t)
           ("\\<\\(STUDY\\)" 1 'font-lock-study-face t)
           ("\\<\\(IMPORTANT\\)" 1 'font-lock-important-face t)
           ("\\<\\(NOTE\\)" 1 'font-lock-note-face t))))
      fixme-modes)
(modify-face 'font-lock-fixme-face "#fb4933" nil nil t nil t nil nil)
(modify-face 'font-lock-study-face "#fabd2f" nil nil t nil t nil nil)
(modify-face 'font-lock-important-face "#fe8019" nil nil t nil t nil nil)
(modify-face 'font-lock-note-face "#b8bb26" nil nil t nil t nil nil)

;;============================== GENERAL FUNCTIONS ===============================

(setq separator-length 80)
(defun sokus-insert-separator (separator-title separator-symbol)
  (setq padded-title-length (+ (length separator-title) 2))
  (setq total-symbols-to-enter (- separator-length padded-title-length))
  (setq left-side-length (/ total-symbols-to-enter 2))
  (setq right-side-length (- total-symbols-to-enter left-side-length))
  (dotimes `left-side-length (insert separator-symbol))
  (insert (concat " " separator-title " "))
  (dotimes `right-side-length (insert separator-symbol)))

(defun sokus-insert-major-separator (separator-title)
  (interactive "sTitle: ")
  (sokus-insert-separator separator-title "="))
(defun sokus-insert-minor-separator (separator-title)
  (interactive "sTitle: ")
  (sokus-insert-separator separator-title "-"))

(defun sokus-replace-string (from-string to-string)
       "Replace a string without moving point."
       (interactive "sReplace: \nsReplace: %s  With: ")
       (save-excursion
         (replace-string from-string to-string)
         ))

(defun sokus-replace-in-region (old-word new-word)
  "Perform a replace-string in the current region."
  (interactive "sReplace: \nsReplace: %s  With: ")
  (save-excursion
    (save-restriction
      (narrow-to-region (mark) (point))
      (beginning-of-buffer)
      (replace-string old-word new-word)
      )))

(defun sokus-save-buffer ()
  "Save the buffer after untabifying it."
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (untabify (point-min) (point-max))))
  (save-buffer))

(defun sokus-kill-other-buffers ()
      "Kill all other buffers."
      (interactive)
      (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))

;;================================== BEHAVIOUR ===================================

(defun sokus-ediff-setup-windows (buffer-A buffer-B buffer-C control-buffer)
  (ediff-setup-windows-plain buffer-A buffer-B buffer-C control-buffer)
)
(setq ediff-window-setup-function 'sokus-ediff-setup-windows)
(setq ediff-split-window-function 'split-window-horizontally)

(defadvice set-mark-command (after no-bloody-t-m-m activate)
  "Prevent consecutive marks activating bloody `transient-mark-mode'."
  (if transient-mark-mode (setq transient-mark-mode nil)))

(defadvice mouse-set-region-1 (after no-bloody-t-m-m activate)
  "Prevent mouse commands activating bloody `transient-mark-mode'."
  (if transient-mark-mode (setq transient-mark-mode nil)))

;;============================== PLATFORM SPECIFIC ===============================

(setq sokus-linux (featurep 'x))
(setq sokus-win32 (not sokus-linux))

(when sokus-linux
  (setq sokus-makescript "./build.sh"))

(when sokus-win32
  (setq sokus-makescript "build.bat"))

;;(set-variable 'grep-command "grep -irHn ")
(when sokus-win32
    (setq grep-use-null-device t)
    (set-variable 'grep-command "findstr -s -n -i -l "))

;;================================= COMPILATION ==================================

(defun find-project-directory-recursive ()
  "Recursively search for a makefile."
  (interactive)
  (if (file-exists-p sokus-makescript) t
      (cd "../")
      (find-project-directory-recursive)))

(setq compilation-directory-locked nil)
(defun lock-compilation-directory ()
  "The compilation process should NOT hunt for a makefile"
  (interactive)
  (setq compilation-directory-locked t)
  (message "Compilation directory is locked."))

(defun unlock-compilation-directory ()
  "The compilation process SHOULD hunt for a makefile"
  (interactive)
  (setq compilation-directory-locked nil)
  (message "Compilation directory is roaming."))

(defun find-project-directory ()
  "Find the project directory."
  (interactive)
  (setq find-project-from-directory default-directory)
  (switch-to-buffer-other-window "*compilation*")
  (if compilation-directory-locked (cd last-compilation-directory)
    (cd find-project-from-directory)
    (find-project-directory-recursive)
    (setq last-compilation-directory default-directory)))

(defun make-without-asking ()
  "Make the current build."
  (interactive)
  (if (find-project-directory) (compile sokus-makescript))
  (other-window 1))

(defun sokus-compilation-hook ()
  (make-local-variable 'truncate-lines)
  (setq truncate-lines nil))
(add-hook 'compilation-mode-hook 'sokus-compilation-hook)

(setq compilation-context-lines 0)
(setq compilation-error-regexp-alist
      (cons '("^\\([0-9]+>\\)?\\(\\(?:[a-zA-Z]:\\)?[^:(\t\n]+\\)(\\([0-9]+\\)) : \\(?:fatal error\\|warnin\\(g\\)\\) C[0-9]+:" 2 3 nil (4))
          compilation-error-regexp-alist))

;;================================= KEYBINDINGS ==================================

(global-set-key (kbd "C-x p m") 'make-without-asking)
(global-set-key (kbd "M-g f") 'first-error)
(global-set-key (kbd "C-d") 'delete-region)

(define-key isearch-mode-map (kbd "C-s") 'isearch-repeat-forward)
(define-key isearch-mode-map (kbd "C-r") 'isearch-repeat-backward)

;; (define-key global-map "\ej" 'imenu)

;;=============================== FILE EXTENSIONS ================================

(setq auto-mode-alist
      (append
       '(("\\.cpp$"    . c++-mode)
         ("\\.hin$"    . c++-mode)
         ("\\.cin$"    . c++-mode)
         ("\\.inl$"    . c++-mode)
         ("\\.rdc$"    . c++-mode)
         ("\\.h$"    . c++-mode)
         ("\\.c$"   . c++-mode)
         ("\\.cc$"   . c++-mode)
         ("\\.c8$"   . c++-mode)
         ("\\.txt$" . indented-text-mode)
         ("\\.emacs$" . emacs-lisp-mode)
         ("\\.gen$" . gen-mode)
         ("\\.ms$" . fundamental-mode)
         ("\\.m$" . objc-mode)
         ("\\.mm$" . objc-mode)
         ) auto-mode-alist))

(defconst sokus-c-style
  '((c-electric-pound-behavior   . nil)
    (c-tab-always-indent         . t)
    (c-comment-only-line-offset  . 0)
    (c-hanging-braces-alist      . ((class-open)
                                    (class-close)
                                    (defun-open)
                                    (defun-close)
                                    (inline-open)
                                    (inline-close)
                                    (brace-list-open)
                                    (brace-list-close)
                                    (brace-list-intro)
                                    (brace-list-entry)
                                    (block-open)
                                    (block-close)
                                    (substatement-open)
                                    (statement-case-open)
                                    (class-open)))
    (c-hanging-colons-alist      . ((inher-intro)
                                    (case-label)
                                    (label)
                                    (access-label)
                                    (access-key)
                                    (member-init-intro)))
    (c-cleanup-list              . (scope-operator
                                    list-close-comma
                                    defun-close-semi))
    (c-offsets-alist             . ((arglist-close         .  c-lineup-arglist)
                                    (label                 . -4)
                                    (access-label          . -4)
                                    (substatement-open     .  0)
                                    (statement-case-intro  .  4)
				    ;;(statement-block-intro . c-lineup-for)
                                    (statement-block-intro .  +)
                                    (case-label            .  4)
                                    (block-open            .  0)
                                    (inline-open           .  0)
                                    (topmost-intro-cont    .  0)
                                    (knr-argdecl-intro     . -4)
                                    (brace-list-open       .  0)
                                    (brace-list-intro      .  4)))
    (c-echo-syntactic-information-p . t))
    "Sokus C Style")
 
(defun sokus-c-hook ()
  (c-add-style "SokusCStyle" sokus-c-style t)
  
  (setq tab-width 4
        indent-tabs-mode nil)

  (c-set-offset 'member-init-intro '++) ; additional style stuff
  (c-toggle-auto-hungry-state -1)

  ; Newline indents, semi-colon doesn't
  (define-key c++-mode-map (kbd "C-d") 'delete-region)
  (define-key c++-mode-map "\C-m" 'newline-and-indent)
  (setq c-hanging-semi&comma-criteria '((lambda () 'stop)))
  ; Handle super-tabbify (TAB completes, shift-TAB actually tabs)
  (setq dabbrev-case-replace t)
  (setq dabbrev-case-fold-search t)
  (setq dabbrev-upcase-means-case-search t)

  ; Abbrevation expansion
  (abbrev-mode 1)

  ; Turn on line numbers
  ;(linum-mode)
)
(add-hook 'c-mode-common-hook 'sokus-c-hook)

(defun sokus-text-hook ()
  (setq tab-width 4
        indent-tabs-mode nil)
  (define-key text-mode-map "\C-m" 'newline-and-indent)
)
(add-hook 'text-mode-hook 'sokus-text-hook)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(cmake-mode modern-cpp-font-lock lsp-ui lsp-mode flycheck use-package gruvbox-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
