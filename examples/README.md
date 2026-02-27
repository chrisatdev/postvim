# PostVim Examples

This directory contains example HTTP request files to help you get started with PostVim.

## Files

### basic-requests.http
Demonstrates basic HTTP methods using the `.http` format:
- GET requests
- POST with JSON body
- PUT, DELETE, PATCH requests
- Request headers
- Query parameters

**Usage:**
1. Open the file: `nvim basic-requests.http`
2. Place cursor on any request
3. Press `<leader>r` to execute

### api-testing.http
Real-world examples using public APIs:
- Random User API
- GitHub API
- JSONPlaceholder API
- Authentication examples

**Note:** For authenticated requests, replace `YOUR_GITHUB_TOKEN_HERE` with your actual token.

### basic-requests.json
Same examples as `basic-requests.http` but in JSON format.

**Usage:**
1. Open the file: `nvim basic-requests.json`
2. Press `<leader>ra` to execute all requests
3. Or press `<leader>r` to execute the first request

## Quick Test

To quickly test if PostVim is working:

```bash
# Open an example file
nvim examples/basic-requests.http

# Execute a request (in Neovim)
# Move cursor to line 2 (Simple GET request)
# Press <leader>r
```

You should see a split window with the HTTP response!

## Format Comparison

### .http Format (Recommended)
- More readable
- Easier to write
- VS Code REST Client compatible
- Natural separation with `###`

### JSON Format
- Structured data
- Programmatically generated
- Traditional approach

## Tips

1. **Test Simple Requests First**: Start with `basic-requests.http` to verify everything works
2. **Use Public APIs**: The examples use public APIs that don't require authentication
3. **Check Health**: Run `:checkhealth postvim` if something doesn't work
4. **View Responses**: Each URL opens its own buffer, so you can compare multiple responses

## Need Help?

- Run `:help PostVim` (coming soon)
- Check `:checkhealth postvim`
- Read the main [README.md](../README.md)
- Open an issue on GitHub

Happy testing!
