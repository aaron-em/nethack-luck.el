;;; nethack-luck.el - Nethack's luck messages, for your convenience

;; Copyright (C) 2013 Aaron Miller. All rights reversed.
;; Share and Enjoy!

;; Last revision: Wednesday, December 18, 2013, ca. 23:00.

;; This release of nethack-luck.el, and every future release, is
;; dedicated to the memory of Izchak Miller (1935-1994).

;; Author: Aaron Miller <me@aaron-miller.me>

;; This file is not part of Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 2, or (at your
;; option) any later version.

;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see `http://www.gnu.org/licenses'.

;;; Commentary:

;; I thought it would be nifty to have my eshell buffers' banner
;; message show the same luck-modifier messages as Nethack does, so I
;; wrote this library which does that, using Nethack's own phase-of-moon
;; algorithm for maximum veracity.

;; This library also provides a function, `nethack-luck-message',
;; which returns the message Nethack would include in its banner for
;; the given time, or for right now if no time is given; a function,
;; `nethack-luck-phase-of-moon', which returns the current phase of
;; moon, calculated by Nethack's algorithm, as an integer; a function,
;; `nethack-luck-phase-name', which returns the name corresponding to
;; an integer which `nethack-luck-phase-of-moon' might return; and a
;; few ancillary functions, which you might also find useful.

;; To use this code, drop this file into your Emacs load path, then
;; (require 'nethack-luck). This suffices to modify your default
;; Eshell banner with the Nethack luck message, if any.

;; The Eshell banner modification is made by means of advice around
;; `eshell-buffer-initialize', so the value of `eshell-banner-message'
;; is not changed. (The advice obtains the Eshell banner, before
;; modifying it, via (eval eshell-banner-message), so it will behave
;; properly no matter what value you have assigned to
;; `eshell-banner-message'.)  If you wish to disable the Eshell banner
;; modification, and simply have `nethack-luck-message' and friends
;; available for your own purposes, set `nethack-luck-modify-banner'
;; to nil.

;;; Bugs/TODO:

;; Currently, while the effect of the new moon on your luck is
;; identical to that in Nethack, there is no effect on your chance,
;; when you hear a cockatrice's or chickatrice's hissing, of
;; starting to turn to stone.

;;; Miscellany:

;; The canonical version of this file is hosted in my Github
;; repository [1]. If you didn't get it from there, great! I'm happy
;; to hear my humble efforts have achieved wide enough interest to
;; result in a fork hosted somewhere else. I'd be obliged if you'd
;; drop me a line to let me know about it.

;; [1]: https://github.com/aaron-em/nethack-luck.el

(defgroup nethack-luck nil
  "Customization options for the Nethack luck message library."
  :prefix "nethack-luck-")

(defcustom nethack-luck-modify-banner t
  "Whether to insert the Nethack luck message into the Eshell
banner. See the documentation for `eshell-banner-initialize',
specifically its advice `nethack-luck-munge-eshell-banner', for
details of how this is done."
  :group 'nethack-luck
  :group 'eshell-banner
  :type '(choice (const :tag "No" nil)
                 (const :tag "Yes" t)))

(defvar nethack-luck-phases
  '("new"  "waxing crescent" "first quarter" "waxing gibbous"
    "full" "waning gibbous"  "last quarter"  "waning crescent")
  "Names for the phases of the moon.")

(defun nethack-luck-get-day-in-year (&optional time)
  "Obtain the day of the year from TIME (or `current-time' if
TIME is not given)."
  (if (eq time nil) (setq time (current-time)))
  (string-to-number (format-time-string "%j" time)))

(defun nethack-luck-get-year (&optional time)
  "Obtain the year from TIME (or `current-time' if TIME is not
given)."
  (if (eq time nil) (setq time (current-time)))
  (string-to-number (format-time-string "%Y" time)))

