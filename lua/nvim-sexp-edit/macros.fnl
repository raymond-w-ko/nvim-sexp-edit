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

{:augroup augroup
 :def-plug def-plug}
