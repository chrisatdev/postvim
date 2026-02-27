local utils = require('postvim.utils')

local M = {}

-- Parse JSON format
local function parse_json_format(content)
  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok then
    return nil, "Invalid JSON format: " .. tostring(data)
  end
  
  -- Support both array of requests and single request object
  local requests = {}
  if type(data) == "table" then
    if data[1] then
      -- Array of requests
      requests = data
    elseif data.method and data.url then
      -- Single request object
      requests = {data}
    elseif data.requests then
      -- Format: { "requests": [...] }
      requests = data.requests
    else
      return nil, "Invalid JSON structure. Expected array of requests or single request object."
    end
  else
    return nil, "Invalid JSON structure. Expected object or array."
  end
  
  -- Normalize headers format
  for _, req in ipairs(requests) do
    if req.headers then
      -- Convert array of objects to single object
      if type(req.headers[1]) == "table" then
        local normalized = {}
        for _, header_obj in ipairs(req.headers) do
          for key, value in pairs(header_obj) do
            normalized[key] = value
          end
        end
        req.headers = normalized
      end
    end
  end
  
  return requests, nil
end

-- Parse .http format (VS Code REST Client compatible)
local function parse_http_format(lines)
  local requests = {}
  local current_request = nil
  local in_body = false
  local body_lines = {}
  
  for i, line in ipairs(lines) do
    local trimmed = utils.trim(line)
    
    -- Check for request separator or comment
    if utils.starts_with(trimmed, "###") then
      -- Save previous request if exists
      if current_request then
        if #body_lines > 0 then
          current_request.body = table.concat(body_lines, "\n")
        end
        table.insert(requests, current_request)
      end
      
      -- Start new request
      current_request = {
        headers = {},
        name = trimmed:sub(4):match("^%s*(.-)%s*$"), -- Extract name after ###
      }
      in_body = false
      body_lines = {}
      
    elseif current_request then
      -- Parse method and URL line
      if not current_request.method then
        local method, url = trimmed:match("^(%u+)%s+(.+)$")
        if method and url then
          current_request.method = method
          current_request.url = utils.trim(url)
          in_body = false
        end
        
      -- Empty line indicates start of body
      elseif trimmed == "" and not in_body then
        in_body = true
        
      -- Parse headers (key: value format)
      elseif not in_body and trimmed:match("^[^:]+:.+$") then
        local key, value = trimmed:match("^([^:]+):%s*(.+)$")
        if key and value then
          current_request.headers[utils.trim(key)] = utils.trim(value)
        end
        
      -- Parse body content
      elseif in_body then
        table.insert(body_lines, line) -- Keep original formatting for body
      end
    end
  end
  
  -- Save last request
  if current_request then
    if #body_lines > 0 then
      current_request.body = table.concat(body_lines, "\n")
    end
    table.insert(requests, current_request)
  end
  
  return requests, nil
end

-- Find request at specific line number
local function find_request_at_line(requests, line_num, format)
  if format == "json" then
    -- For JSON, just return the first request or all requests
    -- Since JSON doesn't have clear line boundaries, we execute all
    return requests
  else
    -- For .http format, find which request the cursor is in
    -- This would require tracking line numbers during parsing
    -- For now, return the first request
    -- TODO: Implement proper line-based request detection
    if #requests > 0 then
      return {requests[1]}
    end
  end
  return {}
end

-- Parse buffer content and extract requests
function M.parse_buffer(bufnr, current_line)
  bufnr = bufnr or 0
  current_line = current_line or utils.get_current_line()
  
  -- Get buffer content
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 then
    return nil, "Buffer is empty"
  end
  
  local content = table.concat(lines, "\n")
  
  -- Detect format based on content
  local format = "json" -- Default
  local first_line = utils.trim(lines[1])
  
  -- Check if it looks like .http format
  if utils.starts_with(first_line, "###") or 
     utils.starts_with(first_line, "GET ") or
     utils.starts_with(first_line, "POST ") or
     utils.starts_with(first_line, "PUT ") or
     utils.starts_with(first_line, "DELETE ") or
     utils.starts_with(first_line, "PATCH ") then
    format = "http"
  elseif utils.starts_with(first_line, "{") or utils.starts_with(first_line, "[") then
    format = "json"
  end
  
  -- Parse based on detected format
  local requests, err
  if format == "json" then
    requests, err = parse_json_format(content)
  else
    requests, err = parse_http_format(lines)
  end
  
  if err then
    return nil, err
  end
  
  if not requests or #requests == 0 then
    return nil, "No valid requests found in buffer"
  end
  
  return requests, nil, format
end

-- Parse and get only the current request under cursor
function M.parse_current_request(bufnr, current_line)
  bufnr = bufnr or 0
  current_line = current_line or utils.get_current_line()
  
  local all_requests, err, format = M.parse_buffer(bufnr, current_line)
  if err then
    return nil, err
  end
  
  -- For .http format, find the request at current line
  if format == "http" then
    -- Parse again with line tracking
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local current_request = nil
    local request_start_line = 0
    
    for i, line in ipairs(lines) do
      local trimmed = utils.trim(line)
      
      if utils.starts_with(trimmed, "###") then
        request_start_line = i
      end
      
      -- Check if we're at or past the current line
      if i == current_line then
        -- Find the request that contains this line
        for _, req in ipairs(all_requests) do
          current_request = req
          break -- Return first request for now
        end
        break
      end
    end
    
    if current_request then
      return {current_request}, nil
    end
  end
  
  -- For JSON or if not found, return first request
  if #all_requests > 0 then
    return {all_requests[1]}, nil
  end
  
  return nil, "No request found at current position"
end

-- Validate request object
function M.validate_request(request)
  if not request then
    return false, "Request is nil"
  end
  
  if not request.url then
    return false, "Missing required field: url"
  end
  
  if not request.method then
    request.method = "GET" -- Default to GET
  end
  
  -- Validate method
  local valid_methods = { "GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS" }
  local is_valid_method = false
  for _, m in ipairs(valid_methods) do
    if request.method:upper() == m then
      is_valid_method = true
      request.method = m -- Normalize to uppercase
      break
    end
  end
  
  if not is_valid_method then
    return false, string.format("Invalid HTTP method: %s", request.method)
  end
  
  return true, nil
end

return M
