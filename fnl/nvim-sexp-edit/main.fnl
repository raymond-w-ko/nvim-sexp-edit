(module nvim-sexp-edit.main
  {autoload {a aniseed.core
             nvim aniseed.nvim
             str aniseed.string
             util aniseed.nvim.util}
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

(defn find-pair-begin [line start-x]
  (var x -1)
  (for [i start-x 0 -1 :until (< 0 x)]
    (let [ch (string.sub line i i)]
      (when (or (= ch "(") ;; )
                (= ch "{") ;; }
                (= ch "[") ;; ]
                )
        (set x i))))
  x)

(defn find-pair-end [line start-x]
  )

(defn find-pair [[cursor-y cursor-x]]
  (var y cursor-y)
  (var x cursor-x)
  
  (var begin-y -1)
  (var begin-x -1)
  (var done false)
  (var reset-begin-x false)
  (while (and (< 0 y) (not done))
    (local line (-> (nvim.buf_get_lines 0 (a.dec y) y true)
                    (. 1)))
    (when reset-begin-x
      (set begin-x (string.len line)))
    (set begin-x (find-pair-begin line x))
    (if (< 0 begin-x)
      (do
        (set done true)
        (set begin-y y))
      (do
        (set done false)
        (set reset-begin-x true)
        (set y (a.dec y)))))
  
  (var end-y -1)
  (var end-x -1)
  
  [[begin-y begin-x] [end-y end-x]])
(find-pair (current-cursor))

(defn around-form [type]
  (let [cursor (current-cursor)]
    (find-pair cursor))
  ; (nvim.buf_set_mark (vim.fn.bufnr) "<" (nvim.fn.line ".") 2 {})
  ; (nvim.buf_set_mark (vim.fn.bufnr) ">" (nvim.fn.line ".") 5 {})
  (nvim.win_set_cursor 0 [(nvim.fn.line ".") 3])
  (nvim.ex.normal! "v")
  (nvim.win_set_cursor 0 [(nvim.fn.line ".") 7])
  1)
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
   (nvim.ex.autocmd "FileType" "clojure,fennel" (gen-vim-ex-call :setup-buffer))))
                     

(defn init []
  (create-augroup))
(init)
