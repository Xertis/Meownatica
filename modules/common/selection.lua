--By SlivaPiva
--Ну и мои изменения

local Select = {}

local Selections = {}
local NextSelectionId = 1

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

    local text_pos, text_rot

    if rot[1] then
        text_pos = { x + (4 / 7) + 1, y + 1, z }
        text_rot = {
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        }
        if rot[2] then text_pos[3] = text_pos[3] + 1 end
    else
        text_pos = { x, y + 1, z + (4 / 7) + 1 }
        text_rot = {
            0, 0, 1, 0,
            0, 1, 0, 0,
            -1, 0, 0, 0,
            0, 0, 0, 1
        }
        if rot[2] then text_pos[1] = text_pos[1] + 1 end
    end

    if y == maxY then
        text_pos[2] = text_pos[2] + 1 - 1 / 7
    end

    if rot[3] then
        local yx, yy, yz = x + 1, y - (4 / 7), z
        if rot[1] == true then yx = x + 2 - (1/7) end
        if rot[2] == true then yz = z + 1 end
        text_pos = {yx, yy, yz}
        text_rot = {
         0,-1, 0, 0,
         1, 0, 0, 0,
         0, 0, 1, 0,
         0, 0, 0, 1
        }
    end

    local tid = gfx.text3d.show(text_pos, "_", text_table)
    gfx.text3d.set_rotation(tid, text_rot)

    Selections[selection_id][#Selections[selection_id] + 1] = tid
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

    local function showdot(text_pos, text_rot, text)
        local text_scale = 1/16
        local text_table = {
            scale = text_scale,
            xray_opacity = 0,
            render_distance = 250,
            color = col
        }
        local tid = gfx.text3d.show(text_pos, text, text_table)
        gfx.text3d.set_rotation(tid, text_rot)
        Selections[selection_id][#Selections[selection_id] + 1] = tid
    end

    local text_rot = mat4.rotate({0, 1, 0}, 0)
    local text_pos = {x, y+0.5, z+1-0.001}
    local text = "   ∟"
    showdot(text_pos, text_rot, text)

    text_rot = mat4.rotate({0, 1, 0}, 90)
    text_pos = {x+1-0.001, y+0.5, z}
    text = "∟ "
    showdot(text_pos, text_rot, text)

    text_rot = mat4.rotate({0, 1, 0}, 180)
    text_pos = {x, y+0.5, z+0.001}
    text = "∟ "
    showdot(text_pos, text_rot, text)

    text_rot = mat4.rotate({0, 1, 0}, 270)
    text_pos = {x+0.001, y+0.5, z}
    text = "   ∟"
    showdot(text_pos, text_rot, text)

    text_rot = mat4.rotate({1, 0, 0}, 90)
    text_pos = {x, y+0.001, z+0.5}
    text = "   ∟"
    showdot(text_pos, text_rot, text)

    text_rot = mat4.rotate({1, 0, 0}, 270)
    text_pos = {x, y+1-0.001, z+0.5}
    text = "   ∟"
    showdot(text_pos, text_rot, text)

    return selection_id
end

return Select