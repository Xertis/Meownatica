local drawing = require "blueprint/logic/drawing"
local builder = require "blueprint/logic/builder"

local pid = hud.get_player()

input.add_callback("meownatica.build_hud-mark", function ()
    if not COMMON_GLOBALS.BUILD_HUD_OPEN then
        return
    end

    local x, y, z = player.get_selected_block(pid)

    drawing.draw(x, y, z)
end)

input.add_callback("meownatica.build_hud-move", function ()
    if not COMMON_GLOBALS.BUILD_HUD_OPEN then
        return
    end

    local x, y, z = player.get_selected_block(pid)
    if not x then return end
    local blue_print = BLUEPRINTS[CURRENT_BLUEPRINT.id]

    if blue_print then
        if CURRENT_BLUEPRINT.preview_pos[1] ~= nil then
            blue_print:unbuild_preview(CURRENT_BLUEPRINT.preview_pos)
        end

        if input.is_pressed("key:left-ctrl") then
            y = y + 1
        end

        local new_preview_pos = {x, y, z}
        blue_print:build_preview(new_preview_pos)
        CURRENT_BLUEPRINT.preview_pos = new_preview_pos
    end
end)

input.add_callback("meownatica.build_hud-build", function ()
    if not COMMON_GLOBALS.BUILD_HUD_OPEN then
        return
    end

    local blue_print = BLUEPRINTS[CURRENT_BLUEPRINT.id]

    if blue_print then
        if CURRENT_BLUEPRINT.preview_pos[1] == nil then
            return
        end

        builder.build(CURRENT_BLUEPRINT.preview_pos, 200, blue_print)
        CURRENT_BLUEPRINT.preview_pos = {}
    end
end)

input.add_callback("meownatica.build_hud-rotate", function ()
    if not COMMON_GLOBALS.BUILD_HUD_OPEN then
        return
    end

    if not CURRENT_BLUEPRINT then
        return
    end

    if CURRENT_BLUEPRINT.preview_pos[1] == nil then
        return
    end

    local blue_print = BLUEPRINTS[CURRENT_BLUEPRINT.id]

    if blue_print then
        hud.show_overlay("meownatica:build_hud_rotate", false)
    end
end)

input.add_callback("meownatica.menu", function ()
    hud.show_overlay("meownatica:meow_menu")
end)