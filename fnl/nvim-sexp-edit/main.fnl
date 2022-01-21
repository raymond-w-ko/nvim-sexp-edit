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

(defn visually-select [f args]
  (let [{: mode} (nvim.get_mode)
        [begin end] (f)]
    (when (and begin end)
      (when (= mode "v") (nvim.ex.normal! "v"))
      (nvim.win_set_cursor 0 [(. begin 1) (a.dec (. begin 2))])
      (nvim.ex.normal! "v")
      (nvim.win_set_cursor 0 [(. end 1) (a.dec (. end 2))])))
  nil)
 
(defn around-form []
  (visually-select seek.seek-current-form-boundaries {:inside false}))
(defn in-form []
  (visually-select seek.seek-current-form-boundaries {:inside true}))
(defn around-element []
  (visually-select seek.seek-current-element-boundaries {:inside false}))
(defn in-element []
  (visually-select seek.seek-current-element-boundaries {:inside true}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn setup-buffer []
  (vim.keymap.set ["o" "x"] "af" around-form {:buffer 0})
  (vim.keymap.set ["o" "x"] "if" in-form {:buffer 0})
  (vim.keymap.set ["o" "x"] "ae" around-element {:buffer 0})
  (vim.keymap.set ["o" "x"] "ie" in-element {:buffer 0})
  
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
