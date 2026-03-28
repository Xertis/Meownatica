local module = {}

local norm255 = utils.math.norm255
local NextSelectionId = 0
local Selections = {}

local function internal_showdot(selection_id, text_pos, text_axis_x, text_axis_y, text, text_scale, color)
    local text_table = {
        scale = text_scale,
        xray_opacity = 0,
        perspective = 1,
        render_distance = 1000,
        color = color
    }
    local tid = gfx.text3d.show(text_pos, text, text_table)

    local display = "static_billboard"
    if MEOW_CONFIG and MEOW_CONFIG.sliced_preview then
        display = "xy_free_billboard"
    end
    gfx.text3d.update_settings(tid, { display = display })

    gfx.text3d.set_axis_x(tid, text_axis_x)
    gfx.text3d.set_axis_y(tid, text_axis_y)

    if not Selections[selection_id] then Selections[selection_id] = {} end
    table.insert(Selections[selection_id], tid)
end

local function get_face_params(dim_u, dim_v, vec_u, vec_v)
    local max_side = math.max(dim_u, dim_v)
    local scale = max_side / 16
    local ax = { vec_u[1] * dim_u / max_side, vec_u[2] * dim_u / max_side, vec_u[3] * dim_u / max_side }
    local ay = { vec_v[1] * dim_v / max_side, vec_v[2] * dim_v / max_side, vec_v[3] * dim_v / max_side }
    return scale, ax, ay
end

function module.select_blocks(pos1, pos2)
    local blocks = {}
    local _entities = {}
    local x1, y1, z1 = unpack(pos1)
    local x2, y2, z2 = unpack(pos2)

    for x = math.min(x1, x2), math.max(x1, x2) do
        for y = math.min(y1, y2), math.max(y1, y2) do
            for z = math.min(z1, z2), math.max(z1, z2) do
                local block_id = block.get(x, y, z)
                if block_id ~= -1 then
                    if not string.starts_with(block.name(block_id), "meownatica") and not block.is_segment(x, y, z) then
                        table.insert(blocks, {
                            id = block_id,
                            pos = { x, y, z },
                            states = block.get_states(x, y, z)
                        })
                    else
                        table.insert(blocks, {
                            id = 0,
                            pos = { x, y, z },
                            states = 0
                        })
                    end
                else
                    return {}
                end
            end
        end
    end

    local pos = utils.vec.min(pos1, pos2)
    local size = vec3.add(vec3.sub(utils.vec.max(pos1, pos2), pos), 1)
    local uids = entities.get_all_in_box(pos, size)

    for _, uid in ipairs(uids) do
        local entity = entities.get(uid)
        table.insert(_entities, {
            id = entities.get_def(uid),
            pos = entity.transform:get_pos(),
            rotation = entity.transform:get_rot()
        })
    end

    return blocks, _entities
end

function module.draw_single_face(selection_id, x1, y1, z1, x2, y2, z2, side, color)
    local min_x, max_x = math.min(x1, x2), math.max(x1, x2)
    local min_y, max_y = math.min(y1, y2), math.max(y1, y2)
    local min_z, max_z = math.min(z1, z2), math.max(z1, z2)

    local W, H, D = (max_x - min_x) + 1, (max_y - min_y) + 1, (max_z - min_z) + 1
    local zf = -0.001
    local shading = { py = 1.0, ny = 0.5, pz = 0.8, nz = 0.8, px = 0.6, nx = 0.6 }

    local s, ax, ay
    local f_color = { color[1] * shading[side], color[2] * shading[side], color[3] * shading[side], color[4] }

    if side == "pz" then
        s, ax, ay = get_face_params(W, H, { 1, 0, 0 }, { 0, 1, 0 })
        internal_showdot(selection_id, { min_x - 0.5 * W, min_y, max_z + 1 + zf }, ax, ay, "   ∟", s, f_color)
    elseif side == "nz" then
        s, ax, ay = get_face_params(W, H, { -1, 0, 0 }, { 0, 1, 0 })
        internal_showdot(selection_id, { max_x + 1 + 0.5 * W, min_y, min_z - zf }, ax, ay, "   ∟", s, f_color)
    elseif side == "px" then
        s, ax, ay = get_face_params(D, H, { 0, 0, -1 }, { 0, 1, 0 })
        internal_showdot(selection_id, { max_x + 1 + zf, min_y, max_z + 1 + 0.5 * D }, ax, ay, "   ∟", s, f_color)
    elseif side == "nx" then
        s, ax, ay = get_face_params(D, H, { 0, 0, 1 }, { 0, 1, 0 })
        internal_showdot(selection_id, { min_x - zf, min_y, min_z - 0.5 * D }, ax, ay, "   ∟", s, f_color)
    elseif side == "py" then
        s, ax, ay = get_face_params(W, D, { 1, 0, 0 }, { 0, 0, -1 })
        internal_showdot(selection_id, { min_x - 0.5 * W, max_y + 1 + zf, max_z + 1 }, ax, ay, "   ∟", s, f_color)
    elseif side == "ny" then
        s, ax, ay = get_face_params(W, D, { 1, 0, 0 }, { 0, 0, 1 })
        internal_showdot(selection_id, { min_x - 0.5 * W, min_y - zf, min_z }, ax, ay, "   ∟", s, f_color)
    end
end

