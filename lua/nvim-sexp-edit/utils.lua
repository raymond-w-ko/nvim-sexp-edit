local _2afile_2a = "fnl/nvim-sexp-edit/utils.fnl"
local _2amodule_name_2a = "nvim-sexp-edit.utils"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("nvim-sexp-edit.aniseed.autoload")).autoload
local a, nvim, str, _ = autoload("nvim-sexp-edit.aniseed.core"), autoload("nvim-sexp-edit.aniseed.nvim"), autoload("nvim-sexp-edit.aniseed.string"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["_"] = _
local function current_cursor()
  return {nvim.fn.line("."), nvim.fn.col(".")}
end
_2amodule_2a["current-cursor"] = current_cursor