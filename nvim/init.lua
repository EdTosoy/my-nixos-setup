-- ============================================================
-- Personal Neovim Config
-- Based on kickstart.nvim
-- NixOS | Real Programmers Dvorak | One Dark Pro
-- ============================================================

-- NixOS: the config dir is a symlink into the Nix store.
-- Neovim's rtp → package.path injection may not run before init.lua,
-- so we patch it explicitly here — must happen before any require().
local config = vim.fn.stdpath("config")
package.path = config .. "/lua/?.lua;" .. config .. "/lua/?/init.lua;" .. package.path

-- NOTE: leader must be set before lazy.nvim loads so all mappings use it
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.lazy")
