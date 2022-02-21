(module nvim-sexp-edit.main
  {autoload {a aniseed.core
             nvim aniseed.nvim
             str aniseed.string
             util aniseed.nvim.util
             find nvim-sexp-edit.find
             seek nvim-sexp-edit.seek}
   require-macros [nvim-sexp-edit.macros]})

(def vim-fn-prefix "Sexpedit_")

(defn ->vim-fn-name [fn-name]
  (-> (.. vim-fn-prefix fn-name)
      (string.gsub "-" "_")))
      
(defn create-vim-fn [fn-name]
  (let [vim-fn-name (->vim-fn-name fn-name)]
    (util.fn-bridge vim-fn-name :nvim-sexp-edit.main fn-name)))

(defn gen-vim-ex-call [fn-name]
  (string.format "call %s()" (->vim-fn-name fn-name)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn visually-select [f {: inside}]
  (let [{: mode} (nvim.get_mode)
        [begin end] (f)]
    (when (and begin end)
      (when (= mode "v") (nvim.ex.normal! "v"))
      (let [x (a.dec (. begin 2))
            x (if inside (a.inc x) x)]
        (nvim.win_set_cursor 0 [(. begin 1) x]))
      (nvim.ex.normal! "v")
      (let [x (a.dec (. end 2))
            x (if inside (a.dec x) x)]
        (nvim.win_set_cursor 0 [(. end 1) x]))))
  nil)
 
(defn around-form []
  (visually-select seek.current-form-boundaries {:inside false}))
(defn in-form []
  (visually-select seek.current-form-boundaries {:inside true}))
(defn around-element []
  (visually-select seek.current-element-boundaries {:inside false}))
(defn in-element []
  (visually-select seek.current-element-boundaries {:inside false}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn add-char [y x ch]
  (let [lines (nvim.buf_get_lines 0 (a.dec y) y true)
        line (. lines 1)
        line (.. (line:sub 1 x) ch (line:sub (a.inc x)))]
    (nvim.buf_set_lines 0 (a.dec y) y true [line])))

(defn form-wrap [begin-ch end-ch]
  (let [[begin end] (seek.current-form-boundaries)]
    (let [[y x] end] (add-char y x end-ch))
    (let [[y x] begin] (add-char y (a.dec x) begin-ch))
    [begin end]))

(defn elem-wrap [begin-ch end-ch]
  (let [[begin end] (seek.current-element-boundaries)]
    (let [[y x] end] (add-char y x end-ch))
    (let [[y x] begin] (add-char y (a.dec x) begin-ch))
    [begin end]))

(defn paren-wrap-list [] (form-wrap "( " ")"))
(defn brace-wrap-list [] (form-wrap "[ " "]"))
(defn curly-wrap-list [] (form-wrap "{ " "}"))
(defn paren-wrap-elem [] (elem-wrap "( " ")"))
(defn brace-wrap-elem [] (elem-wrap "[ " "]"))
(defn curly-wrap-elem [] (elem-wrap "{ " "}"))

(defn jump-to-head [boundary]
  (let [[begin _] boundary
        [y x] begin]
    (nvim.win_set_cursor 0 [y x])
    (nvim.ex.startinsert)))

(defn jump-to-tail [boundary]
  (let [[_ end] boundary
        [y x] end
        x (a.inc x)]
    (nvim.win_set_cursor 0 [y x])
    (nvim.ex.startinsert)))

(defn paren-head-wrap-list [] (-> (paren-wrap-list) jump-to-head))
(defn paren-tail-wrap-list [] (-> (paren-wrap-list) jump-to-tail))
(defn brace-head-wrap-list [] (-> (brace-wrap-list) jump-to-head))
(defn brace-tail-wrap-list [] (-> (brace-wrap-list) jump-to-tail))
(defn curly-head-wrap-list [] (-> (curly-wrap-list) jump-to-head))
(defn curly-tail-wrap-list [] (-> (curly-wrap-list) jump-to-tail))

(defn paren-head-wrap-elem [] (-> (paren-wrap-elem) jump-to-head))
(defn paren-tail-wrap-elem [] (-> (paren-wrap-elem) jump-to-tail))
(defn brace-head-wrap-elem [] (-> (brace-wrap-elem) jump-to-head))
(defn brace-tail-wrap-elem [] (-> (brace-wrap-elem) jump-to-tail))
(defn curly-head-wrap-elem [] (-> (curly-wrap-elem) jump-to-head))
(defn curly-tail-wrap-elem [] (-> (curly-wrap-elem) jump-to-tail))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn setup-buffer []
  (vim.keymap.set ["o" "x"] "af" around-form {:buffer 0})
  (vim.keymap.set ["o" "x"] "if" in-form {:buffer 0})
  (vim.keymap.set ["o" "x"] "ae" around-element {:buffer 0})
  (vim.keymap.set ["o" "x"] "ie" in-element {:buffer 0})
  (vim.keymap.set ["o" "x"] "as" around-element {:buffer 0})
  (vim.keymap.set ["o" "x"] "is" in-element {:buffer 0})
  
  (let [map (fn [lhs rhs]
              (vim.keymap.set "n" lhs rhs {:buffer 0}))]
    (map "<localleader>i" paren-head-wrap-list)
    (map "<localleader>I" paren-tail-wrap-list)
    (map "<localleader>[" brace-head-wrap-list)
    (map "<localleader>]" brace-tail-wrap-list)
    (map "<localleader>{" curly-head-wrap-list)
    (map "<localleader>}" curly-tail-wrap-list)
    
    (map "<localleader>W" paren-head-wrap-elem)
    (map "<localleader>w" paren-tail-wrap-elem)
    (map "<localleader>e[" brace-head-wrap-elem)
    (map "<localleader>e]" brace-tail-wrap-elem)
    (map "<localleader>e{" curly-head-wrap-elem)
    (map "<localleader>e}" curly-tail-wrap-elem))

  (nvim.buf_set_keymap 0 "i" "(" "()<c-g>U<Left>" {:noremap true :silent true})
  (nvim.buf_set_keymap 0 "i" "[" "[]<c-g>U<Left>" {:noremap true :silent true})
  (nvim.buf_set_keymap 0 "i" "{" "{}<c-g>U<Left>" {:noremap true :silent true})
  (nvim.buf_set_keymap 0 "i" "\"" "\"\"<c-g>U<Left>" {:noremap true :silent true})
  nil)
(create-vim-fn :setup-buffer)

(defn create-augroup []
  (augroup
   "sexp-edit"
   (nvim.ex.autocmd "FileType" "clojure,fennel" (gen-vim-ex-call :setup-buffer)))
  nil)

(defn init []
  (create-augroup))
(init)
