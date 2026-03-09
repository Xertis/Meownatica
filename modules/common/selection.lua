--By SlivaPiva
--Ну и мои изменения

local Select = {}

local Selections = {}
local NextSelectionId = 1
local zfight = 0.001

local function dcoords(x1, y1, z1, x2, y2, z2)
    local minX, maxX = math.min(x1, x2), math.max(x1, x2)
    local minY, maxY = math.min(y1, y2), math.max(y1, y2)
    local minZ, maxZ = math.min(z1, z2), math.max(z1, z2)
    return minX, maxX, minY, maxY, minZ, maxZ,
           (x2 >= x1 and 1 or -1),
           (y2 >= y1 and 1 or -1),
           (z2 >= z1 and 1 or -1)
end

local function loc(x, y, z, maxY, col, rot, selection_id)
    rot = rot or {false, false, false}
    local text_scale = 1 / 7

    local text_table = {
        scale = text_scale,
        xray_opacity = 1,
        render_distance = 1000,
        color = col
    }

    local function add_text(t_pos, t_rot, t_str)
        local tid = gfx.text3d.show(t_pos, t_str, text_table)
        gfx.text3d.set_rotation(tid, t_rot)
        Selections[selection_id][#Selections[selection_id] + 1] = tid
    end

    if rot[3] then
        if rot[1] then -- maxX
            if rot[2] then -- maxZ
                add_text({ x + 1 + (1 / 7), y - (1 / 7), z + 1 + zfight}, mat4.rotate(mat4.rotate({0, 0, 1}, 90), {0, 1, 0}, 0), " _")
                add_text({ x + 1 + zfight, y, z + 1 + (1 / 7)}, mat4.rotate(mat4.rotate({0, 0, 1}, 270), {1, 0, 0}, 270), "_ ")
            else -- minZ
                add_text({ x + 1 + (1 / 7), y, z - zfight}, mat4.rotate(mat4.rotate({0, 0, 1}, 90), {0, 1, 0}, 180), "_ ")
                add_text({ x + 1 + zfight, y, z + (1 / 7) + (1 / 7)}, mat4.rotate(mat4.rotate({0, 0, 1}, 270), {1, 0, 0}, 270), "_ ")
            end
        else -- minX
            if rot[2] then -- maxZ
                add_text({ x + (1 / 7) + (1 / 7), y - (1 / 7), z + 1 + zfight}, mat4.rotate(mat4.rotate({0, 0, 1}, 90), {0, 1, 0}, 0), " _")
                add_text({ x - zfight, y - (1 / 7), z + 1 + (1 / 7)}, mat4.rotate(mat4.rotate({0, 0, 1}, 90), {1, 0, 0}, 270), " _")
            else -- minZ
                add_text({ x + (1 / 7) + (1 / 7), y, z - zfight}, mat4.rotate(mat4.rotate({0, 0, 1}, 90), {0, 1, 0}, 180), "_ ")
                add_text({ x - zfight, y - (1 / 7), z + (1 / 7) + (1 / 7)}, mat4.rotate(mat4.rotate({0, 0, 1}, 90), {1, 0, 0}, 270), " _")
            end
        end
    else
        local py = y
        if py == maxY then
            py = py + 1 - (1/7) - (1/7)
        else
            py = py - (1/7)
        end

        if rot[1] then
            -- Вдоль оси X
            if rot[2] then -- maxZ
                add_text({ x - (1 / 7), py, z + 1 + zfight}, mat4.rotate({0, 1, 0}, 0), " _")
                add_text({ x, py, z + 1 - zfight}, mat4.rotate({0, 1, 0}, 180), "_ ")
            else -- minZ
                add_text({ x - (1 / 7), py, z + zfight}, mat4.rotate({0, 1, 0}, 0), " _")
                add_text({ x, py, z - zfight}, mat4.rotate({0, 1, 0}, 180), "_ ")
            end
        else
            -- Вдоль оси Z
            if rot[2] then -- maxX
                add_text({ x + 1 + zfight, py, z}, mat4.rotate({0, 1, 0}, 90), "_ ")
                add_text({ x + 1 - zfight, py, z - (1 / 7)}, mat4.rotate({0, 1, 0}, 270), " _")
            else -- minX
                add_text({ x + zfight, py, z }, mat4.rotate({0, 1, 0}, 90), "_ ")
                add_text({ x - zfight, py, z - (1 / 7)}, mat4.rotate({0, 1, 0}, 270), " _")
            end
        end
    end
end

function Select.sel(x1, y1, z1, x2, y2, z2, col)
    local selection_id = NextSelectionId
    NextSelectionId = NextSelectionId + 1

    Selections[selection_id] = {}

    local minX, maxX, minY, maxY, minZ, maxZ,
          sx, sy, sz = dcoords(x1, y1, z1, x2, y2, z2)

    local rot  = {true, true, false}

    rot[1] = true
    for x = minX, maxX do
        rot[2] = false
        loc(x, minY, minZ, maxY, col, rot, selection_id)
        loc(x, maxY, minZ, maxY, col, rot, selection_id)
        rot[2] = true
        loc(x, minY, maxZ, maxY, col, rot, selection_id)
        loc(x, maxY, maxZ, maxY, col, rot, selection_id)
    end

    rot[1] = false
    for z = minZ, maxZ do
        rot[2] = true
        loc(maxX, minY, z, maxY, col, rot, selection_id)
        loc(maxX, maxY, z, maxY, col, rot, selection_id)
        rot[2] = false
        loc(minX, minY, z, maxY, col, rot, selection_id)
        loc(minX, maxY, z, maxY, col, rot, selection_id)
    end
    rot[3] = true
    for y = minY, maxY do
        rot[1] = false
        rot[2] = false
        loc(minX, y, minZ, maxY, col, rot, selection_id)
        rot[1] = true
        rot[2] = false
        loc(maxX, y, minZ, maxY, col, rot, selection_id)
        rot[1] = false
        rot[2] = true
        loc(minX, y, maxZ, maxY, col, rot, selection_id)
        rot[1] = true
        rot[2] = true
        loc(maxX, y, maxZ, maxY, col, rot, selection_id)
    end

    return selection_id
end

function Select.desel(selection_id)
    if not selection_id then
        return
    end

    local selection = Selections[selection_id]
    if selection then
        for _, tid in ipairs(selection) do
            gfx.text3d.hide(tid)
        end
        Selections[selection_id] = nil
    end
end

function Select.dot(x, y, z, col)
    local selection_id = NextSelectionId
    NextSelectionId = NextSelectionId + 1
    Selections[selection_id] = {}

    local display = "static_billboard"

    if MEOW_CONFIG.sliced_preview then
        display = "xy_free_billboard"
    end

    local function showdot(text_pos, text_rot, text)
        local text_scale = 1/16
        local text_table = {
            scale = text_scale,
            xray_opacity = 0,
            render_distance = 250,
            color = col,
            display = display
        }
        local tid = gfx.text3d.show(text_pos, text, text_table)
        gfx.text3d.set_rotation(tid, text_rot)
        Selections[selection_id][#Selections[selection_id] + 1] = tid
    end

    local text_rot = mat4.rotate({0, 1, 0}, 0)
    local text_pos = {x - 0.5, y+1, z+1-0.001}
    local text = "   ∟"
    showdot(text_pos, text_rot, text)

    if MEOW_CONFIG.sliced_preview then
        return selection_id
    end

    text_rot = mat4.rotate({0, 1, 0}, 180)
    text_pos = {x + 0.5, y+1, z+zfight}
    text = "∟ "
    showdot(text_pos, text_rot, text)

    text_rot = mat4.rotate({0, 1, 0}, 90)
    text_pos = {x+1-zfight, y+1, z + 0.5}
    text = "∟ "
    showdot(text_pos, text_rot, text)

    text_rot = mat4.rotate({0, 1, 0}, 270)
    text_pos = {x+zfight, y+1, z - 0.5}
    text = "   ∟"
    showdot(text_pos, text_rot, text)

    text_rot = mat4.rotate({1, 0, 0}, 90)
    text_pos = {x - 0.5, y+zfight + 1, z}
    text = "   ∟"
    showdot(text_pos, text_rot, text)

    text_rot = mat4.rotate({1, 0, 0}, 270)
    text_pos = {x - 0.5, y+2-zfight, z + 1}
    text = "   ∟"
    showdot(text_pos, text_rot, text)

    return selection_id
end

return Select