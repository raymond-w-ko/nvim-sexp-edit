local _2afile_2a = "fnl/nvim-sexp-edit/find.fnl"
local _2amodule_name_2a = "nvim-sexp-edit.find"
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
local watchdog_limit = 50000
_2amodule_2a["watchdog-limit"] = watchdog_limit
local open_chars = {["("] = ")", ["{"] = "}", ["["] = "]"}
_2amodule_2a["open-chars"] = open_chars
local close_chars = {[")"] = "(", ["}"] = "{", ["]"] = "["}
_2amodule_2a["close-chars"] = close_chars
local function new_state(y, x)
  return {lines = {}, watchdog = 0, imbalance = 0, ["num-lines"] = nvim.buf_line_count(0), y = y, x = x}
end
local function verify_cursor(state)
  local _let_1_ = state
  local y = _let_1_["y"]
  local x = _let_1_["x"]
  local num_lines = _let_1_["num-lines"]
  if (y <= 0) then
    return nil
  elseif (y > num_lines) then
    return nil
  elseif true then
    return state
  else
    return nil
  end
end
local function print_state(state)
  return print(state.y, state.x, "imb", state.imbalance)
end
local function load_line(state)
  local _let_3_ = state
  local lines = _let_3_["lines"]
  local y = _let_3_["y"]
  if (not lines[y] and (0 < y)) then
    local lines0 = nvim.buf_get_lines(0, a.dec(y), y, true)
    local line = (lines0)[1]
    state["lines"][y] = line
    return state
  else
    return state
  end
end
local function get_line(state)
  local _let_5_ = state
  local lines = _let_5_["lines"]
  local y = _let_5_["y"]
  local line = lines[y]
  assert(line, ("no line loaded at index" .. y))
  return line
end
local function get_char(state)
  load_line(state)
  local _let_6_ = state
  local lines = _let_6_["lines"]
  local y = _let_6_["y"]
  local x = _let_6_["x"]
  return string.sub(lines[y], x, x)
end
local function is_on_open_3f(state)
  local ch = get_char(state)
  return open_chars[ch]
end
_2amodule_2a["is-on-open?"] = is_on_open_3f
local function is_on_close_3f(state)
  local ch = get_char(state)
  return close_chars[ch]
end
_2amodule_2a["is-on-close?"] = is_on_close_3f
local function before_start_of_file_3f(state)
  return (0 > state.y)
end
_2amodule_2a["before-start-of-file?"] = before_start_of_file_3f
local function after_end_of_file_3f(state, n)
  local _let_7_ = state
  local num_lines = _let_7_["num-lines"]
  return (state.y > num_lines)
end
_2amodule_2a["after-end-of-file?"] = after_end_of_file_3f
local function backwards(state)
  local _let_8_ = state
  local y = _let_8_["y"]
  local x = _let_8_["x"]
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
  local _let_11_ = state
  local y = _let_11_["y"]
  local x = _let_11_["x"]
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
local function find_open(_13_)
  local _arg_14_ = _13_
  local inside = _arg_14_["inside"]
  local _let_15_ = utils["current-cursor"]()
  local y = _let_15_[1]
  local x = _let_15_[2]
  local state = new_state(y, x)
  local done = false
  if is_on_close_3f(state) then
    backwards(state)
  else
  end
  while (not done and not before_start_of_file_3f(state) and (state.watchdog < watchdog_limit)) do
    a.update(state, "watchdog", a.inc)
    if is_on_open_3f(state) then
      a.update(state, "imbalance", a.inc)
    elseif is_on_close_3f(state) then
      a.update(state, "imbalance", a.dec)
    else
    end
    if (0 < state.imbalance) then
      done = true
    else
      backwards(state)
    end
  end
  if inside then
    forwards(state)
  else
  end
  return verify_cursor(state)
end
_2amodule_2a["find-open"] = find_open
local function find_close(_20_)
  local _arg_21_ = _20_
  local inside = _arg_21_["inside"]
  local _let_22_ = utils["current-cursor"]()
  local y = _let_22_[1]
  local x = _let_22_[2]
  local state = new_state(y, x)
  local done = false
  if is_on_open_3f(state) then
    forwards(state)
  else
  end
  while (not done and not after_end_of_file_3f(state) and (state.watchdog < watchdog_limit)) do
    a.update(state, "watchdog", a.inc)
    if is_on_close_3f(state) then
      a.update(state, "imbalance", a.dec)
    elseif is_on_open_3f(state) then
      a.update(state, "imbalance", a.inc)
    else
    end
    if (state.imbalance < 0) then
      done = true
    else
      forwards(state)
    end
  end
  if inside then
    backwards(state)
  else
  end
  return verify_cursor(state)
end
_2amodule_2a["find-close"] = find_close
local function find_pair(args)
  local open = find_open(args)
  local open_y = open.y
  local open_x = open.x
  local close = find_close(args)
  local close_y = close.y
  local close_x = close.x
  local _27_
  if ((1 <= open_y) and (1 <= open_x)) then
    _27_ = {open_y, open_x}
  else
    _27_ = nil
  end
  return {_27_, {close.y, close.x}}
end
_2amodule_2a["find-pair"] = find_pair