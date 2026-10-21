# config/clauseclose.lua

Source: `lua/config/clauseclose.lua`

## Purpose
Closes the block when `<CR>` is pressed at the end of a block opener.

## Plugins
- `L3MON4D3/LuaSnip` (`vim.snippet.expand` is used to insert the closing
  keyword).

## Configuration
`<CR>` is remapped (per buffer, per filetype) to check the text before the
cursor against the rules of the filetype. If a rule matches, the closing
keyword is inserted through the snippet engine, with the cursor in the
middle of it (`\n\t$0\n<close>`).

### Rules
| Language | Openers |
| --- | --- |
| `lua` | `{`, `then`, `do`, `function`, `repeat` (`until`) |
| `sh`, `bash`, `zsh` | `{`, `then`, `do`, `in` (`esac`) |
| `vim` | `if`, `for`, `while`, `function`, `augroup`, `try`, `lua` |
| `cobol` | `then`, `perform`, `evaluate` |
| `fortran` | `then`, `do`, `where` |
| `pascal`, `ada` | `begin`, `then`, `loop` |
| `sql`, `plsql`, `postgres` | `begin`, `then`, `loop` |
| `ruby` | `if`, `unless`, `def`, `class`, `module`, `do`, `while`, `for`, `begin` |
| `php` | `foreach`, `if`, `for`, `while`, `switch`, `function`, `do` |

`bash` and `zsh` share the shell rules, `ada` the Pascal rules, `plsql` and
`postgres` the SQL rules.

## Why the tree-sitter check
The rules are matched against the text before the cursor, so `if` inside a
string or a comment would trigger the closing keyword. The tree-sitter node
under the cursor is therefore walked up: when a string or a comment is found
on the way, the `<CR>` is inserted as usual.

The tree-sitter walk only happens when a pattern actually fires - the check
is the expensive part, the pattern match is cheap.

## Notes
- The module is required by `lua/config/autocmds.lua`, so the mappings exist
  before the first buffer is opened.
- The mappings are buffer-local (`buffer = args.buf`), so two buffers with
  different filetypes do not fight over `<CR>`.
