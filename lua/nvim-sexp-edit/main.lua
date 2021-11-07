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
local a, nvim, str, util, _ = autoload("nvim-sexp-edit.aniseed.core"), autoload("nvim-sexp-edit.aniseed.nvim"), autoload("nvim-sexp-edit.aniseed.string"), autoload("nvim-sexp-edit.aniseed.nvim.util"), nil
_2amodule_locals_2a["a"] = a
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
local function current_cursor()
  return {nvim.fn.line("."), nvim.fn.col(".")}
end
_2amodule_2a["current-cursor"] = current_cursor
create_vim_fn("current-cursor")
local function find_pair_begin(line, start_x)
  local x = -1
  for i = start_x, 0, -1 do
    if (0 < x) then break end
    local ch = string.sub(line, i, i)
    if ((ch == "(") or (ch == "{") or (ch == "[")) then
      x = i
    else
    end
  end
  return x
end
_2amodule_2a["find-pair-begin"] = find_pair_begin
local function find_pair(_2_)
  local _arg_3_ = _2_
  local y = _arg_3_[1]
  local x = _arg_3_[2]
  local y0 = y
  local x0 = x
  local end_y = -1
  local end_x = -1
  local begin_y = -1
  local begin_x = -1
  local done = false
  local reset_begin_x = false
  while ((0 < y0) and not done) do
    local line = (nvim.buf_get_lines(0, a.dec(y0), y0, true))[1]
    if reset_begin_x then
      begin_x = string.len(line)
    else
    end
    begin_x = find_pair_begin(line, x0)
    if (0 < begin_x) then
      done = true
      begin_y = y0
    else
      done = false
      reset_begin_x = true
      y0 = a.dec(y0)
    end
  end
  return {{begin_y, begin_x}}
end
_2amodule_2a["find-pair"] = find_pair
find_pair(current_cursor())
local function around_form(type)
  do
    local cursor = current_cursor()
    find_pair(cursor)
  end
  nvim.win_set_cursor(0, {nvim.fn.line("."), 3})
  nvim.ex["normal!"]("v")
  nvim.win_set_cursor(0, {nvim.fn.line("."), 7})
  return 1
end
_2amodule_2a["around-form"] = around_form
create_vim_fn("around-form")
local function setup_buffer()
  nvim.buf_set_keymap(0, "o", "af", string.format(":<c-u>call %s()<cr>", __3evim_fn_name("around-form")), {noremap = true, silent = false})
  nvim.buf_set_keymap(0, "x", "af", string.format(":<c-u>call %s(visualmode())<cr>", __3evim_fn_name("around-form")), {noremap = true, silent = false})
  return nil
end
_2amodule_2a["setup-buffer"] = setup_buffer
create_vim_fn("setup-buffer")
local function create_augroup()
  nvim.ex.augroup("sexp-edit")
  nvim.ex["autocmd!"]()
  do
    nvim.ex.autocmd("FileType", "clojure,fennel", gen_vim_ex_call("setup-buffer"))
  end
  return nvim.ex.augroup("END")
end
_2amodule_2a["create-augroup"] = create_augroup
local function init()
  return create_augroup()
end
_2amodule_2a["init"] = init
return init()