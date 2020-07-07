;;; .doom.d/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Jacob Chvatal"
      user-mail-address "jakechvatal@gmail.com"
      company-idle-delay nil
      lsp-ui-sideline-enable nil
      lsp-enable-symbol-highlighting nil)

(use-package! deadgrep
  :if (executable-find "rg")
  :init
  (map! :leader
        :desc "ripgrep" "r" #'deadgrep))

(use-package! fira-code-mode
  :custom (fira-code-mode-disabled-ligatures '("[]" "#{" "#(" "#_" "#_(" "x"))
  :hook prog-mode) ;; Enables fira-code-mode automatically for programming major modes

(use-package! mastodon
  :ensure t
  :init
  (setq mastodon-instance-url "https://merveilles.town")
  :config
  (mastodon-discover)
  (map!
   :leader
   :prefix "t"
   :desc "toot" "t" #'mastodon-toot))

;; ------------------------------------------------------------------------- Mail
(use-package! notmuch :commands (notmuch)
  :init
  (map! :desc "notmuch" "<f2>" #'notmuch)
  (map! :map notmuch-search-mode-map
        :desc "toggle read" "t" #'+notmuch/toggle-read
        :desc "Reply to thread" "r" #'notmuch-search-reply-to-thread
        :desc "Reply to thread sender" "R" #'notmuch-search-reply-to-thread-sender)
  (map! :map notmuch-show-mode-map
        :desc "Next link" "<tab>" #'org-next-link
        :desc "Previous link" "<backtab>" #'org-previous-link
        :desc "URL at point" "C-<return>" #'browse-url-at-point)
  (defun +notmuch/toggle-read ()
    "toggle read status of message"
    (interactive)
    (if (member "unread" (notmuch-search-get-tags))
        (notmuch-search-tag (list "-unread"))
      (notmuch-search-tag (list "+unread"))))
  :config
  (setq message-auto-save-directory "~/.mail/drafts/"
        message-send-mail-function 'message-send-mail-with-sendmail
        sendmail-program (executable-find "msmtp")
        message-sendmail-envelope-from 'header
        mail-envelope-from 'header
        mail-specify-envelope-from t
        message-sendmail-f-is-evil nil
        message-kill-buffer-on-exit t
        notmuch-always-prompt-for-sender t
        notmuch-archive-tags '("-inbox" "-unread")
        notmuch-crypto-process-mime t
        notmuch-hello-sections '(notmuch-hello-insert-saved-searches)
        notmuch-labeler-hide-known-labels t
        notmuch-search-oldest-first nil
        notmuch-archive-tags '("-inbox" "-unread")
        notmuch-message-headers '("To" "Cc" "Subject" "Bcc")
        notmuch-saved-searches '((:name "inbox" :query "tag:inbox")
                                 (:name "unread" :query "tag:inbox and tag:unread")
                                 (:name "drafts" :query "tag:draft"))))


;; -------------------------------------------------------------------------- RSS
(use-package! elfeed)
(use-package! elfeed-protocol
  :init
  :config
  (setq elfeed-protocol-ttrss-maxsize 200
        elfeed-set-timeout 36000
        elfeed-feeds
        '(("ttrss+https://jake@rss.chvatal.com"
           :password (read-passwd "Provide your tt-rss password:")))))

(after! elfeed
  (elfeed-protocol-enable)
  (map!
   :leader
   :prefix "o"
   :desc "elfeed" "e" #'elfeed)
  (map! :leader
        :prefix "e"
        :desc "elfeed" "e" #'elfeed
        :desc "elfeed-protocol-ttrss-update" "u" #'elfeed-protocol-ttrss-update
        :desc "elfeed-protocol-ttrss-update-star" "s"
        #'elfeed-protocol-ttrss-update-star))

;; -------------------------------------------------------------------------- Org
;; org-directories
(setq org-directory "~/org/"
      org-agenda-files "~/org/agenda/"
      org-default-notes-file "~/org/refile.org"
      org-attach-directory "~/org/.attach/")

(setq j/org-calendar-dir "~/org/calendar/")

(use-package! org
  :mode ("\\.\\(org\\|org_archive\\|txt\\)$" . org-mode)
  :init
  (map! :map org-mode-map
        "M-n" #'outline-next-visible-heading
        "M-p" #'outline-previous-visible-heading)
  (setq org-src-window-setup 'current-window
        org-return-follows-link t
        org-babel-load-languages '((emacs-lisp . t)
                                   (python . t)
                                   (dot . t))
        org-confirm-babel-evaluate nil
        org-use-speed-commands t
        org-catch-invisible-edits 'show org-preview-latex-image-directory "/tmp/ltximg/"
        org-structure-template-alist '(("a" . "export ascii")
                                       ("c" . "center")
                                       ("C" . "comment")
                                       ("e" . "example")
                                       ("E" . "export")
                                       ("h" . "export html")
                                       ("l" . "export latex")
                                       ("q" . "quote")
                                       ("s" . "src")
                                       ("v" . "verse")
                                       ("el" . "src emacs-lisp")
                                       ("d" . "definition")
                                       ("t" . "theorem")))

  (with-eval-after-load 'flycheck
    (flycheck-add-mode 'proselint 'org-mode)))


(setq org-log-done 'time
      org-log-into-drawer t
      org-log-state-notes-insert-after-drawers nil)

(setq org-capture-templates
      `(("i" "inbox" entry (file ,(concat org-agenda-files "inbox.org"))
         "* TODO %?")
        ("m" "media" entry (file+headline ,(concat org-agenda-files "media.org") "Media")
         "* TODO [#A] Reply: %a :@home:@school:" :immediate-finish t)
        ("l" "link" entry (file ,(concat org-agenda-files "inbox.org"))
         "* TODO %(org-cliplink-capture)" :immediate-finish t)
        ("c" "org-protocol-capture" entry (file ,(concat org-agenda-files "inbox.org"))
         "* TODO [[%:link][%:description]]\n\n %i" :immediate-finish t)))

;; ;; Org-GCAL
;; (use-package! org-gcal
;;   :config (setq org-gcal-client-id
;;                 "619470530759-7g9daplb32uk39fmg2tsqqt15p9vvn5v.apps.googleusercontent.com"
;;                 org-gcal-client-secret
;;                 "lcOVB80NCf2_3Ei8WV0_4JKP"
;;                 org-gcal-file-alist
;;                 '(("jakechvatal@gmail.com" . "~/org/calendar/schedule.org"))))

(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
        (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)")))

;;("oao5h6d8eimrav5use51ea0pt8@group.calendar.google.com" .(concat 'j/org-calendar-dir "important_events.org"))
;; eojeegm37fqfgtq97iqt52mucg@group.calendar.google.com extracirriculars
;; oao5h6d8eimrav5use51ea0pt8@group.calendar.google.com important events
;; qlsddquar66p6k014jme4v1f6g@group.calendar.google.com office hours
;; 017sn1vqhpdtpcaoqtqriku28o@group.calendar.google.com TAing
;; u0utv6dn5to1ng51etrheqiahs@group.calendar.google.com class schedule
;; directory for attaching files in org mode

;; ;; refiling tasks after collecting in capture mode
;; ;; any file in org-agenda-files is a target, or the current file
;; (setq org-refile-targets (quote ((nil :maxlevel . 9)
;;                                  (org-agenda-files :maxlevel . 9)))
;;       org-refile-use-outline-path t
;;       org-outline-path-complete-in-steps nil
;;       org-refile-allow-creating-parent-nodes (quote confirm)
;;       org-agenda-dim-blocked-tasks nil
;;       org-agenda-compact-blocks t
;;       org-enforce-todo-dependencies t)

(use-package! org-roam
  :commands (org-roam-insert org-roam-find-file org-roam-switch-to-buffer org-roam)
  :hook (after-init . org-roam-mode)
  :custom-face (org-roam-link ((t (:inherit org-link :foreground "#005200"))))
  :init
  (map! :leader
        :prefix "n"
        :desc "org-roam" "l" #'org-roam
        :desc "org-roam-insert" "i" #'org-roam-insert
        :desc "org-roam-switch-to-buffer" "b" #'org-roam-switch-to-buffer
        :desc "org-roam-find-file" "f" #'org-roam-find-file
        :desc "org-roam-show-graph" "g" #'org-roam-show-graph
        :desc "org-roam-insert" "i" #'org-roam-insert
        :desc "org-roam-capture" "c" #'org-roam-capture)
  (setq org-roam-directory "~/org/wiki/org/"
        org-roam-db-location "~/org/wiki/org/org-roam.db"
        org-roam-graph-exclude-matcher "private"
        org-roam-tag-sources '(prop last-directory)
        org-id-link-to-org-use-id t)
  :config
  (setq org-roam-capture-templates
        '(("l" "lit" plain (function org-roam--capture-get-point)
           "%?"
           :file-name "lit/${slug}"
           :head "#+setupfile:./hugo_setup.org
#+hugo_slug: ${slug}
#+title: ${title}\n"
           :unnarrowed t)
          ("c" "concept" plain (function org-roam--capture-get-point)
           "%?"
           :file-name "concepts/${slug}"
           :head "#+setupfile:./hugo_setup.org
#+hugo_slug: ${slug}
#+title: ${title}\n"
           :unnarrowed t)
          ("p" "private" plain (function org-roam-capture--get-point)
           "%?"
           :file-name "private/${slug}"
           :head "#+title: ${title}\n"
           :unnarrowed t)))
  (setq org-roam-capture-ref-templates
        '(("r" "ref" plain (function org-roam-capture--get-point)
           "%?"
           :file-name "lit/${slug}"
           :head "#+setupfile:./hugo_setup.org
#+roam_key: ${ref}
#+hugo_slug: ${slug}
#+roam_tags: website
#+title: ${title}
- source :: ${ref}"
           :unnarrowed t))))

(after! (org org-roam)
  (use-package! org-roam-protocol)
  (use-package! org-roam-server)
  (setq org-roam-ref-capture-templates
        '(("r" "ref" plain (function org-roam-capture--get-point)
               "%?"
               :file-name "websites/${slug}"
               :head "#+TITLE: ${title}
    #+ROAM_KEY: ${ref}
    - source :: ${ref}"
               :unnarrowed t)))
  (defun j/org-roam-export-all ()
    "Re-exports all Org-roam files to Hugo markdown."
    (interactive)
    (dolist (f (org-roam--list-all-files))
      (with-current-buffer (find-file f)
        (when (s-contains? "setupfile" (buffer-string))
          (org-hugo-export-wim-to-md)))))
  (defun j/org-roam--backlinks-list (file)
    (when (org-roam--org-roam-file-p file)
      (mapcar #'car (org-roam-db-query [:select :distinct [from]
                                                :from links
                                                :where (= to $s1)
                                                :and from :not :like $s2] file "%private%"))))
  (defun j/org-export-preprocessor (_backend)
    (when-let ((links (j/org-roam--backlinks-list (buffer-file-name))))
      (insert "\n** Backlinks\n")
      (dolist (link links)
        (insert (format "- [[file:%s][%s]]\n"
                        (file-relative-name link org-roam-directory)
                        (org-roam--get-title-or-slug link))))))

  (defun j/org-roam-export-updated ()
    "Re-export files that are linked to the current file."
    (let ((files (org-roam-sql [:select [to] :from links :where (= from $s1)] buffer-file-name)))
      (interactive)
      (dolist (f files)
        (with-current-buffer (find-file-noselect (car f))
          (when (s-contains? "setupfile" (buffer-string))
            (org-hugo-export-wim-to-md))))))
  (add-hook 'org-export-before-processing-hook #'j/org-export-preprocessor))


(after! (org ox-hugo)
  (defun j/conditional-hugo-enable ()
    (save-excursion
      (if (cdr (assoc "SETUPFILE" (org-roam--extract-global-props '("SETUPFILE"))))
          (org-hugo-auto-export-mode +1)
        (org-hugo-auto-export-mode -1))))
  (add-hook 'org-mode-hook #'j/conditional-hugo-enable))

;; org-projectile todo integration
(use-package! org-projectile
  :init
  (map! :leader
        :prefix "p"
        :desc "Add a TODO to a project" "n" #'org-projectile-project-todo-completing-read)
  :config
  (org-projectile-per-project)
  (progn
    (setq org-projectile-per-project-filepath "TODO.org"
          org-agenda-files (append org-agenda-files (org-projectile-todo-files)))
    (push (org-projectile-project-todo-entry) org-capture-templates))
  :ensure t)

(use-package! deft
      :after org
      :bind
      ("C-c n d" . deft)
      :custom
      (deft-recursive t)
      (deft-use-filename-as-title t)
      (deft-use-filter-string-for-filename t)
      (deft-default-extension "org")
      (deft-directory "~/org/wiki/org/"))


(use-package! org-journal
  :config
  (setq org-journal-date-prefix "#+TITLE: "
        org-journal-file-format "%Y-%m-%d.org"
        org-journal-dir "~/org/journal/"
        org-journal-carryover-items nil)
  (defun org-journal-today ()
    (interactive)
    (org-journal-new-entry t)))


(use-package! bibtex-completion
  :config
  (setq bibtex-completion-notes-path "~/org/wiki/org/"
        bibtex-completion-bibliography "~/org/wiki/org/biblio.bib"
        bibtex-completion-pdf-field "file"
        bibtex-completion-notes-template-multiple-files
        (concat
         "#+title: ${title}\n"
         "#+roam_key: cite:${=key=}\n"
         "* TODO Notes\n"
         ":PROPERTIES:\n"
         ":Custom_ID: ${=key=}\n"
         ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n"
         ":AUTHOR: ${author-abbrev}\n"
         ":JOURNAL: ${journaltitle}\n"
         ":DATE: ${date}\n"
         ":YEAR: ${year}\n"
         ":DOI: ${doi}\n"
         ":URL: ${url}\n"
         ":END:\n\n")))


;; (use-package! org-noter
;;   :after org
;;   :ensure t
;;   :config (setq org-noter-default-notes-file-names '("notes.org")
;;                 org-noter-notes-search-path '("~/org/notes/")
;;                 org-noter-separate-notes-from-heading t))

;; (use-package! citeproc-org
;;   :after org
;;   :config
;;   (citeproc-org-setup))

;; add auto spacing at 80 lines to org mode
(add-hook 'org-mode-hook '(lambda () (setq fill-column 80)))
(add-hook 'org-mode-hook 'turn-on-auto-fill)

;; ----------------------------------------------------------------------------- ETC
;; clipboard between systems
(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

;; Line number configuration
(setq display-line-numbers-type 'relative)

;; ### mode fixes and configuration ###
(add-hook 'julia-mode 'julia-repl-mode)
(add-hook 'darkroom-mode 'visual-line-mode)
(add-hook 'writeroom-mode 'visual-line-mode)

;; org alert default style
(setq alert-default-style 'libnotify)

;; ### PATH DEBUG FIX ###
(setq exec-path-from-shell-arguments '("-i"))

;; ### BROWSER ###
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "firefox")

(use-package! smerge-mode
  :bind (("C-c h s" . j/hydra-smerge/body))
  :init
  (defun j/enable-smerge-maybe ()
    "Auto-enable `smerge-mode' when merge conflict is detected."
    (save-excursion
      (goto-char (point-min))
      (when (re-search-forward "^<<<<<<< " nil :noerror)
        (smerge-mode 1))))
  (add-hook 'find-file-hook #'j/enable-smerge-maybe :append)
  :config
  (defhydra j/hydra-smerge (:color pink
                            :hint nil
                            :pre (smerge-mode 1)
                            ;; Disable `smerge-mode' when quitting hydra if
                            ;; no merge conflicts remain.
                            :post (smerge-auto-leave))
    "
   ^Move^       ^Keep^               ^Diff^                 ^Other^
   ^^-----------^^-------------------^^---------------------^^-------
   _n_ext       _b_ase               _<_: upper/base        _C_ombine
   _p_rev       _u_pper           g   _=_: upper/lower       _r_esolve
   ^^           _l_ower              _>_: base/lower        _k_ill current
   ^^           _a_ll                _R_efine
   ^^           _RET_: current       _E_diff
   "
    ("n" smerge-next)
    ("p" smerge-prev)
    ("b" smerge-keep-base)
    ("u" smerge-keep-upper)
    ("l" smerge-keep-lower)
    ("a" smerge-keep-all)
    ("RET" smerge-keep-current)
    ("\C-m" smerge-keep-current)
    ("<" smerge-diff-base-upper)
    ("=" smerge-diff-upper-lower)
    (">" smerge-diff-base-lower)
    ("R" smerge-refine)
    ("E" smerge-ediff)
    ("C" smerge-combine-with-next)
    ("r" smerge-resolve)
    ("k" smerge-kill-current)
    ("q" nil "cancel" :color blue)))

;; ----------------------------------------------------------------------------- OFF-LIMITS
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(haskell-interactive-popup-errors nil)
 '(package-selected-packages
   (quote
    (ox-hugo mastodon fira-code-mode deft org-projectile-helm proof-general org-roam-server org-roam-bibtex org-projectile org-noter exwm-x elfeed-protocol company-org-roam))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-roam-link ((t (:inherit org-link :foreground "#005200")))))
