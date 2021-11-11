(module nvim-sexp-edit.main
  {autoload {a aniseed.core
             nvim aniseed.nvim
             str aniseed.string
             util aniseed.nvim.util
             find nvim-sexp-edit.find}
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

(defn form [args]
  (let [[open close] (find.find-pair args)]
    (when (and open close)
      (nvim.win_set_cursor 0 [(. open 1) (a.dec (. open 2))])
      (nvim.ex.normal! "v")
      (nvim.win_set_cursor 0 [(. close 1) (a.dec (. close 2))])))
  nil)
 
(defn around-form [count type]
  (form {:inside false :count count :type type}))
(create-vim-fn :around-form)

(defn in-form [count type]
  (form {:inside true :count count :type type}))
(create-vim-fn :in-form)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn ox-map [rhs fn-name]
  (nvim.buf_set_keymap
    0 "o" rhs (string.format ":<c-u>call %s(v:count, visualmode())<cr>" (->vim-fn-name fn-name))
    {:noremap true :silent false})
  (nvim.buf_set_keymap
    0 "x" rhs (string.format ":<c-u>call %s(v:count ,visualmode())<cr>" (->vim-fn-name fn-name))
    {:noremap true :silent false}))

(defn setup-buffer []
  (ox-map "af" :around-form)
  (ox-map "if" :in-form)
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
