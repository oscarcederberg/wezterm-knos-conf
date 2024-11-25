local wezterm = require("wezterm")
local module = {}

-- Apply Functions

local function apply_appearance(config)
  config.color_scheme = 'Gruvbox Dark (Gogh)'
  config.font = wezterm.font_with_fallback({
    "Noto Sans Mono",
    "Noto Color Emoji"
  })

  config.inactive_pane_hsb = {
    saturation = 0.75,
    brightness = 0.66,
  }

  config.window_background_opacity = 0.75

  config.use_fancy_tab_bar = false
  config.hide_tab_bar_if_only_one_tab = false
end

local function apply_bindings(config)
  local action = wezterm.action

  config.disable_default_key_bindings = true
  config.leader = { key = '\\', mods = 'ALT' }
  config.keys = {
    {
      key = 'c',
      mods = 'ALT',
      action = action.CopyTo 'ClipboardAndPrimarySelection'
    },
    {
      key = 'v',
      mods = 'ALT',
      action = action.PasteFrom 'Clipboard'
    },
    {
      key = 'l',
      mods = 'LEADER|SHIFT',
      action = action.ShowDebugOverlay
    },
    {
      key = 'r',
      mods = 'LEADER|SHIFT',
      action = action.Multiple({
        action.ReloadConfiguration,

        wezterm.action_callback(function(_, _)
          wezterm.plugin.update_all()
        end),
      })
    },
    {
      key = 'l',
      mods = 'LEADER',
      action = wezterm.action.ShowLauncherArgs { flags = 'WORKSPACES' },
    },
    {
      key = 'n',
      mods = 'LEADER',
      action = action.PromptInputLine {
        description = wezterm.format {
          { Attribute = { Intensity = 'Bold' } },
          { Foreground = { AnsiColor = 'Yellow' } },
          { Text = 'Enter name for new session' },
        },
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:perform_action(
              action.SwitchToWorkspace { name = line, },
              pane
            )
          end
        end),
      },
    },
    {
      key = "r",
      mods = "LEADER",
      action = action.PromptInputLine {
        description = wezterm.format {
          { Attribute = { Intensity = 'Bold' } },
          { Foreground = { AnsiColor = 'Yellow' } },
          { Text = 'Enter new name for session' },
        },
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            wezterm.mux.rename_workspace(
              wezterm.mux.get_active_workspace(),
              line
            )
          end
        end),
      },
    },
    {
      key = 'PageUp',
      mods = 'ALT',
      action = action.ScrollByPage(-1)
    },
    {
      key = 'PageDown',
      mods = 'ALT',
      action = action.ScrollByPage(1)
    },
    {
      key = 'UpArrow',
      mods = 'ALT',
      action = action.ScrollToPrompt(-1)
    },
    {
      key = 'DownArrow',
      mods = 'ALT',
      action = action.ScrollToPrompt(1)
    },
    {
      key = 'UpArrow',
      mods = 'CTRL|ALT',
      action = action.ScrollByLine(-1)
    },
    {
      key = 'DownArrow',
      mods = 'CTRL|ALT',
      action = action.ScrollByLine(1)
    },
    {
      key = '=',
      mods = 'CTRL',
      action = action.IncreaseFontSize,
    },
    {
      key = '-',
      mods = 'CTRL',
      action = action.DecreaseFontSize,
    },
    {
      key = '0',
      mods = 'CTRL',
      action = action.ResetFontSize,
    },
    {
      key = '\\',
      mods = 'CTRL',
      action = action.SplitVertical {},
    },
    {
      key = '|',
      mods = 'SHIFT|CTRL',
      action = action.SplitHorizontal {},
    },
    {
      key = 'q',
      mods = 'CTRL',
      action = action.CloseCurrentPane { confirm = false },
    },
    {
      key = 's',
      mods = 'SHIFT|CTRL',
      action = action.PaneSelect {
        alphabet = '1234567890',
        mode = 'SwapWithActive',
      },
    },
    {
      key = 'Tab',
      mods = 'CTRL',
      action = action.ActivatePaneDirection('Next'),
    },
    {
      key = 'Tab',
      mods = 'SHIFT|CTRL',
      action = action.ActivatePaneDirection('Prev'),
    },
    {
      key = 'f',
      mods = 'CTRL',
      action = action.TogglePaneZoomState,
    },
    {
      key = 't',
      mods = 'ALT',
      action = action.SpawnTab 'CurrentPaneDomain',
    },
    {
      key = 'q',
      mods = 'ALT',
      action = action.CloseCurrentTab { confirm = true },
    },
    {
      key = 'r',
      mods = 'ALT',
      action = action.PromptInputLine {
        description = wezterm.format {
          { Attribute = { Intensity = 'Bold' } },
          { Foreground = { AnsiColor = 'Yellow' } },
          { Text = 'Enter new name for tab' },
        },
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      },
    },
    {
      key = "Tab",
      mods = 'ALT',
      action = action.ActivateTabRelative(1),
    },
    {
      key = "Tab",
      mods = 'SHIFT|ALT',
      action = action.ActivateTabRelative(-1),
    },
  }

  for _, direction in pairs({ 'Left', 'Up', 'Right', 'Down' }) do
    table.insert(config.keys, {
      key = string.format('%sArrow', direction),
      mods = 'CTRL',
      action = action.ActivatePaneDirection(direction),
    }
    )

    table.insert(config.keys, {
      key = string.format('%sArrow', direction),
      mods = 'SHIFT|CTRL',
      action = action.AdjustPaneSize { direction, 1 },
    }
    )
  end

  for i = 1, 9 do
    table.insert(config.keys, {
      key = tostring(i),
      mods = 'ALT',
      action = action.ActivateTab(i - 1),
    })

    table.insert(config.keys, {
      key = tostring(i),
      mods = 'CTRL|ALT',
      action = action.MoveTab(i - 1),
    })
  end
end

local function apply_settings(config)
  config.initial_cols = 120
  config.initial_rows = 24

  config.warn_about_missing_glyphs = false
end

function module.apply_to_config(config)
  wezterm.log_info("applying knos-config")
  apply_appearance(config)
  apply_bindings(config)
  apply_settings(config)
end

return module
