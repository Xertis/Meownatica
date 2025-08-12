local rotator = require "blueprint/logic/rotation"
local module = {}

local queue = {}

local function compose_rotation(rot, facing, angle, profile)
    if profile == "none" then
        return 0
    end

    if profile == "pipe" then
        return dirs[profile][tostring(facing) .. tostring(rot)]
    end

    local rotate = dirs[profile][tostring(facing) .. tostring(angle)] or rot

    return rotate
end

function module.build(origin_pos, max_units_per_tick, blueprint)
    local rotated_blocks = blueprint.blocks
    local rotated_entities = blueprint.entities
    local rotated = false
    if blueprint.rotation_vector[1] ~= 0 or blueprint.rotation_vector[2] ~= 0 or blueprint.rotation_vector[3] ~= 0 then
        rotated_blocks = rotator.dual_pass_rotated(rotated_blocks, blueprint.rotation_matrix)
        rotated_entities = rotator.entities_rotate(rotated_entities, {0, 0, 0}, blueprint.rotation_matrix)
        rotated = true
    end

    local common_facing, common_angle = utils.vec.facing(blueprint.rotation_vector)
    local builded_unit = 0

    local co = coroutine.create(function ()
        for _, blk in ipairs(rotated_blocks) do
            if builded_unit > max_units_per_tick then
                coroutine.yield()
                builded_unit = 0
            end

            local p = blk.pos
            local world_x = origin_pos[1] + p[1]
            local world_y = origin_pos[2] + p[2]
            local world_z = origin_pos[3] + p[3]

            local id = block.index(blueprint.block_indexes.from[blk.id].name)
            if (not MEOW_CONFIG.setair and id ~= 0) or MEOW_CONFIG.setair then
                local new_states = blk.states

                if rotated then
                    local rot = bit.band(blk.states, 7)
                    local new_rot = rotator.transform_block(common_facing, common_angle, rot, block.get_rotation_profile(id))

                    new_states = bit.rshift(new_states, 3)
                    new_states = bit.lshift(new_states, 3)
                    new_states = bit.bor(new_states, new_rot)
                end

                block.set(world_x, world_y, world_z, id, new_states, true)
            end

            builded_unit = builded_unit + 1
        end

        if not MEOW_CONFIG.spawn_entities then
            return
        end

        for _, entity in ipairs(rotated_entities) do
            if builded_unit > max_units_per_tick then
                coroutine.yield()
                builded_unit = 0
            end

            local pos = vec3.add(entity.pos, origin_pos)
            local _entity = entities.spawn(blueprint.entity_indexes.from[entity.id].name, pos)
            _entity.transform:set_rot(entity.rotation)
        end
    end)

    table.insert(queue, co)
end

function module.tick()
    for i = #queue, 1, -1 do
        local co = queue[i]
        if coroutine.status(co) ~= "dead" then
            local success, err = coroutine.resume(co)
            if not success then
                print("Error in coroutine: " .. tostring(err))
                table.remove(queue, i)
            end
        else
            table.remove(queue, i)
        end
    end
end

return module