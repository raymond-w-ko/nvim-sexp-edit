(module nvim-sexp-edit.seek
  {autoload {a aniseed.core
             nvim aniseed.nvim
             str aniseed.string
             utils nvim-sexp-edit.utils
             parse nvim-sexp-edit.parse}
   require-macros [nvim-sexp-edit.macros]})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn current-node-of-type [target-type]
  (let [nodes (->> (parse.parse-root-form)
                   (a.filter (fn [{: type}] (= type target-type))))
        [y x] (utils.current-cursor)]

    (var done false)
    (var candidate nil)
    (each [i node (ipairs nodes) :until done]
      (let [{: begin : end} node]
        (if (or (< (. begin 1) y)
                (and (= (. begin 1) y) (<= (. begin 2) x)))
          (set candidate node)
          (set done true))))
    (nvim.print candidate)
    candidate))

(defn current-form-boundaries []
  (let [{: begin : end} (current-node-of-type :form)]
    [begin end]))

(defn current-element-boundaries []
  (let [{: begin : end} (current-node-of-type :element)]
    [begin end]))
