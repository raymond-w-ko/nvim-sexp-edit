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
        (when (and (or (< (. begin 1) y)
                       (and (= (. begin 1) y) (<= (. begin 2) x)))
                   (or (> (. end 1) y)
                       (and (= (. end 1) y) (>= (. end 2) x)))) 
          (set candidate node))
        (when (> (. begin 1) y)
          (set done true))))
    ; (nvim.print nodes)
    ; (nvim.print candidate)
    candidate))

(defn current-form-boundaries []
  (let [{: begin : end : subtype} (current-node-of-type :form)]
    [begin end :form subtype]))

(defn current-element-boundaries []
  (let [{: begin : end : subtype} (current-node-of-type :element)]
    [begin end :element subtype]))
