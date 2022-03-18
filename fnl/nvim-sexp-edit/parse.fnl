(module nvim-sexp-edit.parse
  {autoload {a aniseed.core
             nvim aniseed.nvim
             str aniseed.string
             utils nvim-sexp-edit.utils}
   require-macros [nvim-sexp-edit.macros]})

(def complement-chars {"(" ")"
                       "{" "}"
                       "[" "]"
                       ")" "("
                       "}" "{"
                       "]" "["})


(def close-chars {")" true
                  "}" true
                  "]" true})
(def whitespace-chars {" " true
                       "\t" true
                       "\r" true
                       "\v" true})

(defn new-state []
  (let [[y x] (utils.current-cursor)]
    {:lines {}
     :num-lines (nvim.buf_line_count 0)
     :y y
     :x x}))

(fn load-line [state]
  (let [{: lines : y} state]
    (when (and (not (. lines y)) (< 0 y))
      (let [lines (nvim.buf_get_lines 0 (a.dec y) y true)  ;; one-based to zero-based, end exclusive
            line (. lines 1)]
        (tset state :lines y line)))
    state)) 

(fn get-line [state]
  (load-line state)
  (let [{: lines : y} state
        line (. lines y)]
    (assert line (.. "no line loaded at index" y))
    line))

(fn get-char [state]
  (let [{: x} state
        line (get-line state)]
    (string.sub line x x)))

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

(defn is-root-form-begin-line? [state]
  (let [line (get-line state)
        ch (string.sub line 1 1)]
    (or (= ch "(")
        (= ch "{"))))

(defn is-whitespace-char? [ch]
  (. whitespace-chars ch))


(fn print-state [state]
  (print (. state :y) (. state :x)))
  
(defn parse-root-form []
  (local state (new-state))
  
  (while (and (< 0 (. state :y))
                (not (is-root-form-begin-line? state)))
      (a.update state :y a.dec))
  (tset state :x 1)
  
  (local nodes [])
  (local dispatch {})
  
  (fn read-element []
    (let [{: y : x} state
          node {:begin [y x]
                :type :element}]
      (table.insert nodes node)
      (var done false)
      (while (not done)
        (forwards state)
        (let [ch (get-char state)
              f (. dispatch ch)]
          (when (or f
                    (is-whitespace-char? ch)
                    (. close-chars ch))
            (backwards state)
            (tset node :end [(. state :y) (. state :x)])
            (set done true))))))
  (fn read-string []
    (let [{: y : x} state
          node {:begin [y x]
                :type :element
                :subtype :string
                :open-char "\""
                :close-char "\""}]
      (table.insert nodes node)
      (var done false)
      (while (not done)
        (forwards state)
        (let [ch (get-char state)]
          (cond
            (= ch "\\") (forwards state)
            (= ch "\"") (do (tset node :end [(. state :y) (. state :x)])
                          (set done true)))))))
  (fn read-form []
    (let [{: y : x} state
          open-char (get-char state)
          close-char (. complement-chars open-char)
          node {:begin [y x]
                :type :form
                :open-char open-char
                :close-char close-char}]
      (table.insert nodes node)
      (var done false)
      (while (not done)
        (forwards state)
        (let [ch (get-char state)
              f (. dispatch ch)]
          (cond
            (= ch close-char) (do
                                (tset node :end [(. state :y) (. state :x)])
                                (set done true))
            f (f)
            (not (is-whitespace-char? ch)) (read-element))))))
  (tset dispatch "(" read-form)
  (tset dispatch "{" read-form)
  (tset dispatch "[" read-form)
  (tset dispatch "\"" read-string)
  
  (let [ch (get-char state)]
    ((. dispatch ch)))
  ; (print nodes)
  nodes)
