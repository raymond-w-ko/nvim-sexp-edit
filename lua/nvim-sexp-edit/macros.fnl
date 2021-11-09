(fn augroup [group-name ...]
  (let []
   `(do
     (nvim.ex.augroup ,group-name)
     (nvim.ex.autocmd!)
     (do ,...)
     (nvim.ex.augroup "END")))) 

(fn def-plug [plug-name config ...]
  (let [a (string.sub plug-name 1 1)
        b (-> (string.sub plug-name 2))
        vim-name (.. (string.upper a) b)]
    `[(defn ,(sym plug-name) ,...)
      (tset plugs ,vim-name ,plug-name)]))

(fn slice [tbl first last step]
  (var sliced [])
  (for [i (or first 1) (or last (length tbl) (or step 1))]
    (local idx (+ 1 (length sliced)))
    (tset sliced idx (. tbl i)))
  sliced)

(fn cond [...]
  (local clauses [...])
  `(if ,(. clauses 1)
     ,(. clauses 2)
     ,(if (= 0 (length clauses))
        nil
        (unpack (slice clauses 3)))))
  
{: augroup
 : def-plug
 : cond}
