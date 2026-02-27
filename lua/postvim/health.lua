local M = {}

local health_start = vim.health.start or vim.health.report_start
local health_ok = vim.health.ok or vim.health.report_ok
local health_warn = vim.health.warn or vim.health.report_warn
local health_error = vim.health.error or vim.health.report_error
local health_info = vim.health.info or vim.health.report_info

function M.check()
  health_start("PostVim Health Check")
  
  -- Check Neovim version
  local nvim_version = vim.version()
  if nvim_version.major >= 0 and nvim_version.minor >= 7 then
    health_ok(string.format("Neovim version: %d.%d.%d", nvim_version.major, nvim_version.minor, nvim_version.patch))
  else
    health_warn(string.format("Neovim version %d.%d.%d is old. PostVim works best with Neovim 0.7+", 
      nvim_version.major, nvim_version.minor, nvim_version.patch))
  end
  
  -- Check for curl
  health_start("Dependencies")
  local curl_exists = vim.fn.executable("curl") == 1
  if curl_exists then
    local curl_version = vim.fn.system("curl --version"):match("curl ([%d%.]+)")
    health_ok(string.format("curl is installed (version: %s)", curl_version or "unknown"))
  else
    health_error("curl is not installed", {
      "PostVim requires curl to make HTTP requests",
      "Install curl: https://curl.se/download.html",
      "  Ubuntu/Debian: sudo apt-get install curl",
      "  macOS: brew install curl",
      "  Windows: choco install curl"
    })
  end
  
  -- Check for jq
  local jq_exists = vim.fn.executable("jq") == 1
  if jq_exists then
    local jq_version = vim.fn.system("jq --version"):match("jq%-([%d%.]+)")
    health_ok(string.format("jq is installed (version: %s)", jq_version or "unknown"))
  else
    health_warn("jq is not installed", {
      "jq is optional but recommended for pretty-printing JSON responses",
      "Install jq: https://stedolan.github.io/jq/download/",
      "  Ubuntu/Debian: sudo apt-get install jq",
      "  macOS: brew install jq",
      "  Windows: choco install jq"
    })
  end
  
  -- Check configuration
  health_start("Configuration")
  local ok, config = pcall(require, 'postvim.config')
  if ok then
    local opts = config.get()
    health_ok("Configuration loaded successfully")
    health_info(string.format("Split direction: %s", opts.split_direction))
    health_info(string.format("Default format: %s", opts.default_format))
    health_info(string.format("Timeout: %dms", opts.timeout))
  else
    health_error("Failed to load configuration", {
      tostring(config)
    })
  end
  
  -- Check module loading
  health_start("Modules")
  local modules = {
    'postvim.utils',
    'postvim.parser',
    'postvim.executor',
    'postvim.ui',
  }
  
  for _, module in ipairs(modules) do
    local ok, err = pcall(require, module)
    if ok then
      health_ok(string.format("%s loaded", module))
    else
      health_error(string.format("Failed to load %s", module), {
        tostring(err)
      })
    end
  end
  
  -- Check keymaps
  health_start("Keymaps")
  local opts = config and config.get() or {}
  if opts.keymaps then
    health_info(string.format("Execute request: %s", opts.keymaps.execute or "not set"))
    health_info(string.format("Execute all requests: %s", opts.keymaps.execute_all or "not set"))
  end
end

return M
