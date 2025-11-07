local cjson = require("cjson")

function exec_shell(cmd)
    local file = io.popen(cmd)

    if not file then
        return
    end

    local output = file:read("*a")
    file:close()
    return output
end

function ensure_yabai_space()
    local displays_json = exec_shell("yabai -m query --displays")
    local displays = cjson.decode(displays_json)
    local display_spaces = {
        ["1"] = 6,
        ["2"] = 2,
    }

    for _, display in ipairs(displays) do
        local len = #display.spaces
        local limit_spaces = display_spaces[display.id]

        if len < limit_spaces then
            for i = 1, limit_spaces - len do
                exec_shell("yabai -m space --create && yabai -m space --display " .. display.id)
            end
        elseif len > limit_spaces then
            for i = 1, len - limit_spaces do
                exec_shell("yabai -m space --destroy " .. limit_spaces + 1)
            end
        end
    end
end

ensure_yabai_space();
