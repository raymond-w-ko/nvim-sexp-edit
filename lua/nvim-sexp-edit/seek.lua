local _2afile_2a = "fnl/nvim-sexp-edit/seek.fnl"
local _2amodule_name_2a = "nvim-sexp-edit.seek"
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
local a, nvim, parse, str, utils, _ = autoload("nvim-sexp-edit.aniseed.core"), autoload("nvim-sexp-edit.aniseed.nvim"), autoload("nvim-sexp-edit.parse"), autoload("nvim-sexp-edit.aniseed.string"), autoload("nvim-sexp-edit.utils"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["parse"] = parse
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["utils"] = utils
_2amodule_locals_2a["_"] = _
local function seek_current_form()
  local nodes
  local function _3_(_1_)
    local _arg_2_ = _1_
    local type = _arg_2_["type"]
    return (type == "form")
  end
  nodes = a.filter(_3_, parse["parse-root-form"]())
  local _let_4_ = utils["current-cursor"]()
  local y = _let_4_[1]
  local x = _let_4_[2]
  local done = false
  local candidate = nil
  for i, node in ipairs(nodes) do
    if done then break end
    local _let_5_ = node
    local begin = _let_5_["begin"]
    local _end = _let_5_["end"]
    if ((begin[1] <= y) and (begin[2] <= x)) then
      candidate = node
    else
      done = true
    end
  end
  return candidate
end
_2amodule_2a["seek-current-form"] = seek_current_form
local function seek_current_form_boundaries()
  local _let_7_ = seek_current_form()
  local begin = _let_7_["begin"]
  local _end = _let_7_["end"]
  return {begin, _end}
end
_2amodule_2a["seek-current-form-boundaries"] = seek_current_form_boundaries