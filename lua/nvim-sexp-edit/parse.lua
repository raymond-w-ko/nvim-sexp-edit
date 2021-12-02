local _2afile_2a = "fnl/nvim-sexp-edit/parse.fnl"
local _2amodule_name_2a = "nvim-sexp-edit.parse"
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
local a, nvim, str, utils, _ = autoload("nvim-sexp-edit.aniseed.core"), autoload("nvim-sexp-edit.aniseed.nvim"), autoload("nvim-sexp-edit.aniseed.string"), autoload("nvim-sexp-edit.utils"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["utils"] = utils
_2amodule_locals_2a["_"] = _
local complement_chars = {["("] = ")", ["{"] = "}", ["["] = "]", [")"] = "(", ["}"] = "{", ["]"] = "["}
_2amodule_2a["complement-chars"] = complement_chars
local close_chars = {[")"] = true, ["}"] = true, ["]"] = true}
_2amodule_2a["close-chars"] = close_chars
local whitespace_chars = {[" "] = true, ["\9"] = true, ["\13"] = true, ["\11"] = true}
_2amodule_2a["whitespace-chars"] = whitespace_chars
local function new_state()
  local _let_1_ = utils["current-cursor"]()
  local y = _let_1_[1]
  local x = _let_1_[2]
  return {lines = {}, ["num-lines"] = nvim.buf_line_count(0), y = y, x = x}
end
_2amodule_2a["new-state"] = new_state
local function load_line(state)
  local _let_2_ = state
  local lines = _let_2_["lines"]
  local y = _let_2_["y"]
  if (not lines[y] and (0 < y)) then
    local lines0 = nvim.buf_get_lines(0, a.dec(y), y, true)
    local line = (lines0)[1]
    state["lines"][y] = line
  else
  end
  return state
end
local function get_line(state)
  load_line(state)
  local _let_4_ = state
  local lines = _let_4_["lines"]
  local y = _let_4_["y"]
  local line = lines[y]
  assert(line, ("no line loaded at index" .. y))
  return line
end
local function get_char(state)
  local _let_5_ = state
  local x = _let_5_["x"]
  local line = get_line(state)
  return string.sub(line, x, x)
end
local function backwards(state)
  local _let_6_ = state
  local y = _let_6_["y"]
  local x = _let_6_["x"]
  local y0 = y
  local x0 = x
  x0 = a.dec(x0)
  if (x0 <= 0) then
    y0 = a.dec(y0)
    do end (state)["y"] = y0
    if (0 < y0) then
      load_line(state)
      do end (state)["x"] = #get_line(state)
    else
    end
    return state
  else
    state["x"] = x0
    return state
  end
end
local function forwards(state)
  local _let_9_ = state
  local y = _let_9_["y"]
  local x = _let_9_["x"]
  local y0 = y
  local x0 = x
  local n = #get_line(state)
  x0 = a.inc(x0)
  if (x0 > n) then
    state["x"] = 1
    y0 = a.inc(y0)
    do end (state)["y"] = y0
    return state
  else
    state["x"] = x0
    return state
  end
end
local function is_root_form_begin_line_3f(state)
  local line = get_line(state)
  return ("(" == string.sub(line, 1, 1))
end
_2amodule_2a["is-root-form-begin-line?"] = is_root_form_begin_line_3f
local function is_whitespace_char_3f(ch)
  return whitespace_chars[ch]
end
_2amodule_2a["is-whitespace-char?"] = is_whitespace_char_3f
local function print_state(state)
  return print(state.y, state.x)
end
local function parse_root_form()
  local state = new_state()
  while ((0 < state.y) and not is_root_form_begin_line_3f(state)) do
    a.update(state, "y", a.dec)
  end
  state["x"] = 1
  local nodes = {}
  local dispatch = {}
  local function read_element()
    local _let_11_ = state
    local y = _let_11_["y"]
    local x = _let_11_["x"]
    local node = {begin = {y, x}, type = "element"}
    table.insert(nodes, node)
    local done = false
    while not done do
      forwards(state)
      local ch = get_char(state)
      local f = dispatch[ch]
      if (f or is_whitespace_char_3f(ch) or close_chars[ch]) then
        backwards(state)
        do end (node)["end"] = {state.y, state.x}
        done = true
      else
      end
    end
    return nil
  end
  local function read_string()
    local _let_13_ = state
    local y = _let_13_["y"]
    local x = _let_13_["x"]
    local node = {begin = {y, x}, type = "element", subtype = "string", ["open-char"] = "\"", ["close-char"] = "\""}
    table.insert(nodes, node)
    local done = false
    while not done do
      forwards(state)
      local ch = get_char(state)
      if (ch == "\\") then
        forwards(state)
        forwards(state)
      else
      end
      if (ch == "\"") then
        node["end"] = {state.y, state.x}
        forwards(state)
        done = true
      else
      end
    end
    return nil
  end
  local function read_form()
    local _let_16_ = state
    local y = _let_16_["y"]
    local x = _let_16_["x"]
    local open_char = get_char(state)
    local close_char = complement_chars[open_char]
    local node = {begin = {y, x}, type = "form", ["open-char"] = open_char, ["close-char"] = close_char}
    table.insert(nodes, node)
    local done = false
    while not done do
      forwards(state)
      local ch = get_char(state)
      local f = dispatch[ch]
      if (ch == close_char) then
        node["end"] = {state.y, state.x}
        done = true
      elseif f then
        f()
      elseif not is_whitespace_char_3f(ch) then
        read_element()
      else
      end
    end
    return nil
  end
  dispatch["("] = read_form
  dispatch["{"] = read_form
  dispatch["["] = read_form
  dispatch["\""] = read_string
  do
    local ch = get_char(state)
    dispatch[ch]()
  end
  print(nodes)
  return nodes
end
_2amodule_2a["parse-root-form"] = parse_root_form
--[[ "str\"ing" (parse-root-form) ]]--
return nil