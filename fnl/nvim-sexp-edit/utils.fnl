(module nvim-sexp-edit.utils
  {autoload {a aniseed.core
             nvim aniseed.nvim
             str aniseed.string}
   require-macros [nvim-sexp-edit.macros]})

(defn current-cursor []
  "(1,1)-indexed cursor"
  [(nvim.fn.line ".") (nvim.fn.col ".")])
