local config = require('postvim.config')
local utils = require('postvim.utils')

local M = {}

-- Cache for request buffers (URL -> buffer number)
M.request_buffers = {}

-- Create or reuse buffer for a URL
function M.get_or_create_buffer(url)
  -- Check if buffer exists for this URL
  if M.request_buffers[url] then
    local buf = M.request_buffers[url]
    if vim.api.nvim_buf_is_valid(buf) then
      return buf
    end
  end
  
  -- Create new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_name(buf, string.format("PostVim: %s", url))
  
  M.request_buffers[url] = buf
  return buf
end

-- Open buffer in split/tab according to config
function M.open_buffer(buf)
  local opts = config.get()
  local direction = opts.split_direction
  
  -- Check if buffer is already visible in a window
  local win = vim.fn.bufwinid(buf)
  if win ~= -1 then
    vim.api.nvim_set_current_win(win)
    return win
  end
  
  -- Create new window based on direction
  if direction == 'vertical' then
    vim.cmd('vsplit')
  elseif direction == 'horizontal' then
    vim.cmd('split')
  elseif direction == 'tab' then
    vim.cmd('tabnew')
  else
    vim.cmd('vsplit') -- Default to vertical
  end
  
  -- Set buffer in new window
  vim.api.nvim_win_set_buf(0, buf)
  
  return vim.api.nvim_get_current_win()
end

-- Format and display response in buffer
function M.display_response(url, response_data)
  local buf = M.get_or_create_buffer(url)
  M.open_buffer(buf)
  
  local lines = {}
  local opts = config.get()
  
  -- Add status line
  if opts.show_status_code and response_data.status_code then
    local status_line = string.format("HTTP/1.1 %d %s", 
      response_data.status_code, 
      utils.get_status_description(response_data.status_code))
    table.insert(lines, status_line)
  end
  
  -- Add response headers
  if opts.show_headers and response_data.headers then
    for _, header in ipairs(response_data.headers) do
      table.insert(lines, header)
    end
  end
  
  -- Add separator
  if opts.show_status_code or opts.show_headers then
    table.insert(lines, "")
  end
  
  -- Add metadata (response time, size, etc.)
  local metadata = {}
  if opts.show_response_time and response_data.response_time then
    table.insert(metadata, string.format("Response Time: %s", utils.format_time(response_data.response_time)))
  end
  
  if response_data.content_length then
    table.insert(metadata, string.format("Content Length: %s", utils.format_bytes(response_data.content_length)))
  end
  
  if #metadata > 0 then
    for _, line in ipairs(metadata) do
      table.insert(lines, line)
    end
    table.insert(lines, "")
    table.insert(lines, string.rep("-", 50))
    table.insert(lines, "")
  end
  
  -- Add response body
  if response_data.body then
    local body_lines = vim.split(response_data.body, '\n', { plain = true })
    for _, line in ipairs(body_lines) do
      table.insert(lines, line)
    end
  end
  
  -- Set buffer content
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'modified', false)
  
  -- Set filetype based on content type
  local filetype = 'json' -- Default
  if response_data.content_type then
    if response_data.content_type:match('application/json') then
      filetype = 'json'
    elseif response_data.content_type:match('text/html') then
      filetype = 'html'
    elseif response_data.content_type:match('text/xml') or response_data.content_type:match('application/xml') then
      filetype = 'xml'
    elseif response_data.content_type:match('text/plain') then
      filetype = 'text'
    end
  end
  
  vim.api.nvim_buf_set_option(buf, 'filetype', filetype)
  
  -- Show status in echo area with color
  if response_data.status_code then
    local color = utils.get_status_color(response_data.status_code)
    local message = string.format("Request completed: %d %s", 
      response_data.status_code, 
      utils.get_status_description(response_data.status_code))
    
    if response_data.response_time then
      message = message .. string.format(" (%s)", utils.format_time(response_data.response_time))
    end
    
    vim.api.nvim_echo({{string.format("[PostVim] %s", message), color}}, true, {})
  end
  
  return buf
end

-- Display error in buffer
function M.display_error(url, error_message)
  local buf = M.get_or_create_buffer(url)
  M.open_buffer(buf)
  
  local lines = {
    "ERROR",
    "",
    string.rep("-", 50),
    "",
    error_message,
    "",
    string.rep("-", 50),
  }
  
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'modified', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'text')
  
  utils.error(error_message)
  
  return buf
end

-- Clear all request buffers
function M.clear_buffers()
  for url, buf in pairs(M.request_buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  M.request_buffers = {}
  utils.info("All response buffers cleared")
end

return M
