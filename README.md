# PostVim

**PostVim** is a powerful and user-friendly Neovim plugin that allows you to make HTTP requests directly from within your editor. Whether you need to test REST APIs, debug endpoints, or interact with web services, PostVim makes it easy to work with HTTP without leaving your Neovim environment.

## Features

- **Multiple Format Support**: Use either JSON format or the intuitive `.http` format (compatible with VS Code REST Client)
- **Smart Request Execution**: Execute individual requests under cursor or all requests in buffer
- **Rich Response Information**: View status codes, headers, response times, and content length
- **Visual Feedback**: Clear loading indicators and colored status codes (green for 2xx, red for 4xx/5xx)
- **Intelligent Error Handling**: Descriptive error messages with helpful suggestions
- **Automatic Dependency Checking**: Validates required tools on startup
- **Highly Configurable**: Customize split behavior, timeouts, SSL verification, and more
- **Health Check Integration**: Use `:checkhealth postvim` to verify your setup
- **Pretty JSON Formatting**: Automatic JSON formatting with syntax highlighting
- **Buffer Management**: Responses for the same URL reuse buffers; different URLs open new ones

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'chrisatdev/postvim',
  config = function()
    require('postvim').setup({
      -- Your configuration here (optional)
    })
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'chrisatdev/postvim',
  config = function()
    require('postvim').setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'chrisatdev/postvim'
```

Then add to your `init.lua`:
```lua
require('postvim').setup()
```

## Quick Start

### Using .http Format (Recommended)

Create a file with `.http` extension:

```http
### Get all users
GET http://localhost:8080/api/users
Accept: application/json
Authorization: Bearer your_token_here

### Create new user
POST http://localhost:8080/api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com"
}

### Update user
PUT http://localhost:8080/api/users/123
Content-Type: application/json

{
  "name": "Jane Doe"
}
```

Place your cursor on any request and press `<leader>r` to execute it!

### Using JSON Format

Create a JSON file:

```json
[{
  "method": "GET",
  "headers": {
    "Accept": "application/json",
    "Authorization": "Bearer your_token_here"
  },
  "url": "http://localhost:8080/api/users"
},
{
  "method": "POST",
  "headers": {
    "Content-Type": "application/json"
  },
  "url": "http://localhost:8080/api/users",
  "body": "{\"name\": \"John Doe\", \"email\": \"john@example.com\"}"
}]
```

## Usage

### Commands

- `:PostVimExecute` - Execute the request under cursor
- `:PostVimExecuteAll` - Execute all requests in buffer
- `:PostVimClear` - Clear all response buffers
- `:PostVimVersion` - Show version information

### Default Keybindings

- `<leader>r` - Execute current request
- `<leader>ra` - Execute all requests

### Response Buffer

The response buffer shows:

```
HTTP/1.1 200 OK
Date: Fri Feb 27 2026 10:30:45 GMT
Content-Type: application/json
Content-Length: 156

Response Time: 245ms
Content Length: 156 B

--------------------------------------------------

{
  "users": [
    { "id": 1, "name": "John" },
    { "id": 2, "name": "Jane" }
  ]
}
```

Status codes are color-coded:
- Green (2xx): Success
- Yellow (3xx): Redirection
- Red (4xx, 5xx): Client/Server errors

## Configuration

### Full Configuration Example

```lua
require('postvim').setup({
  -- UI Settings
  split_direction = 'vertical',  -- 'vertical', 'horizontal', or 'tab'
  split_size = 80,               -- Size of split in columns/rows
  show_headers = true,           -- Show response headers
  show_response_time = true,     -- Show response time
  show_status_code = true,       -- Show HTTP status code
  
  -- Behavior
  timeout = 30000,               -- Request timeout in milliseconds
  follow_redirects = true,       -- Follow HTTP redirects
  verify_ssl = true,             -- Verify SSL certificates
  
  -- Format
  default_format = 'http',       -- 'http' or 'json'
  pretty_print = true,           -- Auto-format JSON responses
  
  -- Keybindings
  keymaps = {
    execute = '<leader>r',       -- Execute current request
    execute_all = '<leader>ra',  -- Execute all requests
  },
  
  -- Language
  language = 'en',               -- 'en' or 'es'
})
```

### Minimal Configuration

```lua
require('postvim').setup()  -- Uses all defaults
```

### Custom Keybindings Only

```lua
require('postvim').setup({
  keymaps = {
    execute = '<leader>hr',      -- Custom keybinding
    execute_all = '<leader>hh',
  }
})
```

## Format Comparison

### .http Format (Recommended)

**Advantages:**
- More intuitive and readable
- Compatible with VS Code REST Client
- Natural separation between requests with `###`
- Cleaner header syntax
- Direct body input without JSON escaping

**Example:**
```http
### Simple GET request
GET https://api.github.com/users/chrisatdev

### POST with JSON body
POST https://httpbin.org/post
Content-Type: application/json

{
  "name": "Test",
  "value": 123
}
```

### JSON Format

**Advantages:**
- Programmatically easier to generate
- All data in structured format
- Traditional approach

**Example:**
```json
[{
  "method": "GET",
  "url": "https://api.github.com/users/chrisatdev"
},
{
  "method": "POST",
  "url": "https://httpbin.org/post",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"name\": \"Test\", \"value\": 123}"
}]
```

## Dependencies

### Required
- **curl**: Used to make HTTP requests
  - Ubuntu/Debian: `sudo apt-get install curl`
  - macOS: `brew install curl`
  - Windows: `choco install curl`

### Optional
- **jq**: Used for pretty-printing JSON responses
  - Ubuntu/Debian: `sudo apt-get install jq`
  - macOS: `brew install jq`
  - Windows: `choco install jq`

Run `:checkhealth postvim` to verify your installation.

## Health Check

PostVim includes a comprehensive health check:

```vim
:checkhealth postvim
```

This verifies:
- Neovim version compatibility
- Required dependencies (curl, jq)
- Plugin configuration
- Module loading status
- Keybinding setup

## Troubleshooting

### "Missing required dependencies: curl"
Install curl using your package manager. See Dependencies section above.

### "Failed to parse response"
This may happen if the server returns invalid HTTP. Check if the URL is correct and the server is responding properly.

### "Request timeout"
Increase the timeout in configuration:
```lua
require('postvim').setup({
  timeout = 60000  -- 60 seconds
})
```

### SSL/TLS Errors
For development/testing with self-signed certificates:
```lua
require('postvim').setup({
  verify_ssl = false  -- Warning: Only use for development
})
```

## Roadmap

### Planned Features (Future Versions)

- **Variables & Environments**: Define variables and switch between dev/staging/prod
- **Dynamic Variables**: Support for `{{$guid}}`, `{{$timestamp}}`, etc.
- **Request History**: Track and re-execute previous requests
- **Authentication Helpers**: Built-in support for OAuth, Basic Auth
- **Test/Assertions**: Add response validation
- **Collection Import/Export**: Import Postman collections
- **GraphQL Support**: Send GraphQL queries
- **WebSocket Support**: Test WebSocket connections

## Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- Code follows existing style
- Add tests if applicable
- Update documentation
- Run `:checkhealth postvim` to verify changes

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

- GitHub: [@chrisatdev](https://github.com/chrisatdev)
- Created with love for the Neovim community

## Acknowledgments

- Inspired by Postman and VS Code REST Client
- Built for the amazing Neovim community
- Thanks to all contributors

---

If you find PostVim useful, please consider giving it a star on GitHub!
