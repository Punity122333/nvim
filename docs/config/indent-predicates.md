# config/indent_predicates.lua

Source: `lua/config/indent_predicates.lua`

## Purpose
Registers an extra tree-sitter query predicate.

## Plugins
- `nvim-treesitter/nvim-treesitter` (the queries that use it).

## Configuration
`M.setup()` registers the predicate `not-kind-eq?` with
`vim.treesitter.query.add_predicate`:

```scm
((identifier) @foo (#not-kind-eq? @foo "string" "comment"))
```

It matches when **none** of the captured nodes has one of the given kinds.
A capture without any node also matches.

`setup()` is called from `init.lua`, right after `config.lazy` and
`config.highlights`.

## Why it is needed
The predicate is used by the *indent* queries of nvim-treesitter:
`c`, `ecma`, `groovy`, `ispc`, `ocaml`, `r`, `snl` and `swift`. Without the
registration those queries fail to load, and the indentation of those
languages breaks (the query error is reported by `:checkhealth`).

## Notes
- The registration is wrapped in `pcall`, so a Neovim version without
  `vim.treesitter.query.add_predicate` does not break the startup.
- It has to be registered *before* the first indent query is used, which is
  why it happens in `init.lua` and not in the tree-sitter plugin file.
