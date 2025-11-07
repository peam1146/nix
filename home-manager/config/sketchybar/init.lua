-- Require the sketchybar module
-- package.cpath = package.cpath .. ";${SBAR_CPATH}"
sbar = require("sketchybar")

function exec_shell(cmd)
    local file = io.popen(cmd)

    if not file then
        return
    end

    local output = file:read("*a")
    file:close()
    return output
end

-- Set the bar name, if you are using another bar instance than sketchybar
-- sbar.set_bar_name("bottom_bar")

-- Bundle the entire initial configuration into a single message to sketchybar
sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.end_config()

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
sbar.event_loop()
