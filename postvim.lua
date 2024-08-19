local M = {}

local request_buffers = {}

local function split_output(url)
  if request_buffers[url] then
    local buf = request_buffers[url]
    local win = vim.fn.bufwinid(buf)
    if win ~= -1 then
      vim.api.nvim_set_current_win(win)
      return buf
    end
  end

  vim.cmd('vsplit')
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  request_buffers[url] = buf
  return buf
end

local function execute_request(method, headers, url, body)
  local command = string.format("curl -s -X %s", method)

  if headers then
    for _, header_table in ipairs(headers) do
      for key, value in pairs(header_table) do
        command = command .. string.format(" -H '%s: %s'", key, value)
      end
    end
  end

  command = command .. string.format(" '%s'", url)

  if body then
    command = command .. string.format(" -d '%s'", body)
  end

  command = command .. " | jq ."

  local output = vim.fn.system(command)
  return output
end

local function parse_json_content(json_content)
  local ok, requests = pcall(vim.fn.json_decode, json_content)
  if not ok then
    print("Failed to decode JSON: ", requests)
    return {}
  end
  return requests
end

function M.execute()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local json_content = table.concat(lines, "\n")
  local requests = parse_json_content(json_content)

  if #requests == 0 then
    print("No valid requests found.")
    return
  end

  for _, request in ipairs(requests) do
    local output = execute_request(request.method, request.headers, request.url, request.body)
    local output_buf = split_output(request.url)
    vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, vim.split(output, '\n'))
    vim.cmd('set filetype=json')
  end
end

return M

