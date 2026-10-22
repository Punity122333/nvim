# Neovim Configuration

A **LazyVim**-based Neovim configuration focused on a fast, productive, and hackable editor experience. This repo contains my personal Neovim setup, including custom highlights, plugins, keymaps, and utilities.

---

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration Structure](#configuration-structure)
- [Key Mappings](#key-mappings)
- [Plugins](#plugins)
- [Development](#development)
- [License](#license)

---

## About

This is a Neovim configuration built on top of [LazyVim](https://github.com/LazyVim/LazyVim). It provides a comprehensive set of plugins and configurations for daily development, with a strong emphasis on:

- **Aesthetics** — Custom highlight groups and colour palette (`config/highlights.lua`)
- **Productivity** — Mini‑plugins, snacks picker, telescope, trouble, and more
- **Language Support** — Language servers for Python, Rust, Haskell, Go, JSON, Markdown, and many more via LazyVim extras
- **Snippets** — Custom snippet engine (`lua/snippet_engine/`) plus `friendly-snippets`
- **LSP & Debugging** — `lua_ls`, `basedpyright`, `delve`, `codelldb`, and DAP integration
- **AI Assistance** — GitHub Copilot integration

The configuration follows the principle of **one owner per concern**: colours are defined in `config/highlights.lua`, options in `config/options.lua`, and plugin specs in `lua/plugins/`.

---

## Features

| Category | Highlights |
|---|---|
| **UI / Visual** | Custom theme tinting, relative/absolute line numbers, cursor colouration, `SnacksPicker` UI, `lualine` with custom components |
| **Editing** | `mini.surround`, `mini.comment`, `mini.operators`, `mini.splitjoin`, `mini.ai`, `conform.nvim` for formatting, `blink.cmp` completion with snippet engine |
| **LSP / Tools** | `lazy.nvim` lazy-loading, `null-ls` for code actions, `trouble` diagnostics, `dap` debugging, `toggleterm` for terminal splits |
| **Files / Navigation** | `nvim-tree` / `oil.nvim` file explorer, `snacks.explorer`, `gitsigns`, `mini.diff`, `telescope`, `fzf-native` |
| **Markdown & LaTeX** | `render-markdown` (disabled), `vimtex` configuration, `neorg` (if enabled), `obsidian` support |
| **AI & Copilot** | GitHub Copilot with debug mode, `avante` (if configured) |

---

## Installation

> **Prerequisites**: Neovim >= 0.9, Git, a C compiler (for tree-sitter), and a working terminal (Wayland clipboard support is configured for `wl-copy`/`wl-paste`).

### Option 1: Clone this repo (default lazyvim starter)

```bash
git clone https://github.com/Punity122333/nvim ~/.config/nvim
```

### Option 2: Use as a standalone config

If you already have a Neovim config, you can copy the contents of `lua/`, `plugins/`, and `after/` into your own `~/.config/nvim`.

After cloning / copying, start Neovim:

```bash
nvim
```

The first launch will bootstrap `lazy.nvim` and install all plugins. This may take a few minutes.

### Updating

To update plugins and the config:

```bash
nvim --headless -c 'Lazy' -c 'qa'
```

Or simply run `Lazy` from within Neovim.

---

## Quick Start

| Action | Default Keybind |
|---|---|
| Open picker (files) | `<C-p>` |
| Open picker (grep) | `<C-f>` |
| Toggle terminal | `<C-\>` |
| Format buffer | `<leader>f` |
| Restart LSP | `<leader>rl` |
| Inspect word under cursor | `hi` |
| Reload all buffers | `:RefreshAll` |
| Cowardly format range | `<leader>f` + visual selection |
| Dap toggle | `<leader>d` |

(See the [keymaps docs](docs/config/keymaps.md) for the complete list.)

---

## Configuration Structure

```
.
├─ init.lua          entry point: environment, theme, global commands
├─ lua/
│  ├── config/       core options: options, keymaps, autocmds, palette, indent
│  ├── plugins/      one file per plugin spec (lazy.nvim)
│  └── snippet_engine/ custom snippet engine (LSP syntax on extmarks)
├─ after/            ftplugins and tree-sitter queries
├─ docs/             this documentation
└─ snippets/         snippet files (friendly-snippets + custom)
```

### Core config files

- `lua/config/options.lua` – global options (line numbers, formatoptions, PATH, etc.)
- `lua/config/keymaps.lua` – keymap definitions
- `lua/config/autocmds.lua` – autocommands
- `lua/config/highlights.lua` – colour palette and highlight groups
- `lua/config/treesitter.lua` – treesitter config and disabled languages
- `lazy.lua` – lazy.nvim setup (bootstrapping, defaults)

### Plugin categories

Each plugin spec lives in `lua/plugins/` and is named after the plugin, e.g. `lua/plugins/blink-cmp.lua`, `lua/plugins/render-markdown.lua`, etc.

---

## Key Mappings

Below are the most useful mappings. Full lists are in `lua/config/keymaps.lua` and documented per‑file in `docs/`.

| Mode | Keymap | Action |
|---|---|---|
| `n` | `hi` | `:Inspect<CR>` – show documentation for word under cursor |
| `n` | `<leader>f` | Format buffer (async, LSP fallback) |
| `n` | `<leader>rl` | Restart LSP server |
| `n` | `<C-p>` | Snacks picker: find files |
| `n` | `<C-f>` | Snacks picker: live grep |
| `n` | `<leader>d` | Toggle Dap debug session |
| `n` | `<leader>u` | Toggle diagnostics |
| `i` | `<C-s>` | Save (if enabled) |
| `t` | `<C-\>` | Toggle terminal |
| `v` | `<leader>f` | Format selection |

---

## Plugins

This config uses **LazyVim extras** plus a few custom plugins. Key plugins include:

| Plugin | Purpose |
|---|---|
| `folke/lazy.nvim` | Plugin manager |
| `echasnovski/mini.*` | Mini‑suite: surround, comment, operators, ai, splitjoin, hipatterns |
| `folke/trouble.nvim` | Diagnostics, references, quickfix |
| `nvim-lua/plenary.nvim` | Utility libs |
| `nvim-tree/nvim-web-devicons` | File icons |
| `folke/which-key.nvim` | Keybind hint popups |
| `hrsh7th/nvim-cmp` | Completion |
| `saghen/blink.cmp` | Fork of cmp, used with custom snippet engine |
| `gbprod/mini.snippets` | Snippet support |
| `rafamadriz/friendly-snippets` | Pre‑built snippets |
| `mawkler/moly` | (custom) |
| `echasnovski/snacks.nvim` | Picker, dashboard, explorer, status column |
| `folke/tokyonight.nvim` / colorscheme base |
| `folke/todo-comments.nvim` | Highlight TODOs |
| `windwp/nvim-autopairs` | Auto‑closing brackets |
| `numToStr/Comment.nvim` | Commenting (replaced by mini.comment) |
| `b0o/shellharden` | Bash + Zsh completion |
| `gaoosa123/avante.nvim` | AI assistant (configurable) |
| `rcarriga/nvim-dap-ui` | DAP UI |
| `theHamsta/nvim-dap-vscode-nodejs` | Node debugging |
| `jay-babu/mason-nvim-dap.nvim` | DAP automatic setup |
| `akinsho/nvim-bufferline.lua` | Tabline (custom) |
| `nvim-lualine/lualine.nvim` | Statusline |
| `CRAG666/code_runner.nvim` | Run code snippets |
| `brenoprata10/nvim-highlight-comment` | Highlight TODO/FIXME |
| `mrjones2014/legendary.nvim` | Keybind manager |
| `MunifTanjim/nui.nvim` | Neovim UI component lib |
| `AstroNvim/starter.nvim` | Start screen (alpha dashboard) |

See `lua/plugins/` for the full list and per‑plugin configuration.

---

## Development

### Adding a new plugin

1. Create a new file `lua/plugins/<name>.lua` following the existing pattern.
2. Add the spec using LazyVim's `LazyVim.plugin()` or standard lazy.nvim syntax.
3. Run `:Lazy` to register / install.

### Customising options

Most options live in `lua/config/options.lua`. Use `vim.g.<name>` or `vim.opt.<name>` there. For plugin‑specific options, use the `opts` table in the plugin spec (never `config`, which replaces LazyVim's setup).

### Changing the colour palette

Edit `lua/config/highlights.lua`. The palette is defined as a Lua table; all highlight groups reference colours from this table. Running `:ThemeGodMode` (automatically on `ColorScheme` / `VimEnter`) will re‑tint the UI.

### Debugging

DAP configurations are in `lua/config/dap.lua`. Ensure `mason-nvim-dap` is active for automatic adapter detection.

---

## License

This project is **unlicensed** – feel free to use, modify, and distribute the configuration. If you find it useful, consider starring the repo.

---

## Acknowledgments

- Base configuration on [LazyVim](https://github.com/LazyVim/LazyVim)
- Inspiration from [AstroNvim](https://github.com/AstroNvim/AstroNvim) and [nvim-configs](https://github.com/NvChad/NvChad)
- Plugin authors and the Neovim community