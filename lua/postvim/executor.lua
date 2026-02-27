local config = require('postvim.config')
local utils = require('postvim.utils')

local M = {}

-- Build curl command from request data
local function build_curl_command(request)
  local opts = config.get()
  local parts = {}
  
  -- Base curl command with silent mode and include headers
  table.insert(parts, "curl -s -i")
  
  -- Add write-out for timing information
  table.insert(parts, "-w '\\n__POSTVIM_TIME__%{time_total}__'")
  
  -- Add method
  if request.method then
    table.insert(parts, string.format("-X %s", request.method))
  end
  
  -- Add headers
  if request.headers then
    for key, value in pairs(request.headers) do
      local escaped_value = utils.escape_for_shell(value)
      table.insert(parts, string.format("-H '%s: %s'", key, escaped_value))
    end
  end
  
  -- Add body/data
  if request.body then
    local escaped_body = utils.escape_for_shell(request.body)
    table.insert(parts, string.format("-d '%s'", escaped_body))
  end
  
  -- Add timeout
  if opts.timeout then
    local timeout_seconds = math.floor(opts.timeout / 1000)
    table.insert(parts, string.format("--max-time %d", timeout_seconds))
  end
  
  -- Add redirect follow option
  if opts.follow_redirects then
    table.insert(parts, "-L")
  end
  
  -- Add SSL verification option
  if not opts.verify_ssl then
    table.insert(parts, "-k")
  end
  
  -- Add URL (must be last)
  local escaped_url = utils.escape_for_shell(request.url)
  table.insert(parts, string.format("'%s'", escaped_url))
  
  return table.concat(parts, " ")
end

-- Parse curl output (headers + body + timing)
local function parse_response(output)
  if not output or output == "" then
    return nil, "Empty response from server"
  end
  
  -- Extract timing information
  local response_time = nil
  local body_and_headers = output
  
  local time_match = output:match("__POSTVIM_TIME__([%d%.]+)__")
  if time_match then
    response_time = math.floor(tonumber(time_match) * 1000) -- Convert to milliseconds
    -- Remove timing marker from output
    body_and_headers = output:gsub("\n?__POSTVIM_TIME__[%d%.]+__", "")
  end
  
  -- Split headers and body
  local header_end = body_and_headers:find("\r?\n\r?\n")
  if not header_end then
    return nil, "Invalid HTTP response format"
  end
  
  local headers_section = body_and_headers:sub(1, header_end)
  local body = body_and_headers:sub(header_end + 1)
  
  -- Remove extra newlines
  body = utils.trim(body)
  
  -- Parse headers
  local headers = {}
  local status_code = nil
  local status_line = ""
  
  for line in headers_section:gmatch("[^\r\n]+") do
    if line:match("^HTTP/") then
      status_line = line
      -- Extract status code
      local code = line:match("HTTP/%S+ (%d+)")
      if code then
        status_code = tonumber(code)
      end
    else
      table.insert(headers, line)
    end
  end
  
  -- Extract content-type
  local content_type = nil
  for _, header in ipairs(headers) do
    local ct = header:match("^[Cc]ontent%-[Tt]ype:%s*(.+)$")
    if ct then
      content_type = utils.trim(ct)
      break
    end
  end
  
  -- Try to pretty-print JSON if enabled
  local opts = config.get()
  if opts.pretty_print and content_type and content_type:match("application/json") then
    -- Try to format with jq
    if utils.command_exists("jq") then
      local handle = io.popen(string.format("echo '%s' | jq . 2>/dev/null", utils.escape_for_shell(body)))
      if handle then
        local formatted = handle:read("*a")
        handle:close()
        if formatted and formatted ~= "" then
          body = utils.trim(formatted)
        end
      end
    end
  end
  
  return {
    status_code = status_code,
    status_line = status_line,
    headers = headers,
    body = body,
    content_type = content_type,
    content_length = #body,
    response_time = response_time,
  }
end

-- Execute a single HTTP request
function M.execute_request(request)
  -- Validate request
  if not request.url then
    return nil, "Missing required field: url"
  end
  
  if not request.method then
    request.method = "GET" -- Default method
  end
  
  -- Show loading message
  utils.info(string.format("Executing %s %s...", request.method, request.url))
  
  -- Build and execute curl command
  local command = build_curl_command(request)
  
  -- Record start time
  local start_time = vim.loop.hrtime()
  
  -- Execute command
  local output = vim.fn.system(command)
  local exit_code = vim.v.shell_error
  
  -- Calculate execution time (as backup if curl timing fails)
  local execution_time = math.floor((vim.loop.hrtime() - start_time) / 1000000) -- Convert to milliseconds
  
  -- Check for errors
  if exit_code ~= 0 then
    local error_messages = {
      [6] = "Could not resolve host. Check the URL and your internet connection.",
      [7] = "Failed to connect to server. The server may be down or unreachable.",
      [28] = "Request timeout. The server took too long to respond.",
      [35] = "SSL connection error. The SSL/TLS handshake failed.",
      [52] = "Empty reply from server.",
      [56] = "Failed to receive network data.",
    }
    
    local error_msg = error_messages[exit_code] or string.format("curl failed with exit code %d", exit_code)
    
    -- Include curl output if available
    if output and output ~= "" then
      error_msg = error_msg .. "\n\nDetails:\n" .. output
    end
    
    return nil, error_msg
  end
  
  -- Parse response
  local response, err = parse_response(output)
  if not response then
    return nil, err or "Failed to parse response"
  end
  
  -- Use curl's timing if available, otherwise use our measurement
  if not response.response_time then
    response.response_time = execution_time
  end
  
  return response, nil
end

-- Execute multiple requests
function M.execute_requests(requests)
  local results = {}
  
  for i, request in ipairs(requests) do
    local response, err = M.execute_request(request)
    table.insert(results, {
      request = request,
      response = response,
      error = err,
      index = i,
    })
  end
  
  return results
end

return M
