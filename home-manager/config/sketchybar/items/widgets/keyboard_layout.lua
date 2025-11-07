local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- local current_keyboard_layout = exec_shell(
--     "defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep 'KeyboardLayout Name' | sed 's/.* = //;s/;//'")

local function trim(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

local abbr = nil

local keyboard_abbr = {
    ["Dvorak"] = "DV",
    ["ABC"] = "ABC",
    ["Thai"] = "TH"
}

-- local abbr = keyboard_abbr[trim(current_keyboard_layout)]

local keyboard_layout = sbar.add("item", "keyboard_layout", {
    position = "right",
    background = {
        color = colors.bg2,
        border_color = colors.black,
        border_width = 1
    },
    icon = {
        string = icons.keyboard,
        align = "left",
        padding_left = 8,
    },
    padding_left = 1,
    padding_right = 1,
    label = {
        align = "left",
        padding_right = 8,
    },
    update_freq = 1,
})

sbar.add("bracket", "keyboard_layout.bracket", {
    keyboard_layout.names
}, {
    background = { color = colors.bg1 },
    popup = { align = "center" }
})

sbar.add("item", "keyboard_layout.volume.padding", {
    position = "right",
    width = settings.group_paddings
})

-- TODO: Implement keyboard layout detection and update
keyboard_layout:subscribe("routine", function()
    local new_keyboard_layout = exec_shell(
        "defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep 'KeyboardLayout Name' | sed 's/.* = //;s/;//'")
    local new_abbr = keyboard_abbr[trim(new_keyboard_layout)]
    if new_abbr ~= abbr then
        abbr = new_abbr
        keyboard_layout:set({ label = abbr })
    end
end)
