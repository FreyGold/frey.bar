-- Loaded by the installer from the user's Hyprland configuration.
frey_bar_glass_rule = hl.layer_rule({
  name = "frey-bar-glass",
  match = { namespace = "^omarchy-bar$" },
  blur = true,
  ignore_alpha = 0.001,
})
local config_file = io.open(os.getenv("HOME") .. "/.config/omarchy/shell.json", "r")
local enabled = false
if config_file then
  local text = config_file:read("*a")
  config_file:close()
  enabled = text:match('"id"%s*:%s*"frey%.bar"') ~= nil
    and text:match('"blurEnabled"%s*:%s*(%a+)') == "true"
end
frey_bar_glass_rule:set_enabled(enabled)
