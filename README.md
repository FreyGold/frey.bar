# Frey Bar

A customizable Omarchy top bar with a Simple/Advanced appearance editor.

- Original, Pill, Soft, and Sharp styles with animated transitions.
- Adjustable opacity, widget spacing, padding, corner radius, borders, shadows, and hover highlights.
- Theme, automatic, white, black, and custom text/icon colors.
- Custom background and accent colors; optional background blur.
- Minimal, Glass, and Solid presets; save and delete your own named styles.
- Live preview, Undo changes, and Reset to original.

Right-click the bar to open the editor. Scroll in Advanced to reach more controls; scrolling over a slider does not change its value. Click or drag a slider to adjust it. Text fields accept keyboard input; Escape closes the editor.

Simple includes a toggle to hide the appearance gear while retaining right-click access. Advanced organizes controls into Background, Text & icons, Border, Spacing & shape, and Effects categories. Selecting a style in Simple restores that style's default corner radius, so a saved radius override cannot hide the difference between Pill, Soft, and Sharp.

## Install

Tested on Omarchy 4.0.4 with the Lua Hyprland configuration and Quickshell's KeyboardPanel component. Older shell versions may lack required UI components.

Full setup, including wallpaper sampling dependencies and optional blur integration:

```bash
curl -fsSL https://raw.githubusercontent.com/FreyGold/frey.bar/main/install.sh | bash
```

The installer uses Omarchy's plugin manager, backs up `shell.json` and `hyprland.lua`, preserves your widget layout, and prints a command for restoring the previous configuration. It installs `python-pillow` through Omarchy if missing. It does not import the author's personal layout or widgets. New appearance settings default to Pill, 70% opacity, and automatic text contrast; existing appearance settings are retained.

To review the installer first:

```bash
curl -fsSL https://raw.githubusercontent.com/FreyGold/frey.bar/main/install.sh -o install-frey-bar.sh
less install-frey-bar.sh
bash install-frey-bar.sh
```

For installation through Omarchy alone:

```bash
omarchy plugin add https://github.com/FreyGold/frey.bar.git --enable --yes
```

The native command installs the bar but does not configure the optional blur rule or install Python Pillow. Use the full installer for those features.

## Update

```bash
omarchy plugin update frey.bar
omarchy restart shell
```

## Switch back or restore

Switch to the stock bar without deleting this plugin:

```bash
omarchy plugin enable omarchy.bar
hyprctl eval 'if frey_bar_glass_rule then frey_bar_glass_rule:set_enabled(false) end'
omarchy restart shell
```

To restore your original configuration, run the `restore.sh` from the backup directory printed during installation. This replaces the entire backed-up shell and Hyprland configuration; later changes to those files will be replaced too. The plugin files remain installed.

Remove the plugin after switching away from it:

```bash
omarchy plugin remove frey.bar --yes
```

The Hyprland integration checks whether the plugin rule file exists, so removing the plugin does not leave a broken include.

## Notes

Auto chooses a single black or white foreground using the wallpaper strip behind the primary monitor's bar, blended with background color and opacity. It does not sample application windows or choose a separate foreground for each widget.

Shape, borders, and shadows apply to widget styles; Original retains the continuous stock surface. Blur is most visible below 100% opacity. The dedicated Blur tab includes an enable switch and a strength slider (1–20). Strength changes Hyprland's shared blur size, so it also affects other blurred windows and panels; settings persist across shell restarts and Hyprland reloads. Accent color applies to the focused workspace, active widget states, and appearance editor selections. Widgets that hard-code their own colors may not follow it.

Settings are stored under `bar` in `~/.config/omarchy/shell.json`. The bar uses installed Omarchy shell components and may need updates when their APIs change.

## Credits

Based on the [Omarchy](https://github.com/basecamp/omarchy) bar, distributed under its [MIT license](https://github.com/basecamp/omarchy/blob/master/LICENSE). Customizations by FreyGold. The original license notice is retained in LICENSE.
