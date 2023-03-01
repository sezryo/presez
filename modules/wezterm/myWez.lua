return {
  font = wezterm.font("JetBrains Mono"),
  font_size = 9.0,
  color_scheme = "Catppuccin Frappe",
  hide_tab_bar_if_only_one_tab = true,
  window_background_opacity = 0.7,
  tab_max_width = 12,
  default_prog = { 'nu' },
  disable_default_key_bindings = true,
  -- command_palette_font_size = 9.0, -- Needs Nightly builds

  -- Emacs styled keybinds
  keys = {
    { key = "w", mods = "ALT", action= wezterm.action.CopyTo "ClipboardAndPrimarySelection" },
    { key = 'y', mods = 'CTRL', action = wezterm.action.PasteFrom "PrimarySelection" },
    { key = '-', mods = 'CTRL', action = wezterm.action.DecreaseFontSize },
    { key = '=', mods = 'CTRL', action = wezterm.action.IncreaseFontSize },
    -- { key = 'P', mods = 'CTRL', action = wezterm.action.ActivateCommandPalette }, -- Needs Nightly builds
    { key = 'v', mods = 'ALT', action = wezterm.action.ScrollByPage(-1) },
    { key = 'v', mods = 'CTRL', action = wezterm.action.ScrollByPage(1) },
    { key = ',', mods = 'CTRL|SHIFT', action = wezterm.action.ScrollToTop },
    { key = '.', mods = 'CTRL|SHIFT', action = wezterm.action.ScrollToBottom },
    { key = 'x', mods = 'ALT', action = wezterm.action.ShowLauncher },
    { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain',},
    { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = false },},
    -- search for things that look like git hashes
    { key = 's', mods = 'CTRL|SHIFT', action = wezterm.action.Search { Regex = '[a-f0-9]{6,}', }, },
  },
}
