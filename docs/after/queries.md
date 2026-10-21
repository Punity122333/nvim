# after/queries.md

Source: `after/queries/**/*.scm`

## Purpose
Tree-sitter query overrides. `after/queries/` is the last entry of the runtime path, so
these files are read after the ones shipped by `nvim-treesitter` and win wherever they
capture a node.

## Contents
- **230 `highlights.scm` files**, one per language directory. 215 of them are byte-identical
  and only add the bracket captures (`"[" @bracket.square`, `"(" @bracket.paren`,
  `"{" @bracket.curly` and their closing counterparts) on top of the nvim-treesitter
  query.
- **Bracket subsets** for the languages whose grammar does not use all three bracket
  kinds: `json`, `json5`, `jsdoc`, `toml`, `yaml` (square + curly), `query`, `sql`,
  `xml` (square + paren), `gitattributes`, `git_config`, `gitignore`, `vue` (square only).
- **`cmake/highlights.scm`** - paren and curly only; the CMake grammar has no separate
  `[` / `]` tokens, square brackets are part of `(unquoted_argument)`.
- **`cpp/highlights.scm`** - the six bracket captures plus `"mutable" @mutable` and the
  iostream identifiers `cout`, `cin`, `endl` captured as `@io.cout`, `@io.cin`, `@io.endl`.
- **`python/highlights.scm`** - the six bracket captures plus `(comment) @comment` with
  `(#set! priority 110)`, i.e. an extmark priority above the tree-sitter default of 100,
  so the comment wins over the captures it overlaps.
- **4 `injections.scm` files**: `js`, `jsx`, `tsx`, `typescript`. They inject a sub-language
  into tagged template literals and magic comments - `/* css */` and `` css` ` `` /
  `` styled.div` ` `` / `` styled(C)` ` become `scss`, `/* html */` and `` html` ` `` become
  `html`, `/* sql */` becomes `sql`, and `/* graphql */` plus the `` sql` ``/`SQL`/`gql`/
  `graphql` tags become `graphql`. All of them set `injection.include-children`.

## Notes
- Every file starts with `;; extends` (the `; extends` in the injection files works as
  well). That modeline marks the file as an *extension*: the nvim-treesitter query is
  loaded first and these patterns are appended, so the file adds captures instead of
  replacing the whole query. The appended patterns are applied last and overwrite the base
  capture on the same range, which is what makes the bracket overrides effective.
- The point of the override is coloured brackets. nvim-treesitter captures brackets as
  `@punctuation.bracket` / `@punctuation.special` / `@punctuation.delimiter`; the extra
  captures give them the dedicated groups `@bracket.square` (`#7aa2f7`), `@bracket.paren`
  (`#f38ba8`) and `@bracket.curly` (`#fab387`), which are set in
  `lua/config/highlights.lua`.
- The number of languages is large because tree-sitter grammars do not share a common
  bracket node; without one file per grammar the brackets would stay monochrome in most
  languages.
- `js/injections.scm` is the same content as `jsx/injections.scm` minus the `; extends`
  modeline; the JavaScript parser itself is installed as `javascript`, which only has the
  highlight override.
