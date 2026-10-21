# config/react_indent.lua

Source: `lua/config/react_indent.lua`

## Purpose
The `indentexpr` of the JSX/TSX buffers: it indents the HTML part of a
React component by the nesting depth of the JSX tags.

## Plugins
- `nvim-treesitter/nvim-treesitter` (the tree-sitter parse of the buffer).

## Configuration
`M.indentexpr()` is installed as the `'indentexpr'` of the `javascript`,
`typescript`, `javascriptreact` and `typescriptreact` buffers.

### How it works
1. The *smallest* injected tree that contains the cursor is found (the
   comment/doc trees are ignored). For a `.tsx` file that is the `html`
   tree, for a `.scss` file the `scss` tree.
2. If the tree is `html` (or `scss`/`css`), the indentation is computed
   from the *text* of the lines between the start of the tree and the
   cursor:
   - a small scanner walks the lines and counts the opening and closing
     tags,
   - strings (`'`, `"`), block comments (`/* */`), line comments (`//`) and
     template interpolations (`${...}`) are skipped, so a `<div>` inside a
     string does not count,
   - void elements (`br`, `hr`, `img`, `input`, `meta`, `link`, `source`,
     `wbr`, `area`, `base`, `col`, `embed`, `track`, `param`) do not open a
     level.
3. The result is `outer indent + (depth + 1) * shiftwidth`. A closing tag
   (`</...`) is one level less.
4. A line that starts with a backtick (a template literal) is indented like
   the outer level.
5. Everything else falls back to the normal tree-sitter indent
   (`LazyVim.treesitter.indentexpr()`, falling back to
   `nvim-treesitter.indentexpr()`).

### Limits
- If the line is more than **120 lines** away from the start of the tree, the
  fallback is used (the scan would be too expensive).
- Only the JS/TS filetypes are handled; everything else uses the fallback.

## Notes
- `M.setup()` is called from `lua/config/autocmds.lua`. It sets the option
  for the buffers that are already open and for the new ones (on
  `FileType`, scheduled so that it does not run in the middle of the event).
- The indentation width comes from `lua/config/indent_width.lua`.
- The CSS/SCSS branch is the same algorithm with `{` / `}` instead of the
  tags, and it handles the block comments.
