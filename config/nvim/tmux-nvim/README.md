# tmux-nvim

Neovim plugin mirroring `ChmaraX/herdr-nvim` for tmux. Floating comment input, extmark-tracked comments, smart fzf-lua tmux pane picker, `tmux load-buffer` + `paste-buffer` dispatch.

## Install (lazy.nvim, local)
```lua
{ dir = "~/Projects/tmux-nvim", name = "tmux-nvim", opts = { prefix = "<leader>t" } }
-- prefix <leader>t avoids clash with herdr-nvim's <leader>a; use <leader>a if herdr not installed
```

## Setup
```lua
require("tmux-nvim").setup({
  prefix = "<leader>t", -- <leader>tc / tl / ts / tS (or <leader>a if alone)
  keymaps = true,
  clear_after_send = true,
})
```

## Usage
- `<leader>tc` normal: comment current line (centered 60×6 float, rounded border, `:w` to save, `q`/`Esc` discard, `<C-s>` save)
- `<leader>tc` visual: comment selection
- `<leader>tl` list comments (float, `<CR>` edit, `d` delete, `q` close, auto-preview jumps)
- `<leader>ts` paste comments to tmux pane (no Enter) — smart picker
- `<leader>tS` send comments to tmux pane (with Enter) — smart picker

All comments formatted as `file:line` + snippet + text, with `repo: X, branch: Y` header. Sent via `tmux load-buffer` + `paste-buffer -t <pane>` (multiline-safe, literal). Requires `$TMUX`.

Smart picker: `tmux list-panes` parsed via `#{pane_id}|#{window_index}|#{pane_index}|#{pane_current_command}|#{pane_title}|#{pane_active}`. `pane_title` is the signal — pi sets OSC title to `/tmp/pi-clipboard-....png`, so `is_agent_pane` matches `/tmp/pi`, `pi-clipboard`, word `pi`, `codex`, `claude`. Agents sorted first, current nvim pane last, unambiguous single-agent auto-skips picker (like herdr-nvim's `resolve`).

- `require("tmux-nvim").statusline()` → `● N` or `""`

## Requires
- tmux inside `$TMUX`
- `fzf-lua` recommended for pane picker (falls back to `vim.ui.select`)