function module.build_preview(blueprint, origin_pos, blocks)
    local color = { norm255(40), norm255(151), norm255(255), norm255(255) }
    local selection_id = NextSelectionId
    NextSelectionId = NextSelectionId + 1

    Selections[selection_id] = {}

    local grid = {}
    local min_v, max_v = {
        x = math.huge,
        y = math.huge,
        z = math.huge,
    }, {
        x = -math.huge,
        y = -math.huge,
        z = -math.huge
    }

    for _, blk in ipairs(blocks) do
        local block_id = block.index(blueprint.block_indexes.from[blk.id].name)
        if block_id ~= 0 then
            local p = vec3.add(origin_pos, blk.pos)
            local x, y, z = math.floor(p[1]), math.floor(p[2]), math.floor(p[3])
            grid[x] = grid[x] or {}
            grid[x][y] = grid[x][y] or {}
            grid[x][y][z] = true

            min_v.x, max_v.x = math.min(min_v.x, x), math.max(max_v.x, x)
            min_v.y, max_v.y = math.min(min_v.y, y), math.max(max_v.y, y)
            min_v.z, max_v.z = math.min(min_v.z, z), math.max(max_v.z, z)
        end
    end

    local function has_block(x, y, z)
        return grid[x] and grid[x][y] and grid[x][y][z]
    end

    local function mesh_side(side_name, is_pos)
        local c_min = (side_name == "x" and min_v.x or side_name == "y" and min_v.y or min_v.z)
        local c_max = (side_name == "x" and max_v.x or side_name == "y" and max_v.y or max_v.z)

        for c = c_min, c_max do
            local visited = {}

            local u_min = (side_name == "x" and min_v.y or min_v.x)
            local u_max = (side_name == "x" and max_v.y or max_v.x)
            local v_min = (side_name == "z" and min_v.y or min_v.z)
            local v_max = (side_name == "z" and max_v.y or max_v.z)

            for u = u_min, u_max do
                for v = v_min, v_max do
                    local x, y, z
                    if side_name == "x" then
                        x, y, z = c, u, v
                    elseif side_name == "y" then
                        x, y, z = u, c, v
                    else
                        x, y, z = u, v, c
                    end

                    local needs_face = has_block(x, y, z)
                    if needs_face then
                        local nx, ny, nz = x, y, z
                        if side_name == "x" then
                            nx = x + (is_pos and 1 or -1)
                        elseif side_name == "y" then
                            ny = y + (is_pos and 1 or -1)
                        else
                            nz = z + (is_pos and 1 or -1)
                        end

                        if has_block(nx, ny, nz) then needs_face = false end
                    end

                    if needs_face and not (visited[u] and visited[u][v]) then
                        local eu = u
                        while eu + 1 <= u_max do
                            local next_u = eu + 1
                            local tx, ty, tz, ntx, nty, ntz
                            if side_name == "x" then
                                tx, ty, tz = c, next_u, v
                                ntx, nty, ntz = c + (is_pos and 1 or -1), next_u, v
                            elseif side_name == "y" then
                                tx, ty, tz = next_u, c, v
                                ntx, nty, ntz = next_u, c + (is_pos and 1 or -1), v
                            else
                                tx, ty, tz = next_u, v, c
                                ntx, nty, ntz = next_u, v, c + (is_pos and 1 or -1)
                            end

                            if has_block(tx, ty, tz) and not has_block(ntx, nty, ntz) and not (visited[next_u] and visited[next_u][v]) then
                                eu = next_u
                            else
                                break
                            end
                        end

                        local ev = v
                        while ev + 1 <= v_max do
                            local next_v = ev + 1
                            local can_expand = true
                            for tu = u, eu do
                                local tx, ty, tz, ntx, nty, ntz
                                if side_name == "x" then
                                    tx, ty, tz = c, tu, next_v
                                    ntx, nty, ntz = c + (is_pos and 1 or -1), tu, next_v
                                elseif side_name == "y" then
                                    tx, ty, tz = tu, c, next_v
                                    ntx, nty, ntz = tu, c + (is_pos and 1 or -1), next_v
                                else
                                    tx, ty, tz = tu, next_v, c
                                    ntx, nty, ntz = tu, next_v, c + (is_pos and 1 or -1)
                                end
                                if not (has_block(tx, ty, tz) and not has_block(ntx, nty, ntz) and not (visited[tu] and visited[tu][next_v])) then
                                    can_expand = false; break
                                end
                            end
                            if can_expand then ev = next_v else break end
                        end

                        for tu = u, eu do
                            visited[tu] = visited[tu] or {}
                            for tv = v, ev do visited[tu][tv] = true end
                        end

                        local side_code = (is_pos and "p" or "n") .. side_name
                        if side_name == "x" then
                            module.draw_single_face(selection_id, c, u, v, c, eu, ev, side_code, color)
                        elseif side_name == "y" then
                            module.draw_single_face(selection_id, u, c, v, eu, c, ev, side_code, color)
                        else
                            module.draw_single_face(selection_id, u, v, c, eu, ev, c, side_code, color)
                        end
                    end
                end
            end
        end
    end

    mesh_side("x", true); mesh_side("x", false)
    mesh_side("y", true); mesh_side("y", false)
    mesh_side("z", true); mesh_side("z", false)

    table.insert(blueprint.preview_ids, selection_id)
end

function module.unbuild_preview(blueprint)
    for i = #blueprint.preview_ids, 1, -1 do
        local id = blueprint.preview_ids[i]
        local sel = Selections[id]

        if sel then
            for _, tid in ipairs(sel) do
                gfx.text3d.hide(tid)
            end
            Selections[id] = nil
        end
        table.remove(blueprint.preview_ids, i)
    end
end

return module
