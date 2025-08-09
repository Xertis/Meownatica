local rotator = require "blueprint/logic/rotation"
local module = {}

local queue = {}

local function compose_rotation(rot, facing, profile)
    local new_rot = rot

    if facing == 0 then
        if rot == 0 then
            new_rot = 1
        elseif rot == 1 then
            new_rot = 2
        elseif rot == 2 then
            new_rot = 3
        elseif rot == 3 then
            new_rot = 0
        end
    elseif facing == 5 then
        if rot == 0 then
            new_rot = 2
        elseif rot == 1 then
            new_rot = 3
        elseif rot == 2 then
            new_rot = 0
        elseif rot == 3 then
            new_rot = 1
        end
    elseif facing == 1 then
        if rot == 0 then
            new_rot = 3
        elseif rot == 1 then
            new_rot = 0
        elseif rot == 2 then
            new_rot = 1
        elseif rot == 3 then
            new_rot = 2
        end
    elseif facing == 3 then
        if rot == 4 then
            new_rot = 0
        elseif rot == 0 then
            new_rot = 5
        elseif rot == 5 then
            new_rot = 2
        elseif rot == 2 then
            new_rot = 4
        elseif rot == 1 then
            new_rot = 1
        elseif rot == 3 then
            new_rot = 3
        end
    elseif facing == 4 then
        if rot == 4 then
            new_rot = 1
        elseif rot == 3 then
            new_rot = 4
        elseif rot == 1 then
            new_rot = 5
        elseif rot == 2 then
            new_rot = 2
        elseif rot == 0 then
            new_rot = 0
        elseif rot == 5 then
            new_rot = 3
        end
    elseif facing == 2 then
        if rot == 4 then
            new_rot = 2
        elseif rot == 2 then
            new_rot = 5
        elseif rot == 0 then
            new_rot = 4
        elseif rot == 5 then
            new_rot = 2
        elseif rot == 3 then
            new_rot = 3
        elseif rot == 1 then
            new_rot = 1
        end
    end

    if profile == "none" then
        new_rot = 0
    elseif profile == "pane" then
        new_rot = math.clamp(new_rot, 0, 3)
    end

    return new_rot
end

function module.build(origin_pos, max_blocks_per_tick, blueprint)
    local rotated_blocks = blueprint.blocks
    local rotated = false
    if blueprint.rotation_vector[1] ~= 0 or blueprint.rotation_vector[2] ~= 0 or blueprint.rotation_vector[3] ~= 0 then
        rotated_blocks = rotator.dual_pass_rotated(blueprint.blocks, blueprint.rotation_matrix)
        rotated = true
    end

    local common_facing = utils.vec.facing(blueprint.rotation_vector)
    local builded_blocks = 0

    local co = coroutine.create(function ()
        for _, blk in ipairs(rotated_blocks) do
            if builded_blocks > max_blocks_per_tick then
                coroutine.yield()
                builded_blocks = 0
            end

            local p = blk.pos
            local world_x = origin_pos[1] + p[1]
            local world_y = origin_pos[2] + p[2]
            local world_z = origin_pos[3] + p[3]

            local id = block.index(blueprint.indexes.from[blk.id].name)
            if (not MEOW_CONFIG.setair and id ~= 0) or MEOW_CONFIG.setair then
                local new_states = blk.states

                if rotated then
                    local rot = bit.band(blk.states, 7)
                    local new_rot = compose_rotation(rot, common_facing, block.get_rotation_profile(id))

                    new_states = bit.rshift(new_states, 3)
                    new_states = bit.lshift(new_states, 3)
                    new_states = bit.bor(new_states, new_rot)
                end

                block.set(world_x, world_y, world_z, id, new_states, true)
            end

            builded_blocks = builded_blocks + 1
        end
    end)

    table.insert(queue, co)
end

function module.tick()
    for i=#queue, 1, -1 do
        local co = queue[i]
        if coroutine.status(co) ~= "dead" then
            coroutine.resume(co)
        else
            table.remove(queue, i)
        end
    end
end

return module