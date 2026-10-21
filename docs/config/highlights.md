# config/highlights.lua

Source: `lua/config/highlights.lua`

## Purpose
The single owner of the palette and of every custom highlight group.

## Plugins
- None (core Neovim only).

## Configuration
### The palette
| Name | Value | Used for |
| --- | --- | --- |
| `background_primary` | `#1a1b26` | the background of the editor and of the floats |
| `background_secondary` | `#111116` | the background of the blink/noice popups |
| `foreground_primary` | `#cdd6f4` | the default text colour |
| `foreground_secondary` | `#bac2de` | dimmer text |
| `foreground_accent` | `#111116` | the window separators |
| `foreground_subtle` | `#232330` | borders |
| `selection_blue` | `#28344a` | selections, references, the cursor line |
| `status_line` | `#16161e` | the status line |
| `border` | `#27a1b9` | the border of every float |
| `cursor_fg` / `cursor_bg` | `#000000` / `#00ff00` | the cursor |
| `markdown_bold` | `#ff9e64` | bold markdown, `@mutable`, the bufferline "modified" |
| `unused_diagnostic` | `#6c7086` | `DiagnosticUnnecessary` |

`M.colors` is the table that `init.lua` uses, so that a colour is defined
exactly once.

### The groups
`M.apply()` sets the groups of the whole UI: the completion menu, the
`Pmenu`, the noice popups, the signature help, the bufferline (error /
warning / info / hint / modified, selected and unselected), the DAP UI, the
mason UI, the toggleterm floats, the snacks picker, the Avante popups and
the window separators.

`M.apply_overrides()` sets the groups that have to survive the re-tint loop
of `init.lua` (and a colorscheme change): `@markup.strong`,
`RenderMarkdownCode`, `LspReferenceRead`, the blink signature help groups,
the status line and the *selected* bufferline variants.

### Language tweaks
- `@keyword.repeat` and `@keyword.conditional` are linked to `@keyword`,
  `@bracket.square`/`paren`/`curly` get their own colours.
- `@module.python` is linked to `@type.python`, `@keyword.import.python` and
  `@keyword.import.rust` to `@keyword.conditional.python`.
- `@lsp.type.variable` and `@variable` get the LSP type colour.
- `@io.cout`/`@io.cin` are pink, `@io.endl` is the markdown bold colour.
- `@constructor.python` is bold, `@comment` is italic (not bold).
- `@keyword` is bold.

## Notes
- `M.apply()` runs when the module is loaded and `M.apply_overrides()` runs
  again from the `ThemeGodMode` augroup in `init.lua`: a colorscheme resets
  every group it owns, so the custom ones have to be re-applied whenever the
  colorscheme changes.
- `init.lua` owns the generic re-tint loop and the few groups that override
  it. Anything set here must **not** be set there as well - that is the
  rule that keeps a group in exactly one place.
- `'guicursor'` is set here: `n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor`.
  The cursor is drawn by the terminal, so Neovim only sends the colour
  (OSC 12) and kitty paints the block itself.
