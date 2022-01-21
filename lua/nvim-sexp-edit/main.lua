local _2afile_2a = "fnl/nvim-sexp-edit/main.fnl"
local _2amodule_name_2a = "nvim-sexp-edit.main"
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
local a, find, nvim, seek, str, util, _ = autoload("nvim-sexp-edit.aniseed.core"), autoload("nvim-sexp-edit.find"), autoload("nvim-sexp-edit.aniseed.nvim"), autoload("nvim-sexp-edit.seek"), autoload("nvim-sexp-edit.aniseed.string"), autoload("nvim-sexp-edit.aniseed.nvim.util"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["find"] = find
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["seek"] = seek
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["util"] = util
_2amodule_locals_2a["_"] = _
local vim_fn_prefix = "Sexpedit_"
_2amodule_2a["vim-fn-prefix"] = vim_fn_prefix
local function __3evim_fn_name(fn_name)
  return string.gsub((vim_fn_prefix .. fn_name), "-", "_")
end
_2amodule_2a["->vim-fn-name"] = __3evim_fn_name
local function create_vim_fn(fn_name)
  local vim_fn_name = __3evim_fn_name(fn_name)
  return util["fn-bridge"](vim_fn_name, "nvim-sexp-edit.main", fn_name)
end
_2amodule_2a["create-vim-fn"] = create_vim_fn
local function gen_vim_ex_call(fn_name)
  return string.format("call %s()", __3evim_fn_name(fn_name))
end
_2amodule_2a["gen-vim-ex-call"] = gen_vim_ex_call
local function visually_select(f, _1_)
  local _arg_2_ = _1_
  local inside = _arg_2_["inside"]
  do
    local _let_3_ = nvim.get_mode()
    local mode = _let_3_["mode"]
    local _let_4_ = f()
    local begin = _let_4_[1]
    local _end = _let_4_[2]
    if (begin and _end) then
      if (mode == "v") then
        nvim.ex["normal!"]("v")
      else
      end
      do
        local x = a.dec(begin[2])
        local x0
        if inside then
          x0 = a.inc(x)
        else
          x0 = x
        end
        nvim.win_set_cursor(0, {begin[1], x0})
      end
      nvim.ex["normal!"]("v")
      local x = a.dec(_end[2])
      local x0
      if inside then
        x0 = a.dec(x)
      else
        x0 = x
      end
      nvim.win_set_cursor(0, {_end[1], x0})
    else
    end
  end
  return nil
end
_2amodule_2a["visually-select"] = visually_select
local function around_form()
  return visually_select(seek["current-form-boundaries"], {inside = false})
end
_2amodule_2a["around-form"] = around_form
local function in_form()
  return visually_select(seek["current-form-boundaries"], {inside = true})
end
_2amodule_2a["in-form"] = in_form
local function around_element()
  return visually_select(seek["current-element-boundaries"], {inside = false})
end
_2amodule_2a["around-element"] = around_element
local function in_element()
  return visually_select(seek["current-element-boundaries"], {inside = true})
end
_2amodule_2a["in-element"] = in_element
local function setup_buffer()
  vim.keymap.set({"o", "x"}, "af", around_form, {buffer = 0})
  vim.keymap.set({"o", "x"}, "if", in_form, {buffer = 0})
  vim.keymap.set({"o", "x"}, "ae", around_element, {buffer = 0})
  vim.keymap.set({"o", "x"}, "ie", in_element, {buffer = 0})
  vim.keymap.set({"o", "x"}, "as", around_element, {buffer = 0})
  vim.keymap.set({"o", "x"}, "is", in_element, {buffer = 0})
  nvim.buf_set_keymap(0, "i", "(", "()<c-g>U<Left>", {noremap = true, silent = true})
  nvim.buf_set_keymap(0, "i", "[", "[]<c-g>U<Left>", {noremap = true, silent = true})
  nvim.buf_set_keymap(0, "i", "{", "{}<c-g>U<Left>", {noremap = true, silent = true})
  nvim.buf_set_keymap(0, "i", "\"", "\"\"<c-g>U<Left>", {noremap = true, silent = true})
  return nil
end
_2amodule_2a["setup-buffer"] = setup_buffer
create_vim_fn("setup-buffer")
local function create_augroup()
  do
    nvim.ex.augroup("sexp-edit")
    nvim.ex["autocmd!"]()
    do
      nvim.ex.autocmd("FileType", "clojure,fennel", gen_vim_ex_call("setup-buffer"))
    end
    nvim.ex.augroup("END")
  end
  return nil
end
_2amodule_2a["create-augroup"] = create_augroup
local function init()
  return create_augroup()
end
_2amodule_2a["init"] = init
return init()