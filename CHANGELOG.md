## [Unreleased] - febrero 2026
### Documentation
- [docs] update documentation (18 files) by @Christian Benitez

# Changelog

All notable changes to PostVim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-02-27

### Added

#### Major Features
- **Multiple Format Support**: Now supports both JSON and `.http` formats (VS Code REST Client compatible)
- **.http Format**: Intuitive format with `###` separators, natural header syntax, and direct body input
- **Individual Request Execution**: Execute only the request under cursor with `<leader>r`
- **Rich Response Display**: Shows HTTP status codes, response headers, response time, and content length
- **Color-Coded Status**: Status codes are colored (green for 2xx, yellow for 3xx, red for 4xx/5xx)
- **Health Check**: Comprehensive `:checkhealth postvim` integration
- **Syntax Highlighting**: Full syntax highlighting for `.http` files
- **File Type Detection**: Automatic detection and handling of `.http` files

#### User Experience
- **Visual Feedback**: Loading messages and completion notifications during request execution
- **Improved Error Messages**: Clear, descriptive error messages with helpful suggestions
- **Dependency Validation**: Automatic checking for required tools (curl, jq) on startup
- **Better Error Handling**: Specific error messages for different curl exit codes (timeouts, SSL errors, etc.)
- **Response Time Tracking**: Display request execution time in human-readable format
- **Content Length Display**: Show response size in human-readable format (B, KB, MB, GB)

#### Configuration
- **Setup Function**: New `require('postvim').setup()` function with extensive options
- **Configurable Split Behavior**: Choose between vertical, horizontal, or tab splits
- **Timeout Configuration**: Customizable request timeout
- **SSL Verification Toggle**: Option to disable SSL verification for development
- **Redirect Control**: Configure whether to follow HTTP redirects
- **Custom Keybindings**: Map commands to your preferred key combinations
- **Pretty Print Toggle**: Enable/disable automatic JSON formatting

#### Commands
- `:PostVimExecute` - Execute request under cursor
- `:PostVimExecuteAll` - Execute all requests in buffer
- `:PostVimClear` - Clear all response buffers
- `:PostVimVersion` - Show version information

#### Developer Features
- **Modular Architecture**: Complete rewrite with separate modules:
  - `config.lua` - Configuration management
  - `utils.lua` - Utility functions and helpers
  - `parser.lua` - Format detection and parsing
  - `executor.lua` - HTTP request execution
  - `ui.lua` - Buffer and display management
  - `health.lua` - Health check integration
- **Proper Error Propagation**: Errors are properly caught and displayed
- **Response Metadata**: Detailed response information including headers, timing, and content type
- **Content Type Detection**: Automatic detection and appropriate handling of different response types

#### Documentation
- **Comprehensive README**: Completely rewritten with examples, configuration options, and troubleshooting
- **Examples Directory**: Added `examples/` with sample `.http` and `.json` files
- **Health Check Guide**: Integration with Neovim's health check system
- **Format Comparison**: Documentation comparing `.http` and JSON formats

### Changed

#### Breaking Changes
- **Module Structure**: Plugin moved from root `postvim.lua` to `lua/postvim/` directory structure
- **Header Format**: JSON format now uses object for headers instead of array of objects
  - Old: `"headers": [{"Content-Type": "application/json"}]`
  - New: `"headers": {"Content-Type": "application/json"}`
- **Execution Behavior**: Default behavior is now to execute only current request, not all requests
- **Default Keybinding**: `<leader>r` executes current request only (use `<leader>ra` for all)

#### Improvements
- **Response Buffer Management**: Better handling of buffer reuse and window management
- **JSON Formatting**: More reliable JSON formatting with error handling
- **Performance**: Faster execution with optimized curl commands
- **Code Organization**: Clean, modular codebase that's easier to maintain and extend

### Fixed
- **Empty Response Handling**: Better handling of empty or invalid responses
- **Shell Escaping**: Proper escaping of special characters in URLs and request bodies
- **Buffer Naming**: Unique buffer names to prevent conflicts
- **Error Message Clarity**: Clear distinction between different types of errors
- **JSON Parsing**: More robust JSON parsing with better error messages
- **Header Parsing**: Correct parsing of response headers from curl output

### Deprecated
- **Old Header Format**: Array-of-objects header format in JSON (still supported but discouraged)

## [1.0.0] - Initial Release

### Added
- Basic HTTP request execution (GET, POST, etc.)
- JSON format support
- Custom headers and request bodies
- Response display in split buffers
- jq integration for JSON formatting
- Buffer reuse for same URLs

---

## Upgrade Guide

### From 1.x to 2.0

#### Installation
No changes needed. The plugin structure is backward compatible.

#### Configuration
Add a setup call to your `init.lua`:

```lua
-- Before (1.x) - implicit configuration
vim.keymap.set('n', '<leader>r', ':lua require("postvim").execute()<CR>')

-- After (2.0) - explicit setup
require('postvim').setup({
  keymaps = {
    execute = '<leader>r',
    execute_all = '<leader>ra',
  }
})
```

#### Request Files

**JSON Format** - Update header structure (optional but recommended):
```json
// Before (1.x)
{
  "headers": [{"Content-Type": "application/json"}]
}

// After (2.0)
{
  "headers": {"Content-Type": "application/json"}
}
```

Both formats are supported in 2.0 for backward compatibility.

**New .http Format** (recommended):
```http
### My Request
POST https://api.example.com/users
Content-Type: application/json

{
  "name": "John"
}
```

#### Behavior Changes
- `execute()` now executes only the current request under cursor
- Use `execute_all()` for previous behavior of executing all requests

---

For more information, see the [README.md](README.md) or run `:checkhealth postvim`.
