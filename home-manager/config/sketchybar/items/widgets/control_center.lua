local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local control_center = sbar.add("item", "control_center", {
    position = "right",
    icon = {
        string = icons.control_center,
        padding_right = 8,
        padding_left = 8,
    },
    background = {
        color = colors.bg2,
        border_color = colors.black,
        border_width = 1
    },
    padding_left = 1,
    padding_right = 1,
    label = { drawing = false },
    click_script =
    "osascript -e 'tell application \"System Events\" to tell process \"Control Center\" to perform action \"AXPress\" of menu bar item 2 of menu bar 1'"
})

local volume_bracket = sbar.add("bracket", "control_center.bracket", {
    control_center.names
}, {
    background = { color = colors.bg1 },
    popup = { align = "center" }
})

sbar.add("item", "control_center.volume.padding", {
    position = "right",
    width = settings.group_paddings
})
