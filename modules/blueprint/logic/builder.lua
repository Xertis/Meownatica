local rotator = require "blueprint/logic/rotation"
local module = {}

local queue = {}

function module.build(origin_pos, max_blocks_per_tick, blueprint)
    local rotated = rotator.dual_pass_rotated(blueprint.blocks, blueprint.rotation_matrix)
    local builded_blocks = 0

    local co = coroutine.create(function ()
        for _, blk in ipairs(rotated) do
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
                block.set(world_x, world_y, world_z, id, blk.states)
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