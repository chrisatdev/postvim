local M = {}

-- Check if a command exists in system
function M.command_exists(cmd)
  local handle = io.popen(string.format("command -v %s 2>/dev/null", cmd))
  if not handle then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

-- Validate that required dependencies are installed
function M.check_dependencies()
  local missing = {}
  
  if not M.command_exists("curl") then
    table.insert(missing, "curl")
  end
  
  if not M.command_exists("jq") then
    table.insert(missing, "jq")
  end
  
  return missing
end

-- Show error notification
function M.error(message)
  vim.api.nvim_err_writeln("[PostVim] Error: " .. message)
end

-- Show warning notification
function M.warn(message)
  vim.api.nvim_echo({{string.format("[PostVim] Warning: %s", message), "WarningMsg"}}, true, {})
end

-- Show info notification
function M.info(message)
  vim.api.nvim_echo({{string.format("[PostVim] %s", message), "Normal"}}, true, {})
end

-- Show success notification
function M.success(message)
  vim.api.nvim_echo({{string.format("[PostVim] ✓ %s", message), "MoreMsg"}}, true, {})
end

-- Escape string for shell command
function M.escape_for_shell(str)
  if not str then return "" end
  -- Replace single quotes with '\'' (end quote, escaped quote, start quote)
  return str:gsub("'", "'\\''")
end

-- Trim whitespace from string
function M.trim(s)
  if not s then return "" end
  return s:match("^%s*(.-)%s*$")
end

-- Split string by delimiter
function M.split(str, delimiter)
  local result = {}
  local pattern = string.format("([^%s]+)", delimiter)
  for match in str:gmatch(pattern) do
    table.insert(result, match)
  end
  return result
end

-- Check if string starts with prefix
function M.starts_with(str, prefix)
  return str:sub(1, #prefix) == prefix
end

-- Check if string ends with suffix
function M.ends_with(str, suffix)
  return suffix == "" or str:sub(-#suffix) == suffix
end

-- Get file extension
function M.get_extension(filepath)
  return filepath:match("^.+%.(.+)$")
end

-- Check if current buffer is empty
function M.is_buffer_empty(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr or 0, 0, -1, false)
  if #lines == 0 then return true end
  if #lines == 1 and M.trim(lines[1]) == "" then return true end
  return false
end

-- Get current line number
function M.get_current_line()
  return vim.api.nvim_win_get_cursor(0)[1]
end

-- Format time in milliseconds to human readable
function M.format_time(ms)
  if ms < 1000 then
    return string.format("%dms", ms)
  elseif ms < 60000 then
    return string.format("%.2fs", ms / 1000)
  else
    local minutes = math.floor(ms / 60000)
    local seconds = (ms % 60000) / 1000
    return string.format("%dm %.2fs", minutes, seconds)
  end
end

-- Format bytes to human readable
function M.format_bytes(bytes)
  if bytes < 1024 then
    return string.format("%d B", bytes)
  elseif bytes < 1024 * 1024 then
    return string.format("%.2f KB", bytes / 1024)
  elseif bytes < 1024 * 1024 * 1024 then
    return string.format("%.2f MB", bytes / (1024 * 1024))
  else
    return string.format("%.2f GB", bytes / (1024 * 1024 * 1024))
  end
end

-- Parse HTTP status code and get description
function M.get_status_description(code)
  local status_codes = {
    -- 2xx Success
    [200] = "OK",
    [201] = "Created",
    [202] = "Accepted",
    [204] = "No Content",
    
    -- 3xx Redirection
    [301] = "Moved Permanently",
    [302] = "Found",
    [304] = "Not Modified",
    
    -- 4xx Client Error
    [400] = "Bad Request",
    [401] = "Unauthorized",
    [403] = "Forbidden",
    [404] = "Not Found",
    [405] = "Method Not Allowed",
    [409] = "Conflict",
    [422] = "Unprocessable Entity",
    [429] = "Too Many Requests",
    
    -- 5xx Server Error
    [500] = "Internal Server Error",
    [502] = "Bad Gateway",
    [503] = "Service Unavailable",
    [504] = "Gateway Timeout",
  }
  
  return status_codes[code] or "Unknown"
end

-- Get color for status code
function M.get_status_color(code)
  if code >= 200 and code < 300 then
    return "MoreMsg" -- Green
  elseif code >= 300 and code < 400 then
    return "WarningMsg" -- Yellow
  elseif code >= 400 and code < 500 then
    return "ErrorMsg" -- Red
  elseif code >= 500 then
    return "ErrorMsg" -- Red
  else
    return "Normal"
  end
end

return M
