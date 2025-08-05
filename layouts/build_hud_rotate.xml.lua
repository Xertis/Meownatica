local Blueprint = nil
local autorotate_status = false
local snap = false

function on_open()
    snap = true
    autorotate_status = true

    autorotate()
    snap_step()
    local index = CURRENT_BLUEPRINT.id
    local blueprint = BLUEPRINTS[index]

    if not blueprint then hud.close("build_hud_rotate") return end

    Blueprint = blueprint

    document["text_axis_x"].text = tostring(blueprint.rotation_vector[1])
    document["text_axis_y"].text = tostring(blueprint.rotation_vector[2])
    document["text_axis_z"].text = tostring(blueprint.rotation_vector[3])

    document["track_axis_x"].value = blueprint.rotation_vector[1]
    document["track_axis_y"].value= blueprint.rotation_vector[2]
    document["track_axis_z"].value = blueprint.rotation_vector[3]

    document["track_axis_x"].step = 1
    document["track_axis_y"].step = 1
    document["track_axis_z"].step = 1
end

local function rotate_blueprint()
    if not Blueprint then return end

    if CURRENT_BLUEPRINT.preview_pos[1] == nil then
        return
    end

    Blueprint:unbuild_preview(CURRENT_BLUEPRINT.preview_pos)
    Blueprint:rotate({
        document["track_axis_x"].value,
        document["track_axis_y"].value,
        document["track_axis_z"].value
    })
    Blueprint:build_preview(CURRENT_BLUEPRINT.preview_pos)
end

function axis_x(value)
    document["text_axis_x"].text = tostring(value)
    if autorotate_status then rotate_blueprint() end
end

function axis_y(value)
    document["text_axis_y"].text = tostring(value)
    if autorotate_status then rotate_blueprint() end
end

function axis_z(value)
    document["text_axis_z"].text = tostring(value)
    if autorotate_status then rotate_blueprint() end
end

---

function axis_x_text(value)
    if not axis_validator(value) then return end
    document["track_axis_x"].value = tonumber(value)
    if autorotate_status then rotate_blueprint() end
end

function axis_y_text(value)
    if not axis_validator(value) then return end
    document["track_axis_y"].value = tonumber(value)
    if autorotate_status then rotate_blueprint() end
end

function axis_z_text(value)
    if not axis_validator(value) then return end
    document["track_axis_z"].value = tonumber(value)
    if autorotate_status then rotate_blueprint() end
end

function axis_validator(text)
    if #text > 4 then
        return false
    end

    local status, res = pcall(tonumber, text)
    if not status or not res then
        return false
    end

    local number = tonumber(text)
    if number > 360 or number < 0 then
        return false
    end

    return true
end

function apply()
    --hud.close("meownatica:build_hud_rotate")
    rotate_blueprint()
end

function autorotate()
    autorotate_status = not autorotate_status
    local status = nil
    if autorotate_status then
        status = gui.str("meownatica.menu.on", "meownatica")
        document.apply.text = gui.str("meownatica.menu.close", "meownatica")
    else
        status = gui.str("meownatica.menu.off", "meownatica")
        document.apply.text = gui.str("meownatica.menu-rotate-apply", "meownatica")
    end
    document.autorotate.text = gui.str("meownatica.menu-rotate-auto", "meownatica") .. ': ' .. status
end

function snap_step()
    snap = not snap

    local step = 1
    if snap then step = 90 end

    local status = nil
    if snap then
        status = gui.str("meownatica.menu.on", "meownatica")
    else
        status = gui.str("meownatica.menu.off", "meownatica")
    end

    document.snap_step.text = gui.str("meownatica.menu-rotate-snap", "meownatica") .. ': ' .. status
    document["track_axis_x"].step = step
    document["track_axis_y"].step = step
    document["track_axis_z"].step = step
end