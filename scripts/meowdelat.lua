local BluePrint = require "blueprint/blueprint"

local function __select_blocks(pos1, pos2)
    local blocks = {}
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
                            pos = {x, y, z},
                            states = block.get_states(x, y, z)
                        })
                    else
                        table.insert(blocks, {
                            id = 0,
                            pos = {x, y, z},
                            states = 0
                        })
                    end
                else
                    return {}
                end
            end
        end
    end

    return blocks
end

function on_breaking(x, y, z)
    local pair_x = block.get_field(
        x, y, z,
        "pair_x"
    )
    local pair_y = block.get_field(
        x, y, z,
        "pair_y"
    )
    local pair_z = block.get_field(
        x, y, z,
        "pair_z"
    )

    if pair_x then
        block.set(pair_x, pair_y, pair_z, 0)
    end
end

function on_placed(x, y, z)
    local id = CURRENT_BORDER_ID
    CURRENT_BORDER_ID = utils.math.in_range(CURRENT_BORDER_ID+1, {1, 2})
    BORDERS[id] = {x, y, z}

    if id ~= 2 then
        return
    end

    for self_id, pos in ipairs(BORDERS) do
        local self_x, self_y, self_z = unpack(pos)
        local pair_x, pair_y, pair_z = unpack(BORDERS[utils.math.in_range(self_id+1, {1, 2})])

        block.set_field(
            pair_x, pair_y, pair_z, "pair_x", self_x
        )
        block.set_field(
            pair_x, pair_y, pair_z, "pair_y", self_y
        )
        block.set_field(
            pair_x, pair_y, pair_z, "pair_z", self_z
        )
    end

    local blocks = __select_blocks(BORDERS[1], BORDERS[2])
    if #blocks == 0 then return end

    local origin = {x, y, z}
    if y > BORDERS[1][2] then origin = BORDERS[1] end

    local blue_print = BluePrint.new(blocks, origin)
    CURRENT_BLUEPRINT = blue_print
end