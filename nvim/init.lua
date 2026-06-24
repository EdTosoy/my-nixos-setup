-- ============================================================
-- Personal Neovim Config
-- NixOS | Dvorak | GitHub Dark Dimmed
-- ============================================================

-- NixOS: ~/.config/nvim is a symlink into the read-only Nix store.
-- Neovim's rtp → package.path injection may not fire before init.lua,
-- so we patch it explicitly — must happen before any require().
local config = vim.fn.stdpath("config")
package.path = config .. "/lua/?.lua;" .. config .. "/lua/?/init.lua;" .. package.path

-- Leader must be set before lazy loads so all mappings use it
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.lazy")
