return {
  "jmbuhr/otter.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = { "html", "htmldjango" },
  opts = {
    lsp = {
      diagnostic_update_events = { "BufWritePost", "InsertLeave" },
      root_dir = function(_, bufnr)
        return vim.fs.root(bufnr or 0, { ".git", "package.json" }) or vim.fn.getcwd()
      end,
    },
    buffers = {
      set_filetype = true,
      write_to_disk = false,
    },
    handle_leading_whitespace = true,
    verbose = { no_code_found = true }, -- turn on temporarily to debug
  },
  config = function(_, opts)
    require("otter").setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("otter_embedded_js", { clear = true }),
      pattern = { "html", "htmldjango" },
      callback = function()
        require("otter").activate({ "javascript" }, true, true)
      end,
    })
  end,
}



