local M = {}

-- Lazy load modules
local config = nil
local utils = nil
local parser = nil
local executor = nil
local ui = nil

local function ensure_loaded()
  if not config then
    config = require('postvim.config')
    utils = require('postvim.utils')
    parser = require('postvim.parser')
    executor = require('postvim.executor')
    ui = require('postvim.ui')
  end
end

-- Setup function for user configuration
function M.setup(user_config)
  ensure_loaded()
  
  -- Merge user config with defaults
  config.setup(user_config or {})
  
  -- Check dependencies on setup
  local missing = utils.check_dependencies()
  if #missing > 0 then
    utils.warn("Missing dependencies: " .. table.concat(missing, ", "))
    utils.info("Run :checkhealth postvim for installation instructions")
  end
  
  -- Setup keymaps if configured
  local opts = config.get()
  if opts.keymaps then
    M.setup_keymaps(opts.keymaps)
  end
  
  -- Create user commands
  M.setup_commands()
end

-- Setup default keymaps
function M.setup_keymaps(keymaps)
  keymaps = keymaps or {}
  
  if keymaps.execute then
    vim.keymap.set('n', keymaps.execute, function()
      M.execute()
    end, { desc = "PostVim: Execute current request", silent = true })
  end
  
  if keymaps.execute_all then
    vim.keymap.set('n', keymaps.execute_all, function()
      M.execute_all()
    end, { desc = "PostVim: Execute all requests", silent = true })
  end
end

-- Setup user commands
function M.setup_commands()
  -- Execute current request
  vim.api.nvim_create_user_command('PostVimExecute', function()
    M.execute()
  end, { desc = "Execute current HTTP request" })
  
  -- Execute all requests
  vim.api.nvim_create_user_command('PostVimExecuteAll', function()
    M.execute_all()
  end, { desc = "Execute all HTTP requests in buffer" })
  
  -- Clear response buffers
  vim.api.nvim_create_user_command('PostVimClear', function()
    M.clear_buffers()
  end, { desc = "Clear all PostVim response buffers" })
  
  -- Show version
  vim.api.nvim_create_user_command('PostVimVersion', function()
    M.version()
  end, { desc = "Show PostVim version" })
end

-- Execute current request (under cursor)
function M.execute()
  ensure_loaded()
  
  -- Check dependencies first
  local missing = utils.check_dependencies()
  if #missing > 0 then
    utils.error("Missing required dependencies: " .. table.concat(missing, ", "))
    utils.info("Install them and try again. Run :checkhealth postvim for help")
    return
  end
  
  -- Parse current request
  local requests, err = parser.parse_current_request()
  if err then
    utils.error(err)
    return
  end
  
  if not requests or #requests == 0 then
    utils.error("No request found at current position")
    return
  end
  
  -- Execute the request
  local request = requests[1]
  
  -- Validate request
  local valid, validation_err = parser.validate_request(request)
  if not valid then
    utils.error(validation_err)
    return
  end
  
  -- Execute
  local response, exec_err = executor.execute_request(request)
  
  if exec_err then
    ui.display_error(request.url, exec_err)
    return
  end
  
  if response then
    ui.display_response(request.url, response)
  end
end

-- Execute all requests in buffer
function M.execute_all()
  ensure_loaded()
  
  -- Check dependencies first
  local missing = utils.check_dependencies()
  if #missing > 0 then
    utils.error("Missing required dependencies: " .. table.concat(missing, ", "))
    utils.info("Install them and try again. Run :checkhealth postvim for help")
    return
  end
  
  -- Parse all requests
  local requests, err = parser.parse_buffer()
  if err then
    utils.error(err)
    return
  end
  
  if not requests or #requests == 0 then
    utils.error("No valid requests found in buffer")
    return
  end
  
  utils.info(string.format("Executing %d request(s)...", #requests))
  
  -- Execute each request
  for i, request in ipairs(requests) do
    -- Validate request
    local valid, validation_err = parser.validate_request(request)
    if valid then
      local response, exec_err = executor.execute_request(request)
      
      if exec_err then
        ui.display_error(request.url, exec_err)
      elseif response then
        ui.display_response(request.url, response)
      end
    else
      utils.error(string.format("Request #%d: %s", i, validation_err))
    end
  end
  
  utils.success(string.format("Completed %d request(s)", #requests))
end

-- Clear all response buffers
function M.clear_buffers()
  ensure_loaded()
  ui.clear_buffers()
end

-- Show version information
function M.version()
  ensure_loaded()
  local version = "2.0.0" -- Updated version
  utils.info("PostVim version " .. version)
  utils.info("An HTTP client for Neovim")
  utils.info("https://github.com/chrisatdev/postvim")
end

return M
