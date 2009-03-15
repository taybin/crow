;;; crow.el --- mode for editing Crow code

;; Copyright (C) 1989 Free Software Foundation, Inc.

;; Original Author: Chris Smith <csmith@convex.com>
;; Crow-mode Author: Taybin Rutkin <trutkin@black.clarku.edu>
;; Created: 15 Feb 89
;; Modified for Crow: 6 April 2000
;; Keywords: languages

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; A major mode for editing the Crow programming language.

;;; Code:

(defvar crow-mode-abbrev-table nil
  "Abbrev table in use in Crow-mode buffers.")
(define-abbrev-table 'crow-mode-abbrev-table ())

(defvar crow-mode-map ()
  "Keymap used in Crow mode.")
(if crow-mode-map
    ()
  (let ((map (make-sparse-keymap "Crow")))
    (setq crow-mode-map (make-sparse-keymap))
    (define-key crow-mode-map "{" 'electric-crow-brace)
    (define-key crow-mode-map "}" 'electric-crow-brace)
    (define-key crow-mode-map "\e\C-h" 'mark-crow-function)
    (define-key crow-mode-map "\e\C-a" 'beginning-of-crow-defun)
    (define-key crow-mode-map "\e\C-e" 'end-of-crow-defun)
    (define-key crow-mode-map "\e\C-q" 'indent-crow-exp)
    (define-key crow-mode-map "\177" 'backward-delete-char-untabify)
    (define-key crow-mode-map "\t" 'crow-indent-command)
  
    (define-key crow-mode-map [menu-bar] (make-sparse-keymap))
    (define-key crow-mode-map [menu-bar crow]
      (cons "Crow" map))
    (define-key map [beginning-of-crow-defun] '("Beginning of function" . beginning-of-crow-defun))
    (define-key map [end-of-crow-defun] '("End of function" . end-of-crow-defun))
    (define-key map [comment-region] '("Comment Out Region" . comment-region))
    (define-key map [indent-region] '("Indent Region" . indent-region))
    (define-key map [indent-line] '("Indent Line" . crow-indent-command))
    (put 'eval-region 'menu-enable 'mark-active)
    (put 'comment-region 'menu-enable 'mark-active)
    (put 'indent-region 'menu-enable 'mark-active)))

(defvar crow-mode-syntax-table nil
  "Syntax table in use in Crow-mode buffers.")

(if crow-mode-syntax-table
    ()
  (setq crow-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?\\ "\\" crow-mode-syntax-table)
  (modify-syntax-entry ?# "<" crow-mode-syntax-table)
  (modify-syntax-entry ?\n ">" crow-mode-syntax-table)
  (modify-syntax-entry ?$ "." crow-mode-syntax-table)
  (modify-syntax-entry ?/ "." crow-mode-syntax-table)
  (modify-syntax-entry ?* "." crow-mode-syntax-table)
  (modify-syntax-entry ?+ "." crow-mode-syntax-table)
  (modify-syntax-entry ?- "." crow-mode-syntax-table)
  (modify-syntax-entry ?= "." crow-mode-syntax-table)
  (modify-syntax-entry ?% "." crow-mode-syntax-table)
  (modify-syntax-entry ?< "." crow-mode-syntax-table)
  (modify-syntax-entry ?> "." crow-mode-syntax-table)
  (modify-syntax-entry ?& "." crow-mode-syntax-table)
  (modify-syntax-entry ?| "." crow-mode-syntax-table)
  (modify-syntax-entry ?\' "\"" crow-mode-syntax-table))

(defgroup crow nil
  "Mode for editing Crow code."
  :group 'languages)

(defcustom crow-indent-level 4
  "*Indentation of Crow statements with respect to containing block."
  :type 'integer
  :group 'crow)

(defcustom crow-brace-imaginary-offset 0
  "*Imagined indentation of a Crow open brace that actually follows a statement."
  :type 'integer
  :group 'crow)

(defcustom crow-brace-offset 0
  "*Extra indentation for braces, compared with other text in same context."
  :type 'integer
  :group 'crow)

(defcustom crow-continued-statement-offset 4
  "*Extra indent for Crow lines not starting new statements."
  :type 'integer
  :group 'crow)

(defcustom crow-continued-brace-offset 0
  "*Extra indent for Crow substatements that start with open-braces.
This is in addition to `crow-continued-statement-offset'."
  :type 'integer
  :group 'crow)

(defcustom crow-auto-newline nil
  "*Non-nil means automatically newline before and after braces Crow code.
This applies when braces are inserted."
  :type 'boolean
  :group 'crow)

(defcustom crow-tab-always-indent t
  "*Non-nil means TAB in Crow mode should always reindent the current line.
It will then reindent, regardless of where in the line point is
when the TAB command is used."
  :type 'boolean
  :group 'crow)

(defvar crow-imenu-generic-expression
      '((nil "^[ \t]*procedure[ \t]+\\(\\sw+\\)[ \t]*("  1))
  "Imenu expression for Crow mode.  See `imenu-generic-expression'.")



;;;###autoload
(defun crow-mode ()
  "Major mode for editing Crow code.
Expression and list commands understand all Crow brackets.
Tab indents for Crow code.
Paragraphs are separated by blank lines only.
Delete converts tabs to spaces as it moves back.
\\{crow-mode-map}
Variables controlling indentation style:
 crow-tab-always-indent
    Non-nil means TAB in Crow mode should always reindent the current line,
    regardless of where in the line point is when the TAB command is used.
 crow-auto-newline
    Non-nil means automatically newline before and after braces
    inserted in Crow code.
 crow-indent-level
    Indentation of Crow statements within surrounding block.
    The surrounding block's indentation is the indentation
    of the line on which the open-brace appears.
 crow-continued-statement-offset
    Extra indentation given to a substatement, such as the
    then-clause of an if or body of a while.
 crow-continued-brace-offset
    Extra indentation given to a brace that starts a substatement.
    This is in addition to `crow-continued-statement-offset'.
 crow-brace-offset
    Extra indentation for line if it starts with an open brace.
 crow-brace-imaginary-offset
    An open brace following other text is treated as if it were
    this far to the right of the start of its line.

Turning on Crow mode calls the value of the variable `crow-mode-hook'
with no args, if that value is non-nil."
  (interactive)
  (kill-all-local-variables)
  (use-local-map crow-mode-map)
  (setq major-mode 'crow-mode)
  (setq mode-name "Crow")
  (setq local-abbrev-table crow-mode-abbrev-table)
  (set-syntax-table crow-mode-syntax-table)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start (concat "$\\|" page-delimiter))
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'crow-indent-line)
  (make-local-variable 'require-final-newline)
  (setq require-final-newline t)
  (make-local-variable 'comment-start)
  (setq comment-start "# ")
  (make-local-variable 'comment-end)
  (setq comment-end "")
  (make-local-variable 'comment-column)
  (setq comment-column 32)
  (make-local-variable 'comment-start-skip)
  (setq comment-start-skip "# *")
  (make-local-variable 'comment-indent-function)
  (setq comment-indent-function 'crow-comment-indent)
  ;; font-lock support
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults  
	'((crow-font-lock-keywords
	   crow-font-lock-keywords-1 crow-font-lock-keywords-2)
	  nil nil ((?_ . "w")) beginning-of-defun
	  ;; Obsoleted by Emacs 19.35 parse-partial-sexp's COMMENTSTOP.
	  ;(font-lock-comment-start-regexp . "#")
	  (font-lock-mark-block-function . mark-defun)))
  ;; imenu support
  (make-local-variable 'imenu-generic-expression)
  (setq imenu-generic-expression crow-imenu-generic-expression)
  ;; hideshow support
  ;; we start from the assertion that `hs-special-modes-alist' is autoloaded.
  (unless (assq 'crow-mode hs-special-modes-alist)
    (setq hs-special-modes-alist
	  (cons '(crow-mode "\\<procedure\\>" "\\<end\\>" nil 
			    crow-forward-sexp-function)
		hs-special-modes-alist)))
  (run-hooks 'crow-mode-hook))

;; This is used by indent-for-comment to decide how much to
;; indent a comment in Crow code based on its context.
(defun crow-comment-indent ()
  (if (looking-at "^#")
      0	
    (save-excursion
      (skip-chars-backward " \t")
      (max (if (bolp) 0 (1+ (current-column)))
	   comment-column))))

(defun electric-crow-brace (arg)
  "Insert character and correct line's indentation."
  (interactive "P")
  (let (insertpos)
    (if (and (not arg)
	     (eolp)
	     (or (save-excursion
		   (skip-chars-backward " \t")
		   (bolp))
		 (if crow-auto-newline
		     (progn (crow-indent-line) (newline) t)
		   nil)))
	(progn
	  (insert last-command-char)
	  (crow-indent-line)
	  (if crow-auto-newline
	      (progn
		(newline)
		;; (newline) may have done auto-fill
		(setq insertpos (- (point) 2))
		(crow-indent-line)))
	  (save-excursion
	    (if insertpos (goto-char (1+ insertpos)))
	    (delete-char -1))))
    (if insertpos
	(save-excursion
	  (goto-char insertpos)
	  (self-insert-command (prefix-numeric-value arg)))
      (self-insert-command (prefix-numeric-value arg)))))

(defun crow-indent-command (&optional whole-exp)
  (interactive "P")
  "Indent current line as Crow code, or in some cases insert a tab character.
If `crow-tab-always-indent' is non-nil (the default), always indent current
line.  Otherwise, indent the current line only if point is at the left margin
or in the line's indentation; otherwise insert a tab.

A numeric argument, regardless of its value, means indent rigidly all the
lines of the expression starting after point so that this line becomes
properly indented.  The relative indentation among the lines of the
expression are preserved."
  (if whole-exp
      ;; If arg, always indent this line as Crow
      ;; and shift remaining lines of expression the same amount.
      (let ((shift-amt (crow-indent-line))
	    beg end)
	(save-excursion
	  (if crow-tab-always-indent
	      (beginning-of-line))
	  (setq beg (point))
	  (forward-sexp 1)
	  (setq end (point))
	  (goto-char beg)
	  (forward-line 1)
	  (setq beg (point)))
	(if (> end beg)
	    (indent-code-rigidly beg end shift-amt "#")))
    (if (and (not crow-tab-always-indent)
	     (save-excursion
	       (skip-chars-backward " \t")
	       (not (bolp))))
	(insert-tab)
      (crow-indent-line))))

(defun crow-indent-line ()
  "Indent current line as Crow code.
Return the amount the indentation changed by."
  (let ((indent (calculate-crow-indent nil))
	beg shift-amt
	(case-fold-search nil)
	(pos (- (point-max) (point))))
    (beginning-of-line)
    (setq beg (point))
    (cond ((eq indent nil)
	   (setq indent (current-indentation)))
	  ((looking-at "[ \t]*#")
	   (setq indent 0))
	  (t
	   (skip-chars-forward " \t")
	   (if (listp indent) (setq indent (car indent)))
	   (cond ((and (looking-at "else\\b")
		       (not (looking-at "else\\s_")))
		  (setq indent (save-excursion
				 (crow-backward-to-start-of-if)
				 (current-indentation))))
		 ((or (= (following-char) ?})
		      (looking-at "end\\b"))
		  (setq indent (- indent crow-indent-level)))
		 ((= (following-char) ?{)
		  (setq indent (+ indent crow-brace-offset))))))
    (skip-chars-forward " \t")
    (setq shift-amt (- indent (current-column)))
    (if (zerop shift-amt)
	(if (> (- (point-max) pos) (point))
	    (goto-char (- (point-max) pos)))
      (delete-region beg (point))
      (indent-to indent)
      ;; If initial point was within line's indentation,
      ;; position after the indentation.  Else stay at same point in text.
      (if (> (- (point-max) pos) (point))
	  (goto-char (- (point-max) pos))))
    shift-amt))

(defun calculate-crow-indent (&optional parse-start)
  "Return appropriate indentation for current line as Crow code.
In usual case returns an integer: the column to indent to.
Returns nil if line starts inside a string, t if in a comment."
  (save-excursion
    (beginning-of-line)
    (let ((indent-point (point))
	  (case-fold-search nil)
	  state
	  containing-sexp
	  toplevel)
      (if parse-start
	  (goto-char parse-start)
	(setq toplevel (beginning-of-crow-defun)))
      (while (< (point) indent-point)
	(setq parse-start (point))
	(setq state (parse-partial-sexp (point) indent-point 0))
	(setq containing-sexp (car (cdr state))))
      (cond ((or (nth 3 state) (nth 4 state))
	     ;; return nil or t if should not change this line
	     (nth 4 state))
	    ((and containing-sexp
		  (/= (char-after containing-sexp) ?{))
	     ;; line is expression, not statement:
	     ;; indent to just after the surrounding open.
	     (goto-char (1+ containing-sexp))
	     (current-column))
	    (t
	      (if toplevel
		  ;; Outside any procedures.
		  (progn (crow-backward-to-noncomment (point-min))
			 (if (crow-is-continuation-line)
			     crow-continued-statement-offset 0))
		;; Statement level.
		(if (null containing-sexp)
		    (progn (beginning-of-crow-defun)
			   (setq containing-sexp (point))))
		(goto-char indent-point)
		;; Is it a continuation or a new statement?
		;; Find previous non-comment character.
		(crow-backward-to-noncomment containing-sexp)
		;; Now we get the answer.
		(if (crow-is-continuation-line)
		    ;; This line is continuation of preceding line's statement;
		    ;; indent  crow-continued-statement-offset  more than the
		    ;; first line of the statement.
		    (progn
		      (crow-backward-to-start-of-continued-exp containing-sexp)
		      (+ crow-continued-statement-offset (current-column)
			 (if (save-excursion (goto-char indent-point)
					     (skip-chars-forward " \t")
					     (eq (following-char) ?{))
			     crow-continued-brace-offset 0)))
		  ;; This line starts a new statement.
		  ;; Position following last unclosed open.
		  (goto-char containing-sexp)
		  ;; Is line first statement after an open-brace?
		  (or
		    ;; If no, find that first statement and indent like it.
		    (save-excursion
		      (if (looking-at "procedure\\s ")
			  (forward-sexp 3)
			(forward-char 1))
;		      (if (looking-at "behavior\\s ")
;			  (forward-sexp 3)
;			(forward-char 1))
		      (while (progn (skip-chars-forward " \t\n")
				    (looking-at "#"))
			;; Skip over comments following openbrace.
			(forward-line 1))
		      ;; The first following code counts
		      ;; if it is before the line we want to indent.
		      (and (< (point) indent-point)
			   (current-column)))
		    ;; If no previous statement,
		    ;; indent it relative to line brace is on.
		    ;; For open brace in column zero, don't let statement
		    ;; start there too.  If crow-indent-level is zero,
		    ;; use crow-brace-offset + crow-continued-statement-offset
		    ;; instead.
		    ;; For open-braces not the first thing in a line,
		    ;; add in crow-brace-imaginary-offset.
		    (+ (if (and (bolp) (zerop crow-indent-level))
			   (+ crow-brace-offset
			      crow-continued-statement-offset)
			 crow-indent-level)
		       ;; Move back over whitespace before the openbrace.
		       ;; If openbrace is not first nonwhite thing on the line,
		       ;; add the crow-brace-imaginary-offset.
		       (progn (skip-chars-backward " \t")
			      (if (bolp) 0 crow-brace-imaginary-offset))
		       ;; Get initial indentation of the line we are on.
		       (current-indentation))))))))))

;; List of words to check for as the last thing on a line.
;; If cdr is t, next line is a continuation of the same statement,
;; if cdr is nil, next line starts a new (possibly indented) statement.

(defconst crow-resword-alist
  '(("by" . t) ("case" . t) ("class" . t) ("create") ("do") 
    ("dynamic" . t) ("else") ("every" . t) ("if" . t) ("global" . t) 
    ("initial" . t) ("link" . t) ("local" . t) ("of") ("record" . t) 
    ("repeat" . t) ("static" . t) ("then") ("to" . t) ("until" . t) 
    ("while" . t)))

(defun crow-is-continuation-line ()
  (let* ((ch (preceding-char))
	 (ch-syntax (char-syntax ch)))
    (if (eq ch-syntax ?w)
	(assoc (buffer-substring
		(progn (forward-word -1) (point))
		(progn (forward-word 1) (point)))
	       crow-resword-alist)
      (not (memq ch '(0 ?\; ?\} ?\{ ?\) ?\] ?\" ?\' ?\n))))))

(defun crow-backward-to-noncomment (lim)
  (let (opoint stop)
    (while (not stop)
      (skip-chars-backward " \t\n\f" lim)
      (setq opoint (point))
      (beginning-of-line)
      (if (and (nth 5 (parse-partial-sexp (point) opoint))
	       (< lim (point)))
	  (search-backward "#")
	(setq stop t)))))

(defun crow-backward-to-start-of-continued-exp (lim)
  (if (memq (preceding-char) '(?\) ?\]))
      (forward-sexp -1))
  (beginning-of-line)
  (skip-chars-forward " \t")
  (cond
   ((<= (point) lim) (goto-char (1+ lim)))
   ((not (crow-is-continued-line)) 0)
   ((and (eq (char-syntax (following-char)) ?w)
	 (cdr
	  (assoc (buffer-substring (point)
				   (save-excursion (forward-word 1) (point)))
		 crow-resword-alist))) 0)
   (t (end-of-line 0) (crow-backward-to-start-of-continued-exp lim))))

(defun crow-is-continued-line ()
  (save-excursion
    (end-of-line 0)
    (crow-is-continuation-line)))

(defun crow-backward-to-start-of-if (&optional limit)
  "Move to the start of the last \"unbalanced\" if."
  (or limit (setq limit (save-excursion (beginning-of-crow-defun) (point))))
  (let ((if-level 1)
	(case-fold-search nil))
    (while (not (zerop if-level))
      (backward-sexp 1)
      (cond ((looking-at "else\\b")
	     (setq if-level (1+ if-level)))
	    ((looking-at "if\\b")
	     (setq if-level (1- if-level)))
	    ((< (point) limit)
	     (setq if-level 0)
	     (goto-char limit))))))

(defun mark-crow-function ()
  "Put mark at end of Crow function, point at beginning."
  (interactive)
  (push-mark (point))
  (end-of-crow-defun)
  (push-mark (point))
  (beginning-of-line 0)
  (beginning-of-crow-defun))

(defun beginning-of-crow-defun ()
  "Go to the start of the enclosing procedure; return t if at top level."
  (interactive)
  (if (or
       (re-search-backward "^procedure\\s \\|^end[ \t\n]" (point-min) 'move)
       (re-search-backward "^behavior\\s \\|^end[ \t\n]" (point-min) 'move))
      (looking-at "e")
    t))

(defun end-of-crow-defun ()
  (interactive)
  (if (not (bobp)) (forward-char -1))
  (re-search-forward "\\(\\s \\|^\\)end\\(\\s \\|$\\)" (point-max) 'move)
  (forward-word -1)
  (forward-line 1))

(defun indent-crow-exp ()
  "Indent each line of the Crow grouping following point."
  (interactive)
  (let ((indent-stack (list nil))
	(contain-stack (list (point)))
	(case-fold-search nil)
	restart outer-loop-done inner-loop-done state ostate
	this-indent last-sexp last-depth
	at-else at-brace at-do
	(opoint (point))
	(next-depth 0))
    (save-excursion
      (forward-sexp 1))
    (save-excursion
      (setq outer-loop-done nil)
      (while (and (not (eobp)) (not outer-loop-done))
	(setq last-depth next-depth)
	;; Compute how depth changes over this line
	;; plus enough other lines to get to one that
	;; does not end inside a comment or string.
	;; Meanwhile, do appropriate indentation on comment lines.
	(setq inner-loop-done nil)
	(while (and (not inner-loop-done)
		    (not (and (eobp) (setq outer-loop-done t))))
	  (setq ostate state)
	  (setq state (parse-partial-sexp (point) (progn (end-of-line) (point))
					  nil nil state))
	  (setq next-depth (car state))
	  (if (and (car (cdr (cdr state)))
		   (>= (car (cdr (cdr state))) 0))
	      (setq last-sexp (car (cdr (cdr state)))))
	  (if (or (nth 4 ostate))
	      (crow-indent-line))
	  (if (or (nth 3 state))
	      (forward-line 1)
	    (setq inner-loop-done t)))
	(if (<= next-depth 0)
	    (setq outer-loop-done t))
	(if outer-loop-done
	    nil
	  (if (/= last-depth next-depth)
	      (setq last-sexp nil))
	  (while (> last-depth next-depth)
	    (setq indent-stack (cdr indent-stack)
		  contain-stack (cdr contain-stack)
		  last-depth (1- last-depth)))
	  (while (< last-depth next-depth)
	    (setq indent-stack (cons nil indent-stack)
		  contain-stack (cons nil contain-stack)
		  last-depth (1+ last-depth)))
	  (if (null (car contain-stack))
	      (setcar contain-stack (or (car (cdr state))
					(save-excursion (forward-sexp -1)
							(point)))))
	  (forward-line 1)
	  (skip-chars-forward " \t")
	  (if (eolp)
	      nil
	    (if (and (car indent-stack)
		     (>= (car indent-stack) 0))
		;; Line is on an existing nesting level.
		;; Lines inside parens are handled specially.
		(if (/= (char-after (car contain-stack)) ?{)
		    (setq this-indent (car indent-stack))
		  ;; Line is at statement level.
		  ;; Is it a new statement?  Is it an else?
		  ;; Find last non-comment character before this line
		  (save-excursion
		    (setq at-else (looking-at "else\\W"))
		    (setq at-brace (= (following-char) ?{))
		    (crow-backward-to-noncomment opoint)
		    (if (crow-is-continuation-line)
			;; Preceding line did not end in comma or semi;
			;; indent this line  crow-continued-statement-offset
			;; more than previous.
			(progn
			  (crow-backward-to-start-of-continued-exp 
			   (car contain-stack))
			  (setq this-indent
				(+ crow-continued-statement-offset 
				   (current-column)
				   (if at-brace 
				       crow-continued-brace-offset 0))))
		      ;; Preceding line ended in comma or semi;
		      ;; use the standard indent for this level.
		      (if at-else
			  (progn (crow-backward-to-start-of-if opoint)
				 (setq this-indent (current-indentation)))
			(setq this-indent (car indent-stack))))))
	      ;; Just started a new nesting level.
	      ;; Compute the standard indent for this level.
	      (let ((val (calculate-crow-indent
			   (if (car indent-stack)
			       (- (car indent-stack))))))
		(setcar indent-stack
			(setq this-indent val))))
	    ;; Adjust line indentation according to its contents
	    (if (or (= (following-char) ?})
		    (looking-at "end\\b"))
		(setq this-indent (- this-indent crow-indent-level)))
	    (if (= (following-char) ?{)
		(setq this-indent (+ this-indent crow-brace-offset)))
	    ;; Put chosen indentation into effect.
	    (or (= (current-column) this-indent)
		(progn
		  (delete-region (point) (progn (beginning-of-line) (point)))
		  (indent-to this-indent)))
	    ;; Indent any comment following the text.
	    (or (looking-at comment-start-skip)
		(if (re-search-forward comment-start-skip (save-excursion (end-of-line) (point)) t)
		    (progn (indent-for-comment) (beginning-of-line))))))))))

(defconst crow-font-lock-keywords-1
  (eval-when-compile
    (list
     ;; Fontify procedure name definitions.
     '("^[ \t]*\\(procedure\\|behavior\\)\\>[ \t]*\\(\\sw+\\)?"
       (1 font-lock-builtin-face) (2 font-lock-function-name-face nil t))))
  "Subdued level highlighting for Crow mode.")

(defconst crow-font-lock-keywords-2
  (append 
   crow-font-lock-keywords-1
   (eval-when-compile
     (list
      ;; Fontify all type specifiers.
      (cons 
       (concat 
	"\\<" (regexp-opt  '("null" "string" "co-expression" "table" "integer" 
			     "cset"  "set" "real" "file" "list") t) 
	"\\>") 
       'font-lock-type-face)
      ;; Fontify all keywords.
      ;;
      (cons 
       (concat 
	"\\<" 
	(regexp-opt 
	 '("break" "do" "next" "repeat" "to" "by" "else" "if" "not" "return" 
	   "until" "case" "of" "while" "create" "every" "suspend" "default" 
	   "fail" "record" "then" "message") t)
	"\\>")
       'font-lock-keyword-face)
      ;; Fontify locations (ie <S,X>)
      (cons "<.*>" 
	    'font-lock-keyword-face)
      ;; "class" "end" "initial" 
      (cons (concat "\\<" (regexp-opt '("class" "end" "initial") t) "\\>")
	    'font-lock-builtin-face)
      ;; Fontify all system variables.
      (cons 
       (regexp-opt 
	'("&allocated" "&ascii" "&clock" "&col" "&collections" "&column" 
	  "&control" "&cset" "&current" "&date" "&dateline" "&digits" "&dump"
	  "&e" "&error" "&errornumber" "&errortext" "&errorvalue" "&errout" 
	  "&eventcode" "&eventsource" "&eventvalue" "&fail" "&features" 
	  "&file" "here" "here.S" "here.X" "&host" "&input" "&interval" 
	  "&lcase" "&ldrag" "&letters" "&level" "&line" "&lpress" "&lrelease" 
	  "&main" "&mdrag" "&meta" "&mpress" "&mrelease" "&null" "&output" 
	  "&phi" "&pi" "&pos" "&progname" "&random" "&rdrag" "&regions" 
	  "&resize" "&row" "&rpress" "&rrelease" "&shift" "&source" "&storage"
	  "&subject" "&time" "&trace" "&ucase" "&version" "&window" "&x" 
	  "&y") t)
       'font-lock-constant-face)
      (cons      ;; global local static declarations and link files
       (concat 
	"^[ \t]*"
	(regexp-opt '("class" "global" "link" "local" "static") t)
	"\\(\\sw+\\>\\)*")
       '((1 font-lock-builtin-face)
	 (font-lock-match-c-style-declaration-item-and-skip-to-next
	  (goto-char (or (match-beginning 2) (match-end 1))) nil
	  (1 (if (match-beginning 2)
		 font-lock-function-name-face
	       font-lock-variable-name-face)))))

      (cons      ;; $define $elif $ifdef $ifndef $undef
       (concat "^" 
	       (regexp-opt'("$define" "$elif" "$ifdef" "$ifndef" "$undef") t)
	       "\\>[ \t]*\\([^ \t\n]+\\)?")
	    '((1 font-lock-builtin-face) 
	      (4 font-lock-variable-name-face nil t)))
      (cons      ;; $dump $endif $else $include 
       (concat 
	"^" (regexp-opt'("$dump" "$endif" "$else" "$include") t) "\\>" )
       'font-lock-builtin-face)
      (cons      ;; $warning $error
       (concat "^" (regexp-opt '("$warning" "$error") t)
	       "\\>[ \t]*\\(.+\\)?")
       '((1 font-lock-builtin-face) (3 font-lock-warning-face nil t))))))
  "Gaudy level highlighting for Crow mode.")

(defvar crow-font-lock-keywords crow-font-lock-keywords-1
  "Default expressions to highlight in `crow-mode'.")

;;;used by hs-minor-mode
(defun crow-forward-sexp-function (arg)
  (if (< arg 0)
      (beginning-of-crow-defun)
    (end-of-crow-defun)
    (forward-char -1)))

(provide 'crow)

;;; crow.el ends here
