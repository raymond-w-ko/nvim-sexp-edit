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

(defn current-cursor []
  "(1,1)-indexed cursor"
  [(nvim.fn.line ".") (nvim.fn.col ".")])
(create-vim-fn :current-cursor)

(defn find-pair []
  (let [open (find.find-open)
        open-y (. open :y)
        open-x (. open :x)
        close (find.find-close)
        close-y (. close :y)
        close-x (. close :x)]
    [(when (and (<= 1 open-y) (<= 1 open-x))
       [open-y open-x])
     [(. close :y) (. close :x)]])) 
; (find-pair [])

(defn around-form [type]
  (let [[open close] (find-pair)]
    (when (and open close)
      (nvim.win_set_cursor 0 [(. open 1) (a.dec (. open 2))])
      (nvim.ex.normal! "v")
      (nvim.win_set_cursor 0 [(. close 1) (a.dec (. close 2))])))  
  nil)
(create-vim-fn :around-form)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn setup-buffer []
  (nvim.buf_set_keymap
    0 "o" "af" (string.format ":<c-u>call %s()<cr>" (->vim-fn-name :around-form))
    {:noremap true :silent false})
  (nvim.buf_set_keymap
    0 "x" "af" (string.format ":<c-u>call %s(visualmode())<cr>" (->vim-fn-name :around-form))
    {:noremap true :silent false})
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
