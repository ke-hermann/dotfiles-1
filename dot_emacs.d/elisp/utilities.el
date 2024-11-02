;; various utility functions


(defun increment-number-at-point ()
  "Increment the number at point, if there is one."
  (interactive)
  (let ((num (thing-at-point 'number t)))
    (if num
        (let* ((bounds (bounds-of-thing-at-point 'number))
               (start (car bounds))
               (end (cdr bounds))
               (new-num (number-to-string (1+ num))))
          (delete-region start end)
          (insert new-num))
      (message "No number at point"))))

(defun decrement-number-at-point ()
  "Increment the number at point, if there is one."
  (interactive)
  (let ((num (thing-at-point 'number t)))
    (if num
        (let* ((bounds (bounds-of-thing-at-point 'number))
               (start (car bounds))
               (end (cdr bounds))
               (new-num (number-to-string (1- num))))
          (delete-region start end)
          (insert new-num))
      (message "No number at point"))))
