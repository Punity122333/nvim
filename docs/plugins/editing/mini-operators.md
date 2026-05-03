# editing/mini-operators.lua

Source: `lua/plugins/editing/mini-operators.lua`

## Purpose
Adds custom operators for evaluation, exchange, multiply, replace, and sort.

## Plugins
- `nvim-mini/mini.nvim` (uses `mini.operators`)

## Configuration
- Operator prefixes: `gz=` (evaluate), `gzx` (exchange), `gzm` (multiply), `gzr` (replace/sort).
- Evaluation operator runs `load("return " .. expr)` and replaces with the result.
- `mini.operators` is configured explicitly via `setup()`.
