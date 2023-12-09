
local api = vim.api
local fn = vim.fn
local hlgroup = 'LocalHighlight'

local M = {
  regexes = {},
  whole_file = true,
  exclude_current_word = false,
}

local usage_namespace = api.nvim_create_namespace('highlight_usages_in_window')

local function all_matches(bufnr, regex, line)
  local ans = {}
  local offset = 0
  while true do
    local s, e = regex:match_line(bufnr, line, offset)
    if not s then
      return ans
    end
    table.insert(ans, s + offset)
    offset = offset + e
  end
end

function M.regex(pattern)
  local ret = M.regexes[pattern]
  if ret ~= nil then
    return ret
  end
  ret = vim.regex(pattern)
  if #M.regexes > 1000 then
    table.remove(M.regexes, 1)
    table.insert(M.regexes, ret)
  end

  return ret
end

function M.get_line_limits()
  if M.whole_file then
    return 0, fn.line('$')
  else
    return vim.fn.line('w0') - 1, vim.fn.line('w$')
  end
end

function M.highlight_usages(bufnr)
  local cursor = api.nvim_win_get_cursor(0)
  local line = vim.fn.getline('.')
  if string.sub(line, cursor[2] + 1, cursor[2] + 1) == ' ' then
    M.clear_usage_highlights(bufnr)
    return
  end
  local curword, _, _ = unpack(vim.fn.matchstrpos(line, [[\k*\%]] .. cursor[2] + 1 .. [[c\k*]]))
  if not curword or #curword == 0 then
    M.clear_usage_highlights(bufnr)
    return
  end
  local topline, botline = M.get_line_limits()

  M.clear_usage_highlights(bufnr)

  -- dumb find all matches of the word
  -- matching whole word ('\<' and '\>')
  local cursor_range = { cursor[1] - 1, cursor[2] }
  local curpattern = string.format([[\V\<%s\>]], curword)
  local curpattern_len = #curword
  local status, regex = pcall(M.regex, curpattern)
  if not status then
    return
  end

  local args = {}
  for row = topline, botline - 1 do
    local matches = all_matches(bufnr, regex, row)
    for _, col in ipairs(matches) do
      if not M.exclude_current_word or row ~= cursor_range[1] or cursor_range[2] < col or cursor_range[2] > col + curpattern_len then
        table.insert(args, {
          bufnr,
          usage_namespace,
          hlgroup,
          { row, col },
          { row, col + curpattern_len },
        })
      end
    end
  end

  for _, arg in ipairs(args) do
    vim.highlight.range(unpack(arg))
  end
end

function M.clear_usage_highlights(bufnr)
  api.nvim_buf_clear_namespace(bufnr, usage_namespace, 0, -1)
end

function M.setup()
  vim.api.nvim_set_hl(0, hlgroup, {
    fg = '#dcd7ba',
    bg = '#2d4f67',
    default = true,
  })
end

return M
