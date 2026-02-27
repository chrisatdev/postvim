local M = {}

-- Default configuration
M.defaults = {
  -- UI Settings
  split_direction = 'vertical', -- 'vertical', 'horizontal', 'tab'
  split_size = 80,              -- Size of split in columns/rows
  show_headers = true,          -- Show response headers
  show_response_time = true,    -- Show response time
  show_status_code = true,      -- Show HTTP status code
  
  -- Behavior
  timeout = 30000,              -- Request timeout in milliseconds
  follow_redirects = true,      -- Follow HTTP redirects
  verify_ssl = true,            -- Verify SSL certificates
  
  -- Format
  default_format = 'http',      -- 'http' or 'json'
  pretty_print = true,          -- Auto-format JSON responses
  
  -- Keybindings
  keymaps = {
    execute = '<leader>r',      -- Execute current request
    execute_all = '<leader>ra', -- Execute all requests
  },
  
  -- Environment/Variables
  environments = {},
  current_env = nil,
  
  -- Language
  language = 'en',              -- 'en' or 'es'
}

-- Current configuration (starts with defaults)
M.options = vim.deepcopy(M.defaults)

-- Setup function to merge user config with defaults
function M.setup(user_config)
  M.options = vim.tbl_deep_extend('force', M.defaults, user_config or {})
  return M.options
end

-- Get current configuration
function M.get()
  return M.options
end

-- Get specific config value
function M.get_value(key)
  return M.options[key]
end

-- Set specific config value
function M.set_value(key, value)
  M.options[key] = value
end

return M