(defun nethack-luck-phase-of-moon (&optional time)
  "Obtain the phase of the moon for the given TIME, using the
algorithm defined in the Nethack 3.4.3 code. Returns an integer
between 0 and 7, where 0 is new and 4 is full.

For the original C version and some minimally explanatory
comments, see lines 564-590 of hacklib.c in the Nethack 3.4.3
source."
  (if (eq time nil) (setq time (current-time)))
  (let* ((diy (nethack-luck-get-day-in-year time))
         (goldn (1+ (mod (nethack-luck-get-year time) 19)))
         (epact (mod (+ (* 11 goldn) 18) 30)))
    (if (and (eq 25 epact) (> goldn 11)) (setq epact (1+ epact)))
    (logand (/ (mod (+ (* (+ diy epact) 6) 11) 177) 22) 7)))

(defun nethack-luck-phase-name (phase)
  "Obtain the name for the given PHASE, which must be between 0
and 7 inclusive (i.e., as returned by `nethack-luck-phase-of-moon')."
  (nth phase nethack-luck-phases))

(defun nethack-luck-friday-13th-p (&optional time)
  "Predicate testing whether a given TIME (or `current-time' by
default) is Friday the 13th."
  (if (eq time nil) (setq time (current-time)))
  (string= "Fri 13" (format-time-string "%a %d" time)))

(defun nethack-luck-message (&optional time)
  "Return a Nethack-style startup message about luck for the
given TIME (or `current-time' by default)."
  (if (eq time nil) (setq time (current-time)))
  (let ((phase (nethack-luck-phase-of-moon time))
        (luck 0)
        (message nil))
    (if (nethack-luck-friday-13th-p time) (setq luck (- luck 1)))
    (if (eq phase 4) (setq luck (+ luck 1)))
    (if (eq luck 1)  (setq message "You are lucky! Full moon tonight."))
    (if (eq luck -1) (setq message "Watch out! Bad things can happen on Friday the 13th."))
    (if (and (eq luck 0)
             (eq phase 0))
        (setq message "Be careful! New moon tonight."))
    message))

(defadvice eshell-banner-initialize
  (around nethack-luck-munge-eshell-banner)
  "Insert the current Nethack luck message, if any, into the
Eshell banner, on a line of its own, prior to any trailing
newlines but otherwise at the end of the message.

  For example, the following Eshell banner:

\"Welcome to the Emacs shell

\"

might become:

\"Welcome to the Emacs shell
You are lucky! Full moon tonight.

\"

  The exact result depends on the value of
`eshell-banner-message', the current date, and the phase of
the moon."
  ;; I looked at http://www.emacswiki.org/emacs/MultilineRegexp and it
  ;; scared me; I'm not all that good with multiline regexes even when
  ;; they're PCRE ones, and despite (or perhaps because of) almost
  ;; twenty years of experience with Perl regular expressions, my
  ;; grasp of Emacs' dialect of same remains shaky. Thus, the
  ;; following, which certainly isn't any worse than a regex would be:
  (if (not (and (nethack-luck-message)
                nethack-luck-modify-banner))
      ad-do-it
    (let ((msg-initial (eval eshell-banner-message))
          blanks first-part parts tailed
          eshell-banner-message)
      (setq parts (reverse
                   (save-match-data (split-string msg-initial "\n" nil))))
      ;; Count blanks at head of 'parts' list; push a matching number
      ;; of empty strings onto 'blanks'.
      (mapcar
       #'(lambda (part)
           (if (and (not tailed))
               (if (not (string= part ""))
                   (progn
                     (setq first-part part)
                     (setq tailed t))
                 (push "" blanks))))
       parts)
      ;; Assemble the new banner message by concatenating a reversed
      ;; list made up of first the blanks, then the Nethack luck
      ;; message, and finally everything in 'parts' starting with the
      ;; first non-blank-string member.
      (setq eshell-banner-message
            (mapconcat #'(lambda (s) s)
                       (reverse `(,@blanks
                                  ,(nethack-luck-message)
                                  ,@(member first-part parts)))
                       "\n"))
      ad-do-it)))
(ad-activate 'eshell-banner-initialize)

(provide 'nethack-luck)

;; nethack-luck.el ends here
