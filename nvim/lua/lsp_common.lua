local M = {}

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

M.capabilities = capabilities

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
---@diagnostic disable-next-line: unused-local
function M.on_attach(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", bufopts)
    vim.keymap.set("n", "K", "<cmd>:Lspsaga hover_doc<cr>", { silent = true, desc = "lsp hover" })
    vim.keymap.set("n", "gh", "<cmd>Lspsaga hover_doc<CR>", bufopts)
    vim.keymap.set("n", "gs", "<cmd>Lspsaga lsp_finder<CR>", bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set("n", "<space>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set("n", "<space>rn", "<cmd>Lspsaga rename<CR>", bufopts)
    vim.keymap.set("n", "<F6>", "<cmd>Lspsaga rename<CR>", bufopts)
    vim.keymap.set("n", "<space>la", "<cmd>Lspsaga code_action<CR>", bufopts)
    vim.keymap.set("v", "<space>la", "<cmd><C-U>Lspsaga range_code_action<CR>", bufopts)
    vim.keymap.set("n", "<space>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", bufopts)
    vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_next<CR>", bufopts)
    vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", bufopts)
    vim.keymap.set("n", "[E", function()
        require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, bufopts)
    vim.keymap.set("n", "]E", function()
        require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, bufopts)
    vim.keymap.set("n", "<space>lf", function()
        vim.lsp.buf.format({ async = true })
    end, { noremap = true, silent = true, buffer = bufnr, desc = "lsp format" })
end

function M.add_bundle_exec(config, gem, dir)
    local ret_code = nil
    local jid = vim.fn.jobstart("bundle info " .. gem, {
        cwd = dir,
        on_exit = function(_, data)
            ret_code = data
        end,
    })
    vim.fn.jobwait({ jid }, 5000)
    if ret_code == 0 then
        table.insert(config.cmd, 1, "exec")
        table.insert(config.cmd, 1, "bundle")
    end
end

vim.keymap.set("n", "<space>lI", ":Mason<cr>", { silent = true, desc = "lsp installer" })
vim.keymap.set("n", "<space>li", ":LspInfo<cr>", { silent = true, desc = "lsp info" })
vim.keymap.set("n", "<space>b", "<C-o>", { silent = true, desc = "navigate back" })

return M
