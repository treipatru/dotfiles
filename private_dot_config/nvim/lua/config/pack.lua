-- Glue around the built-in plugin manager (`:h vim.pack`).
-- Plugins are declared with vim.pack.add() in each lua/plugins/*.lua file; versions are pinned in nvim-pack-lock.json.

-- Build steps, run after a plugin is installed or updated.
-- Registered before the first vim.pack.add() so it also fires for fresh installs.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("user_pack_hooks", { clear = true }),
  callback = function(ev)
    local name, kind, path = ev.data.spec.name, ev.data.kind, ev.data.path
    if kind ~= "install" and kind ~= "update" then
      return
    end

    if name == "telescope-fzf-native.nvim" then
      vim.system({ "make" }, { cwd = path }):wait()
    elseif name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

local function plugin_names(arg_lead)
  return vim
    .iter(vim.pack.get(nil, { info = false }))
    :map(function(p)
      return p.spec.name
    end)
    :filter(function(name)
      return vim.startswith(name, arg_lead)
    end)
    :totable()
end

-- :PackUpdate [names...]  Fetch updates and open the review buffer (`:w` to apply, `:q` to discard)
vim.api.nvim_create_user_command("PackUpdate", function(cmd)
  vim.pack.update(#cmd.fargs > 0 and cmd.fargs or nil)
end, { nargs = "*", complete = plugin_names, desc = "Update plugins" })

-- :PackStatus  Show installed plugins and their revisions without fetching anything
vim.api.nvim_create_user_command("PackStatus", function()
  vim.pack.update(nil, { offline = true })
end, { desc = "Show plugin status" })

-- :PackClean  Delete plugins that are on disk but no longer declared in the config
vim.api.nvim_create_user_command("PackClean", function()
  local unused = vim
    .iter(vim.pack.get(nil, { info = false }))
    :filter(function(p)
      return not p.active
    end)
    :map(function(p)
      return p.spec.name
    end)
    :totable()

  if #unused == 0 then
    vim.notify("No unused plugins")
    return
  end
  if vim.fn.confirm("Delete unused plugins?\n" .. table.concat(unused, "\n"), "&Yes\n&No", 2) == 1 then
    vim.pack.del(unused)
  end
end, { desc = "Delete plugins no longer in the config" })
