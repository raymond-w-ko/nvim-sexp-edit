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
  return visually_select(seek["current-element-boundaries"], {inside = false})
end
_2amodule_2a["in-element"] = in_element
local function add_char(y, x, ch)
  local lines = nvim.buf_get_lines(0, a.dec(y), y, true)
  local line = lines[1]
  local line0 = (line:sub(1, x) .. ch .. line:sub(a.inc(x)))
  return nvim.buf_set_lines(0, a.dec(y), y, true, {line0})
end
_2amodule_2a["add-char"] = add_char
local function form_wrap(begin_ch, end_ch)
  local _let_9_ = seek["current-form-boundaries"]()
  local begin = _let_9_[1]
  local _end = _let_9_[2]
  do
    local _let_10_ = _end
    local y = _let_10_[1]
    local x = _let_10_[2]
    add_char(y, x, end_ch)
  end
  do
    local _let_11_ = begin
    local y = _let_11_[1]
    local x = _let_11_[2]
    add_char(y, a.dec(x), begin_ch)
  end
  return {begin, _end}
end
_2amodule_2a["form-wrap"] = form_wrap
local function elem_wrap(begin_ch, end_ch)
  local _let_12_ = seek["current-element-boundaries"]()
  local begin = _let_12_[1]
  local _end = _let_12_[2]
  do
    local _let_13_ = _end
    local y = _let_13_[1]
    local x = _let_13_[2]
    add_char(y, x, end_ch)
  end
  do
    local _let_14_ = begin
    local y = _let_14_[1]
    local x = _let_14_[2]
    add_char(y, a.dec(x), begin_ch)
  end
  return {begin, _end}
end
_2amodule_2a["elem-wrap"] = elem_wrap
local function paren_wrap_list()
  return form_wrap("( ", ")")
end
_2amodule_2a["paren-wrap-list"] = paren_wrap_list
local function brace_wrap_list()
  return form_wrap("[ ", "]")
end
_2amodule_2a["brace-wrap-list"] = brace_wrap_list
local function curly_wrap_list()
  return form_wrap("{ ", "}")
end
_2amodule_2a["curly-wrap-list"] = curly_wrap_list
local function paren_wrap_elem()
  return elem_wrap("( ", ")")
end
_2amodule_2a["paren-wrap-elem"] = paren_wrap_elem
local function brace_wrap_elem()
  return elem_wrap("[ ", "]")
end
_2amodule_2a["brace-wrap-elem"] = brace_wrap_elem
local function curly_wrap_elem()
  return elem_wrap("{ ", "}")
end
_2amodule_2a["curly-wrap-elem"] = curly_wrap_elem
local function jump_to_head(boundary)
  local _let_15_ = boundary
  local begin = _let_15_[1]
  local _0 = _let_15_[2]
  local _let_16_ = begin
  local y = _let_16_[1]
  local x = _let_16_[2]
  nvim.win_set_cursor(0, {y, x})
  return nvim.ex.startinsert()
end
_2amodule_2a["jump-to-head"] = jump_to_head
local function jump_to_tail(boundary)
  local _let_17_ = boundary
  local _0 = _let_17_[1]
  local _end = _let_17_[2]
  local _let_18_ = _end
  local y = _let_18_[1]
  local x = _let_18_[2]
  local x0 = a.inc(x)
  nvim.win_set_cursor(0, {y, x0})
  return nvim.ex.startinsert()
end
_2amodule_2a["jump-to-tail"] = jump_to_tail
local function paren_head_wrap_list()
  return jump_to_head(paren_wrap_list())
end
_2amodule_2a["paren-head-wrap-list"] = paren_head_wrap_list
local function paren_tail_wrap_list()
  return jump_to_tail(paren_wrap_list())
end
_2amodule_2a["paren-tail-wrap-list"] = paren_tail_wrap_list
local function brace_head_wrap_list()
  return jump_to_head(brace_wrap_list())
end
_2amodule_2a["brace-head-wrap-list"] = brace_head_wrap_list
local function brace_tail_wrap_list()
  return jump_to_tail(brace_wrap_list())
end
_2amodule_2a["brace-tail-wrap-list"] = brace_tail_wrap_list
local function curly_head_wrap_list()
  return jump_to_head(curly_wrap_list())
end
_2amodule_2a["curly-head-wrap-list"] = curly_head_wrap_list
local function curly_tail_wrap_list()
  return jump_to_tail(curly_wrap_list())
end
_2amodule_2a["curly-tail-wrap-list"] = curly_tail_wrap_list
local function paren_head_wrap_elem()
  return jump_to_head(paren_wrap_elem())
end
_2amodule_2a["paren-head-wrap-elem"] = paren_head_wrap_elem
local function paren_tail_wrap_elem()
  return jump_to_tail(paren_wrap_elem())
end
_2amodule_2a["paren-tail-wrap-elem"] = paren_tail_wrap_elem
local function brace_head_wrap_elem()
  return jump_to_head(brace_wrap_elem())
end
_2amodule_2a["brace-head-wrap-elem"] = brace_head_wrap_elem
local function brace_tail_wrap_elem()
  return jump_to_tail(brace_wrap_elem())
end
_2amodule_2a["brace-tail-wrap-elem"] = brace_tail_wrap_elem
local function curly_head_wrap_elem()
  return jump_to_head(curly_wrap_elem())
end
_2amodule_2a["curly-head-wrap-elem"] = curly_head_wrap_elem
local function curly_tail_wrap_elem()
  return jump_to_tail(curly_wrap_elem())
end
_2amodule_2a["curly-tail-wrap-elem"] = curly_tail_wrap_elem
local function setup_buffer()
  vim.keymap.set({"o", "x"}, "af", around_form, {buffer = 0})
  vim.keymap.set({"o", "x"}, "if", in_form, {buffer = 0})
  vim.keymap.set({"o", "x"}, "ae", around_element, {buffer = 0})
  vim.keymap.set({"o", "x"}, "ie", in_element, {buffer = 0})
  vim.keymap.set({"o", "x"}, "as", around_element, {buffer = 0})
  vim.keymap.set({"o", "x"}, "is", in_element, {buffer = 0})
  do
    local map
    local function _19_(lhs, rhs)
      return vim.keymap.set("n", lhs, rhs, {buffer = 0})
    end
    map = _19_
    map("<localleader>i", paren_head_wrap_list)
    map("<localleader>I", paren_tail_wrap_list)
    map("<localleader>[", brace_head_wrap_list)
    map("<localleader>]", brace_tail_wrap_list)
    map("<localleader>{", curly_head_wrap_list)
    map("<localleader>}", curly_tail_wrap_list)
    map("<localleader>W", paren_head_wrap_elem)
    map("<localleader>w", paren_tail_wrap_elem)
    map("<localleader>e[", brace_head_wrap_elem)
    map("<localleader>e]", brace_tail_wrap_elem)
    map("<localleader>e{", curly_head_wrap_elem)
    map("<localleader>e}", curly_tail_wrap_elem)
  end
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
init()
return _2amodule_2a