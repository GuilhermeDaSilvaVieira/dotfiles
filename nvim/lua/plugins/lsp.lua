return {
  "neovim/nvim-lspconfig",
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",

    -- Useful status updates for LSP
    "j-hui/fidget.nvim",

    -- Additional lua configuration, makes nvim stuff amazing
    "folke/neodev.nvim",
  },
  config = function()
    local on_attach = function(_, bufnr)
      local nmap = function(keys, func, desc)
        if desc then
          desc = "LSP: " .. desc
        end
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
      end

      nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
      nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
      nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
      nmap(
        "gr",
        require("telescope.builtin").lsp_references,
        "[G]oto [R]eferences"
      )
      nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
      nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
      nmap(
        "<leader>ds",
        require("telescope.builtin").lsp_document_symbols,
        "[D]ocument [S]ymbols"
      )
      nmap("K", vim.lsp.buf.hover, "Hover Documentation")
      nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
      nmap("[d", vim.diagnostic.goto_prev, "Goto Previous Diagnostic")
      nmap("]d", vim.diagnostic.goto_next, "Goto Next Diagnostic")
      nmap("gl", vim.diagnostic.open_float, "Open Floating Diagnostic")
      -- Create a command `:Format` local to the LSP buffer
      vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
        vim.lsp.buf.format()
      end, { desc = "Format current buffer with LSP" })
    end
    -- Setup neovim lua configuration
    require("neodev").setup()

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

    -- Setup mason so it can manage external tooling
    require("mason").setup()

    local servers = {
      rust_analyzer = {},
      lua_ls = {
        Lua = {
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
          format = { enable = false },
          settings = { completion = { callSnippet = "Replace" } },
        },
      },
    }

    -- Ensure the servers above are installed
    local mason_lspconfig = require("mason-lspconfig")

    mason_lspconfig.setup({ ensure_installed = vim.tbl_keys(servers) })

    mason_lspconfig.setup_handlers({
      function(server_name)
        require("lspconfig")[server_name].setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = servers[server_name],
        })
      end,
    })

    -- Turn on lsp status information
    require("fidget").setup()
  end,
}