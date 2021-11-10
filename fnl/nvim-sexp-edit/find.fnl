(module nvim-sexp-edit.find
  {autoload {a aniseed.core
             nvim aniseed.nvim
             str aniseed.string
             utils nvim-sexp-edit.utils}
   require-macros [nvim-sexp-edit.macros]})

(def watchdog-limit 50000)

(def open-chars {"(" ")"
                 "{" "}"
                 "[" "]"})
(def close-chars {")" "("
                  "}" "{"
                  "]" "["})

(fn new-state [y x]
  "y is line index, x is col index"
  {:lines {}
   :watchdog 0
   :imbalance 0
   :num-lines (nvim.buf_line_count 0)
   :y y
   :x x})

(fn verify-cursor [state]
  (let [{: y : x : num-lines} state]
    (cond
     (<= y 0) nil
     (> y num-lines) nil
     true state)))

(fn print-state [state]
  (print (. state :y) (. state :x) "imb" (. state :imbalance)))

(fn load-line [state]
  (let [{: lines : y} state]
    (if (and (not (. lines y)) (< 0 y))
      (let [lines (nvim.buf_get_lines 0 (a.dec y) y true)  ;; one-based to zero-based, end exclusive
            line (. lines 1)]
        (tset state :lines y line)
        state)
      state))) 

(fn get-line [state]
  (let [{: lines : y} state
        line (. lines y)]
    (assert line (.. "no line loaded at index" y))
    line))

(fn get-char [state]
  (load-line state)
  (let [{: lines : y : x} state]
    (-> (. lines y)
        (string.sub x x))))

(defn is-on-open? [state]
  (let [ch (get-char state)]
    (. open-chars ch)))
    
(defn is-on-close? [state]
  (let [ch (get-char state)]
    (. close-chars ch)))

(defn before-start-of-file? [state]
  (> 0 (. state :y)))

(defn after-end-of-file? [state n]
  (let [{: num-lines} state]
    (> (. state :y) num-lines)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
(fn backwards [state]
  (let [{: y : x} state]
    (var y y)
    (var x x)
    (set x (a.dec x))
    (if (<= x 0)
      (do
        (set y (a.dec y))
        (tset state :y y)
        (when (< 0 y)
          (load-line state)
          (tset state :x (length (get-line state))))
        state)
      (do
        (tset state :x x)
        state))))

(fn forwards [state]
  (let [{: y : x} state]
    (var y y)
    (var x x)
    (local n (length (get-line state)))
    (set x (a.inc x))
    (if (> x n)
      (do
        (tset state :x 1)
        (set y (a.inc y))
        (tset state :y y)
        state)
      (do
        (tset state :x x)
        state))))

(defn find-open [{: inside}]
  (let [[y x] (utils.current-cursor)
        state (new-state y x)]
    (var done false)
    (when (is-on-close? state)
      (backwards state))
    (while (and (not done)
                (not (before-start-of-file? state))
                (< (. state :watchdog) watchdog-limit))
      (a.update state :watchdog a.inc)
      (cond
       (is-on-open? state) (a.update state :imbalance a.inc)
       (is-on-close? state) (a.update state :imbalance a.dec))
      (if (< 0 (. state :imbalance))
        (set done true)
        (backwards state)))
    (when inside
      (forwards state))
    (verify-cursor state)))
      
(defn find-close [{: inside}]
  (let [[y x] (utils.current-cursor)
        state (new-state y x)]
    (var done false)
    (when (is-on-open? state)
      (forwards state))
    (while (and (not done)
                (not (after-end-of-file? state))
                (< (. state :watchdog) watchdog-limit))
      (a.update state :watchdog a.inc)
      (cond
       (is-on-close? state) (a.update state :imbalance a.dec)
       (is-on-open? state) (a.update state :imbalance a.inc))
      (if (< (. state :imbalance) 0)
        (set done true)
        (forwards state)))
    (when inside
      (backwards state))
    (verify-cursor state)))

(defn find-pair [args]
  (let [open (find-open args)
        open-y (. open :y)
        open-x (. open :x)
        close (find-close args)
        close-y (. close :y)
        close-x (. close :x)]
    [(when (and (<= 1 open-y) (<= 1 open-x))
       [open-y open-x])
     [(. close :y) (. close :x)]]))
