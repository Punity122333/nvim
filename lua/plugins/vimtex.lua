return {
    "lervag/vimtex",
    lazy = false,
    init = function()
        -- Disable all syntax concealment
        vim.g.vimtex_syntax_conceal = {
            additions = 0,
            consecutive_stops = 0,
            definitions = 0,
            delimited = 0,
            greek = 0,
            math_bounds = 0,
            math_delimiters = 0,
            math_fracs = 0,
            math_symbols = 0,
            math_super_sub = 0,
            sections = 0,
            styles = 0,
        }
        vim.g.vimtex_syntax_conceal_disable = 1
        vim.g.vimtex_syntax_enabled = 1

        -- Indentation (must be set before vimtex's ftplugin reads them)
        vim.g.vimtex_indent_enabled = 1
        vim.g.vimtex_indent_bib_enabled = 1
        vim.g.vimtex_indent_on_ampersands = 1
        vim.g.vimtex_indent_ignored_envs = { "document" }
        vim.g.vimtex_indent_lists = { "itemize", "enumerate", "description", "thebibliography" }
        vim.g.vimtex_indent_commands = {
            ["\\section"] = { indent = 1 },
            ["\\subsection"] = { indent = 1 },
            ["\\subsubsection"] = { indent = 1 },
        }

        -- Disable the default ]] insert mapping (causes input lag due to
        -- the two-character wait). We remap its action to <C-=> in tex.lua.
        vim.g.vimtex_mappings_disable = { i = { ']]' } }

        -- PDF viewer: zathura. It is linked against libsynctex, so forward
        -- search (\ll jumps to the right page) and inverse search (clicking in
        -- zathura jumps back to the source line) both work. The
        -- 'zathura_simple' variant needs no xdotool; install xdotool and use
        -- 'zathura' instead to reuse a single window instance.
        vim.g.vimtex_view_method = "zathura_simple"

        -- latexmk (from texlive, already installed) reruns bibtex/aux as
        -- needed, which plain pdflatex does not. Fall back to texmf if it
        -- ever goes missing.
        if vim.fn.executable("latexmk") == 1 then
            vim.g.vimtex_compiler_method = "latexmk"
        end
    end,
}
