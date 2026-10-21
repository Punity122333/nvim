# snippet_engine/init.lua

Source: `lua/snippet_engine/init.lua`

## Purpose
A custom snippet engine that implements the LSP snippet syntax on top of
extmarks.

## Plugins
- `saghen/blink.cmp` (the engine is plugged into blink as its snippet
  source, see `lua/plugins/blink-cmp.lua`).
- `rafamadriz/friendly-snippets` (the snippet files).

## Configuration
The module is used through three functions:

| Function | Purpose |
| --- | --- |
| `M.expand(body)` | expand a snippet at the cursor |
| `M.jump(direction)` | jump to the next / previous tabstop |
| `M.active(direction)` | is there a tabstop to jump to? |
| `M.get_session()` | the current session |
| `M.destroy()` | tear the session stack down |

### The syntax
| Syntax | Meaning |
| --- | --- |
| `$1`, `${1}` | a tabstop |
| `${1:default}` | a tabstop with a default text |
| `$0` | the final cursor position |
| `${1\|a,b,c\|}` | a choice - the first entry is the default |
| `${1/regex/format/flags}` | a transform of another tabstop |
| `${1:+text}` / `${1:?then:else}` | conditional text |
| `${VAR}` | a variable (see below) |

Variables: `TM_FILENAME`, `TM_FILENAME_BASE`, `TM_DIRECTORY`, `TM_FILEPATH`,
`TM_LINE_NUMBER`, `TM_CURRENT_LINE`, `TM_CURRENT_WORD`, `CLIPBOARD`,
`CURRENT_YEAR`, `CURRENT_MONTH`, `CURRENT_DATE`.

Transform modifiers: `upcase`, `downcase`, `capitalize`, `camelcase`,
`pascalcase`. The flags are `g` (global) and `i` (ignore case).

### How it works
- The snippet is parsed into an AST and then **flattened** into the final
  text plus the list of the tabstops and the transforms (one pass, O(n)).
- The text is written to the buffer in a single `nvim_buf_set_text` call.
- Every tabstop gets an extmark in the `snip_engine` namespace; the
  extmark *is* the session state, so the position of the placeholders
  follows the edits of the user.
- The positions are computed with a binary search over the line starts
  (`byte_to_rowcol`).

### Mirroring
When the same tabstop index appears more than once, the text is mirrored:
a `TextChangedI` autocmd copies the content of the primary occurrence into
the others. The check is ordered cheapest-first (is the session the active
one? is the cursor inside the primary occurrence?), so the common case is
two integer comparisons.

### The session stack
Snippets can be expanded *inside* a snippet (that is what the LSP servers
do). Every expansion pushes a session onto a stack:

- `InsertLeave` pops the current session and resumes the parent one,
- `BufLeave` destroys the whole stack,
- `$0` (the final tabstop) pops the session when it is reached.

### The choice UI
A choice (`${1|a,b,c|}`) opens a small floating window next to the
placeholder. `<C-n>` / `<C-p>` change the selection (the text of the
placeholder is updated live), `<CR>` / `<Tab>` accept it and `<Esc>` accepts
the first entry and closes the window. The insert-mode mappings of the
buffer are saved and restored while the window is open.

## Why a custom engine
The stock `LuaSnip` / `vim.snippet` do not implement the LSP snippet syntax
completely, and the session stack (a snippet that expands another snippet)
is not supported by the built-in engine. The engine is written around
extmarks so that the placeholders survive the edits of the user without a
"session" that has to be kept in sync with the buffer.

## Notes
- The engine is loaded lazily by blink (`require("snippet_engine")` on the
  first expansion).
- `blink.cmp` is configured with `snippets.expand`, `snippets.active` and
  `snippets.jump` pointing at it, so `<Tab>` / `<S-Tab>` jump between the
  tabstops of the *active* session.
- The snippet files live in `snippets/` and are loaded by
  `friendly-snippets` (see `lua/plugins/blink-cmp.lua`, the
  `search_paths` option).
