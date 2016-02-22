;;; uncrustify.el --- apply uncrustify on buffer region

;; Copyright (C) 2010 Gustavo Lima Chaves

;; Author: Gustavo Lima Chaves <com dot gmail at limachaves, in reversed order>
;; Modified: Gordon Read <com dot f2s at gtread, in reversed order>
;;           Added Customisation vars, uncrustify-region, uncrustify-buffer and
;;           uncrustify-on-save hook (15/06/2011)
;; Modified: Gordon read <com dot f2s at gtread, in reversed order>
;;           Added uncrustify-init-hooks and uncrustify-finish-hooks
;;           (12/07/2011)
;; Website: TODO
;; Keywords: uncrustify

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301, USA.

;;; Commentary:

;; A simple Emacs interface for the uncrustify source code beautifier.
;; Checks your buffers for improper code indentation. It will follow
;; the indentation rules found in the specified configuration file.

;; Load this file and run:
;;
;;  M-x uncrustify-buffer
;;
;; to indent the whole buffer or select a region and run
;;
;;  M-x uncrustify
;;
;; to indent just the region.
;;
;; See also Customisation group "uncrustify"

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom

(defgroup uncrustify nil
  "Customization group for uncrustify"
  :group 'uncrustify)

(defcustom uncrustify-uncrustify-cfg-file "~/.uncrustify.cfg"
  "Path to uncrustify configuration file.\n"
  :type 'string
  :group 'uncrustify)

(defcustom uncrustify-args ""
  "Additional arguments to pass to uncrustify."
  :type 'string
  :group 'uncrustify)

(defcustom uncrustify-init-hooks nil
  "Hooks called prior to running uncrustify."
  :type 'hook
  :group 'uncrustify)

(defcustom uncrustify-finish-hooks nil
  "Hooks called after running uncrustify."
  :type 'hook
  :group 'uncrustify)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vars

(defvar uncrustify-path nil
  "The uncrustify executable in path.\n
  When non-nil return value is the path to local uncrustify.\n
  :SEE (URL `http://uncrustify.sourceforge.net/index.php')")
(unless (bound-and-true-p uncrustify-path)
  (let ((path (or (executable-find "uncrustify")
                  (executable-find "uncrustify.exe"))))
    (when path (setq uncrustify-path path))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; private functions

(defun uncrustify~get-lang ()
  "Get language based on major-mode"
  (case major-mode
    ('c-mode    "C")
    ('c++-mode  "CPP")
    ('d-mode    "D")
    ('java-mode "JAVA")
    ('objc-mode "OC")
    ('vala-mode "VALA")
    (t nil)))

  (run-hooks 'uncrustify-init-hooks)
  (if uncrustify-path
      (let ((lang (uncrustify~get-lang)))
        (if (stringp lang)
            (let ((cmd (format "%s -c %s -l %s %s"
                               uncrustify-path
                               uncrustify-uncrustify-cfg-file
                               lang
                               uncrustify-args)))
              (shell-command-on-region point-a point-b cmd t t
                                       null-device))
          (message "Language not supported by uncrustify - no change")))
    (message "Uncrustify not found in path - no change"))
  (run-hooks 'uncrustify-finish-hooks))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; public functions

(defun uncrustify ()
  "Uncrustify the marked region.
  The configuration file will be read from the specification given by
  `uncrustify-uncrustify-cfg-file'."
  (interactive)
  (save-excursion
    (uncrustify-impl (region-beginning) (region-end))))

(defun uncrustify-buffer ()
  "Uncrustify the entire buffer.
  The configuration file will be read from the specification given by
  `uncrustify-uncrustify-cfg-file'. The cursor will attempt to (re)locate
  the current line, which might change as a result of the uncrustification."
  (interactive)
  (let* ((uncrustify-current-line (line-number-at-pos)))
    (save-excursion
      (uncrustify-impl (point-min) (point-max)))
    (goto-char (point-min)) (forward-line (1- uncrustify-current-line))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'uncrustify)
;; uncrustify.el ends here
