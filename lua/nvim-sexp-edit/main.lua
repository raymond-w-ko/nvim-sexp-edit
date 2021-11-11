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
local a, find, nvim, str, util, _ = autoload("nvim-sexp-edit.aniseed.core"), autoload("nvim-sexp-edit.find"), autoload("nvim-sexp-edit.aniseed.nvim"), autoload("nvim-sexp-edit.aniseed.string"), autoload("nvim-sexp-edit.aniseed.nvim.util"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["find"] = find
_2amodule_locals_2a["nvim"] = nvim
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
local function form(args)
  do
    local _let_1_ = find["find-pair"](args)
    local open = _let_1_[1]
    local close = _let_1_[2]
    if (open and close) then
      nvim.win_set_cursor(0, {open[1], a.dec(open[2])})
      nvim.ex["normal!"]("v")
      nvim.win_set_cursor(0, {close[1], a.dec(close[2])})
    else
    end
  end
  return nil
end
_2amodule_2a["form"] = form
local function around_form(count, type)
  return form({inside = false, count = count, type = type})
end
_2amodule_2a["around-form"] = around_form
create_vim_fn("around-form")
local function in_form(count, type)
  return form({inside = true, count = count, type = type})
end
_2amodule_2a["in-form"] = in_form
create_vim_fn("in-form")
local function ox_map(rhs, fn_name)
  nvim.buf_set_keymap(0, "o", rhs, string.format(":<c-u>call %s(v:count, visualmode())<cr>", __3evim_fn_name(fn_name)), {noremap = true, silent = false})
  return nvim.buf_set_keymap(0, "x", rhs, string.format(":<c-u>call %s(v:count ,visualmode())<cr>", __3evim_fn_name(fn_name)), {noremap = true, silent = false})
end
local function setup_buffer()
  ox_map("af", "around-form")
  ox_map("if", "in-form")
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