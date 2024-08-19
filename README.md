# PostVim

**PostVim** is a simple yet powerful Neovim plugin that allows you to make HTTP requests directly from within your editor. Whether you need to send a GET request or POST some data, PostVim makes it easy to work with APIs without leaving your Neovim environment.

## Features

- Execute HTTP requests (GET, POST, etc.) directly from Neovim.
- Supports setting custom headers and request bodies.
- Responses are automatically formatted as pretty JSON with syntax highlighting.
- Responses for the same URL are shown in the same buffer; different URLs will open in new buffers.
- Integrated with `jq` for JSON formatting and colorization.

## Installation

To install PostVim, use your preferred plugin manager.

### Using [vim-plug](https://github.com/junegunn/vim-plug)

Add the following to your `init.vim` or `init.lua`:

```vim
Plug 'chrisatdev/postvim'
```

Then, run `:PlugInstall` in Neovim.

## Using Packer
Add the following to your init.lua:

```lua
use 'chrisatdev/postvim'
```

Then, run `:PackerSync` in Neovim.

## Usage
 1. Create a JSON file with your HTTP requests. Example:
```json
[{
  "method": "GET",
  "headers": [{
    "Accept": "application/json",
    "Authorization": "Bearer your_token_here"
  }],
  "url": "http://localhost:8080/api/users"
},
{
  "method": "POST",
  "headers": [{
    "Content-Type": "application/json"
  }],
  "url": "http://localhost:8080/api/users",
  "body": "{\"name\": \"John Doe\", \"email\": \"john@example.com\"}"
}]
```

2. Execute the requests by pressing `<leader>(key)` while in the JSON file.

3. The response will be displayed in a split buffer with syntax highlighting.

## Configuration
### Keybinding
You can customize this by mapping it to another key combination in your init.vim or init.lua:
```lua
nnoremap <leader>r :lua require('postvim').execute()<CR>

```

## JSON Formatting and Syntax Highlighting
The plugin uses jq to format and colorize JSON responses. Ensure jq is installed on your system for this feature to work.

## Dependencies
`curl`: Used to make the HTTP requests.<br>
`jq`: Used to format and colorize the JSON output.

## License
This project is licensed under the MIT License.

## Contributing
Contributions are welcome! <br>
Feel free to submit a Pull Request or open an Issue if you find a bug or have a feature request.

## Author
* GitHub: [chrisatdev](https://github.com/chrisatdev)
