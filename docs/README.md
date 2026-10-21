# Neovim configuration

Documentation of this Neovim configuration (LazyVim-based).

## Layout

```
.
├── init.lua          the entry point: environment, theme, global commands
├── lua/
│   ├── config/       the core: options, keymaps, autocmds, palette, indent
│   ├── plugins/      one file per plugin spec (lazy.nvim)
│   └── snippet_engine/
├── after/            ftplugins and tree-sitter queries
├── docs/             this documentation
└── snippets/         the snippets of the snippet engine
```

## Documentation

- [init.lua](init.md) - the entry point
- [config/](config/index.md) - the core of the configuration
  - [lazy](config/lazy.md), [options](config/options.md),
    [autocmds](config/autocmds.md), [highlights](config/highlights.md),
    [treesitter](config/treesitter.md), [numbers](config/numbers.md),
    [keymaps](config/keymaps.md)
  - [indent width](config/indent-width.md),
    [indent predicates](config/indent-predicates.md),
    [clause close](config/clauseclose.md),
    [C++ indent](config/cpp-indent.md),
    [React indent](config/react-indent.md)
- [plugins/](plugins/index.md) - one page per plugin
- [snippet engine](snippet-engine.md) - the custom snippet engine
- [after/](after/index.md) - the ftplugins and the tree-sitter queries

## Conventions

Every page follows the same structure:

```
# <path of the file>

Source: `<path in the repository>`

## Purpose
What the file is for.

## Plugins
The repositories it configures.

## Configuration
What it actually does.
```

Sections called "Why ..." explain a decision that is not obvious from the
code - a workaround for a plugin bug, a trade-off, a constraint of the
terminal. They are the most useful part of the documentation, because the
code cannot explain *why* something looks strange.

## Principles of the configuration

- **One owner per concern.** A colour is defined in `config/highlights.lua`
  and nowhere else, an option in `config/options.lua`, the indentation width
  in `config/indent_width.lua`. The other files read them.
- **The plugin files own the plugin.** A setting that only makes sense for
  one plugin lives in that plugin's file in `lua/plugins/`, not in
  `lua/config/`.
- **Never replace a `config` function.** In lazy.nvim a user `config`
  *replaces* the one of LazyVim's extra, which silently drops the extra's
  own setup (mappings, DAP adapters, ...). `opts` is used instead.
- **The comments in the code are part of the documentation.** Most of the
  non-obvious decisions in this configuration are explained in a comment
  right next to them, usually with the error that motivated the change.
