;;; unsubscribe.el --- Unsubscribe from emails using notmuch mail
;;; Commentary:

;;; Provides unsubscribe-from-list which will either email the unsubscribe mail
;;; address or visit the unsubscribe url, depending on which is available.

;;; Package-Requires: ((notmuch "20181208.1245"))
;;; -*- lexical-binding: t; -*-

;;; Code:
(defun unsubscribe-find-in-raw-msg (regex)
  "Return capture group from REGEX after searching raw email body."
  (let ((id (notmuch-search-find-thread-id)))
    (with-temp-buffer
      (call-process notmuch-command nil t nil "show" "--format=raw" id)
      (goto-char 1)
      (re-search-forward regex nil t)
      (match-string 1))))

(defun unsubscribe-get-mail-url ()
  "Return url object of the mail-to url for unsubscription."
  (let ((match (unsubscribe-find-in-raw-msg "^List-Unsubscribe:\s*\\(?:<http[^<]+>\\)?\\(?:, \\)?<\\(mailto[^<]+\\)>")))
    (if match (url-generic-parse-url match) nil)))

(defun unsubscribe-get-web-url ()
  "Return url object of the http url for unsubscription."
  (let ((match (unsubscribe-find-in-raw-msg "^List-Unsubscribe:\s*\\(?:<mailto[^<]+>\\)?\\(?:, \\)?<\\(http[^<]+\\)>")))
    (if match match nil)))

(defun unsubscribe-from-list ()
  "Unsubscribe from the selected email list."
  (interactive)
  (let ((mail-url (unsubscribe-get-mail-url))
        (web-url (unsubscribe-get-web-url)))
        (cond (mail-url (url-mailto mail-url))
              (web-url (browse-url web-url))
              (t (message "Could not find unsubscribe url")))))

(provide 'unsubscribe)
;;; unsubscribe.el ends here
