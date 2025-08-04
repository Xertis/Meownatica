
function place_keybind(panel, key_info)
    key_info.key = string.upper(key_info.key)
    panel:add(gui.template("build_hud_key", key_info))
    local key = document["key_" .. key_info.id]
    key.pos = {key_info.id*100, 0}
end

function on_open()
    COMMON_GLOBALS.BUILD_HUD_OPEN = true

    local PID = hud.get_player()
    local SELECTED_BLUEPRINT_TEXT = gui.str("meownatica.build-hud-selected-blueprint", "meownatica")
    local DISTANCE_PREVIEW_TEXT = gui.str("meownatica.build-hud-distance-preview", "meownatica")
    local DISTANCE_BLOCKS_TEXT = gui.str("meownatica.distance-blocks", "meownatica")

    place_keybind(document.root, {
        id = 0,
        head = "Build",
        key = '-' .. input.get_binding_text("meownatica.build_hud-build") .. '-'
    })
    place_keybind(document.root, {
        id = 1,
        head = "Move",
        key = '-' .. input.get_binding_text("meownatica.build_hud-move") .. '-'
    })
    place_keybind(document.root, {
        id = 2,
        head = "Rotate",
        key = '-' .. input.get_binding_text("meownatica.build_hud-rotate") .. '-'
    })
    place_keybind(document.root, {
        id = 3,
        head = "Mark",
        key = '-' .. input.get_binding_text("meownatica.build_hud-mark") .. '-'
    })
    place_keybind(document.root, {
        id = 4,
        head = "Select",
        key = '-' .. input.get_binding_text("meownatica.build_hud-select") .. '-'
    })

    document.root:setInterval(100, function ()
        local index = CURRENT_BLUEPRINT.id
        local blueprint = BLUEPRINTS[index]
        if blueprint then
            document.selected_blueprint.text = string.format("%s: %s [%s]", SELECTED_BLUEPRINT_TEXT, blueprint.name, index)
        else
            document.selected_blueprint.text = SELECTED_BLUEPRINT_TEXT .. ": nil"
        end

        if not blueprint or CURRENT_BLUEPRINT.preview_pos[1] == nil then
            document.distance_preview.visible = false
        else
            document.distance_preview.visible = true
            document.distance_preview.text = string.format("%s: %s %s [%s, %s, %s]",
                DISTANCE_PREVIEW_TEXT,
                math.round(utils.math.euclidian3D({player.get_pos(PID)}, CURRENT_BLUEPRINT.preview_pos)),
                DISTANCE_BLOCKS_TEXT,
                CURRENT_BLUEPRINT.preview_pos[1], CURRENT_BLUEPRINT.preview_pos[2], CURRENT_BLUEPRINT.preview_pos[3]
            )
        end
    end)
end

function on_close()
    COMMON_GLOBALS.BUILD_HUD_OPEN = false
end